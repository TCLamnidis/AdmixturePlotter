#!/usr/bin/env Rscript

## Define functions ----------------------------

## A function that calculates the correlation matrix for a K and it's K-1
correlate_components <- function(k, k_min) {
  start_this_k = 2+sum(1:k-1)-(sum(1:k_min-1))+1
  end_this_k = start_this_k+k-1
  end_prev_k = start_this_k-1
  start_prev_k = end_prev_k-(k-2)
  # print (paste0("This K: ",start_this_k,":",end_this_k))
  # print (paste0("Prev K: ",start_prev_k,":",end_prev_k))
  cor(raw_data[start_prev_k:end_prev_k], raw_data[start_this_k:end_this_k])
}

## A function that returns the column name of the best correlated component in 
##   the K-1 run, for each component in the K run.
fix_colours <- function(k, k_min) {
  ## If the K being processed is the minimum K in the data, keep columns 
  ##  unchanged (since there is nothing to compare to).
  if (k == k_min) {
    return(paste0(k, ":", 1:k))
  }
  
  ## Calculate a correlation matrix for each component of this K to the 
  ##   components of K-1.
  cor_mat <- correlate_components(k, k_min)
  
  ## Find the most correlated component from the last K for each component in 
  ##   this K.
  component_order <- c()
  for (x in 1:k-1) {
    component_order <- append(component_order, which.max(cor_mat[x, ]))
  }
  
  ## If one component in the last K is the most correlated with two components 
  ##   on this K, find the next best correlated component, and if that is 
  ##   unique, assign that as the correct component.
  ## If it is not unique, repeat the process until a unique component is found.
  if (any(duplicated(component_order)) == T && 
      sum(duplicated(component_order)) == 1) {
    duplicate <- which(duplicated(component_order))
    condition <- T
    top_correlates <- c()
    while (condition == T) {
      ## 
      ## until one that isn't already crrelated with another component is found.
      top_correlates <- c(top_correlates, which.max(cor_mat[duplicate, ]))
      cor_mat[duplicate, top_correlates] <- NA
      component_order[duplicate] <- which.max(cor_mat[duplicate, ])
      if (any(duplicated(component_order)) == F) {condition = F}
    }
  } else if (sum(duplicated(component_order)) > 1) {
    stop (paste0("Correlation of components failed. Usually this is caused by high CV errors for some of the components you are trying to plot. 
Please consider limiting your input dataset to K=",k_min," to ",k-1,".

You can use this command to extract the suggested columns from the input file:
    cut -d ' ' -f 1-",sum(seq(k_min,k_max-1))+2,"
    "), call.=FALSE)
  }
  ## If a component hasn't been resolved yet, add it as the newest component.
  missing_component = setdiff(1:k, component_order)
  component_order<-append(component_order, missing_component)
  return(paste0(k,":", component_order))
}

pick_colour <- function(x) {
  return(colours[x])
}
#### MAIN ####

## Load libraries -----------------------------
library(optparse)
library(ggplot2)
library(dplyr, warn.conflicts = F)
library(tidyr)
library(stringr)
library(readr)

## Parse arguments ----------------------------
parser <- OptionParser()
parser <- add_option(parser, c("-i", "--input"), type = 'character', 
                     action = "store", dest = "input", 
                     help = "The input data file. This file should contain all 
                     components per K per indiviual for all K values.")
parser <- add_option(parser, c("-c", "--colourList"), type = 'character',
                     action = "store", dest = "colourList", 
                     help = "A file of desired colours, in R compatible formats.
                     One colour per line.")
parser <- add_option(parser, c("-p", "--popOrder"), type = "character",
                     action = 'store', dest = 'popOrder', 
                     help = "A file containing one population per line in the 
                     desired order.")
parser <- add_option(parser, c("-o", "--outputPlot"), type = "character", 
                     action = 'store', default = "OutputPlot", dest = 'output', 
                     help = "The desired name of the output plot. 
                     [Default: '%default.pdf']")
parser <- add_option(parser, c("-r", "--remove"), type = "logical", 
                     action = 'store_true', default = F, dest = 'remove', 
                     help = "If an order list is provided, should populations not 
                     in the list be removed from the output plot?
                     Not recommended for final figures, but can help in cases 
                     where you are trying to focus on a certain subset of your 
                     populations.")

args <- parse_args(parser)
## If no input is given, script will exit and provide Usage information.
if (is.null(args$input) == T) {
  write("No input file given. Halting execution.", stderr())
  print_help(parser)
  quit(status = 1)
}

## Read cli options into variables.
input <- args$input
colour_file <- args$colourList
## Output name will ignore '.pdf' suffix if provided by user
output <- sub(x = args$output, replacement = "", pattern = ".pdf") 
pop_order <- args$popOrder
if (args$remove && is.null(args$popOrder)){
  write("No population order specified. 'remove' option ignored.", stderr())
}

## Load data --------------------------------

## read data
raw_data <- read_delim(input, " ", col_types = cols())

## Infer min and max K values.
k_min <- as.numeric(str_split_fixed(names(raw_data[,3]),":",2)[1])
k_max <- as.numeric(str_split_fixed(names(raw_data[,ncol(raw_data)]),":",2)[1])

## Sort components of each K according to correlation with components of K-1. 
##   This needs to happen per K, otherwise the correlations will not match 
##   beyond the first pair of Ks.
header <- names(raw_data) ## Take column names from original data

## 'Ind' and 'Pop' should always be at the start of the reformatted data.
refcols = c("Ind", "Pop") 

## For each K in the data, use fix_colours to extract the vector of most correlated
##   column names for each Component in the K. Then sort the components of this 
##   K in the raw data.
for (k in k_min:k_max) { 
  refcols <- c(refcols, fix_colours(k,k_min)) ##    
  raw_data <- raw_data[, c(refcols, setdiff(names(raw_data), refcols))] ## 
}

## Finally, fix the column names so that inference of component numbers is correct
names(raw_data) <- header 

## Flatten data to long format
long_data <- gather(raw_data, temp, value, 3:ncol(raw_data))
## Remove raw_data from memory to reduce memory footprint.
rm(raw_data)
## Split K and Component name to separate columns
long_data <- long_data %>% 
  separate(temp, c("K","Component"), sep = ":") %>%
  mutate(K = as.numeric(K), Component = as.numeric(Component))

## If no colour list is provided, use rainbow() to generate the required number 
##   of colours. Otherwise, read the colour definitions into a vector.
if (is.null(colour_file) == T){
  colours = rainbow(k_max)
} else {
  colours = read_delim(colour_file, "\n", col_types = cols(), col_names = F)
  colours <- colours$X1
}

## Create colour column based on colour vector.
## Each component in each K run is given the colour of the same index as that 
##   component from the colours list.
long_data <- long_data %>% 
  mutate(clr = purrr::map(Component, pick_colour) %>% 
           unlist)

## Set order of Pops
## If no OrderList is provided, then the populations are sorted alphabetically
if (is.null(pop_order) == F) {
  order <- read.delim(pop_order, header = F, col.names = "Pops")
  long_data$Pop_f <- factor(long_data$Pop, levels = order$Pops)
} else {
  long_data$Pop_f <- long_data$Pop
}

## Early testing dataset subset
# temp_data <- filter(long_data, K == 2)

## Create the named vector (dictionary) of colours needed for scale_fill_manual.
## Each colour is mapped to itself.
col <- as.character(long_data$clr)
names(col) <- as.character(long_data$clr)

if (is.null(args$remove) == F) {
  long_data <- drop_na(long_data, 'Pop_f')
}

## Plot data --------------------------------------------

## Plot the value of each component(y) per individual(x). 'clr' is also the 
##   categorical variable, which is ok since each category will be seen once per K.
ggplot(long_data, aes(x = Ind , y = value, fill = clr)) +
          geom_bar(stat = 'identity', width = 1) +
  ## Colour bars by colour vector.
  scale_fill_manual(values = col) +
  ## X scale changed per Pop. 0 multiplicative change, and +1 additive.
  ## Creates the white bars between groups.
  scale_x_discrete(expand = c(0, 1)) +
  ## Set Y axis label
  ylab("K = ") +
  theme_minimal() +
  theme(legend.position = "none", ## No legend
        text = element_text(family = "Helvetica"),
        # axis.text.x = element_text(angle = 90, hjust = 1, size = 6),
        ## Rotate and resize X axis strip text (Pop Names)
        strip.text.x = element_text(angle = 90, hjust = 0, size = 4),
        ## Rotate Y axis strip text (K value)
        strip.text.y = element_text(angle = 180),
        panel.spacing.x = unit(0, "lines"),
        ## Set white space between K plots.
        panel.spacing.y = unit(0.005, "lines"), 
        ## Remove axis ticks, and axis text (ancestry proportion and sample names)
        axis.ticks = element_blank(), 
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        ## Remove X axis title ("Ind") 
        axis.title.x = element_blank(), 
        ## Remove gridlines from plot
        panel.grid = element_blank()) +
  ## Creates the plot made so far for each K and each Pop.
  ## The plots per POP are then plotted on top of one another to create each K plot. 
  ## The per K plots are plotted below one another.
  facet_grid(K~ Pop_f,
             scales = "free_x",
             space = "free",
             ## switchlabels of the Y-axis so they is plotted to the left (K=).
             switch = "y") +
  ## Saves the plot as a pdf with specified size.
  ggsave(filename = paste0(output,".pdf"), 
         limitsize = F,
         width = 50, height = 20,
         units = "cm")

## Silently remove the Rplots.pdf file, if one was created.
if (file.exists("Rplots.pdf") && output !=  "Rplots") {
    invisible(file.remove("Rplots.pdf"))
}

