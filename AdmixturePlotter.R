#!/usr/bin/env Rscript
## A function that calculates the correlation matrix for a K and it's K-1
correlate_Components <- function(K, Kmin) {
  start_this_K=2+sum(1:K-1)-(sum(1:Kmin-1))+1
  end_this_K=start_this_K+K-1
  end_prev_K=start_this_K-1
  start_prev_K=end_prev_K-(K-2)
  # print (paste0("This K: ",start_this_K,":",end_this_K))
  # print (paste0("Prev K: ",start_prev_K,":",end_prev_K))
  cor(raw_data[start_prev_K:end_prev_K],raw_data[start_this_K:end_this_K])
}

## A function that returns the column name of the best correlated component in the K-1 run, for each component in the K run.
fix_colours <- function (K, Kmin) {
  ## If the K being processed is the minimum K in the data, keep columns unchanged (since there is nothing to compare to).
  if (K==Kmin){
    return (paste0(K,":", 1:K))
  }
  
  ## Calculate a correlation matrix for each component of this K to the components of K-1.
  Cor_mat<-correlate_Components(K, Kmin)
  
  ## Find the most correlated component from the last K for each component in this K.
  comp_order=c()
  for (x in 1:K-1) {
    comp_order<- append(comp_order, which.max(Cor_mat[x,]))
  }
  
  ## If one component in the last K is the most correlated with two components on this K, 
  ## find the next best correlated component, and if that is unique, assign that as the correct component.
  ## If it is not unique, repeat the process until a unique component is found.
  if (any(duplicated(comp_order)) == T && sum(duplicated(comp_order) == 1 )){
    Condition = T
    Top_Correlates <- c()
    while (Condition == T){
      ## 
      ## until one that isn't already crrelated with another component is found.
      Top_Correlates <- c(Top_Correlates,which.max(Cor_mat[which(duplicated(comp_order)),]))
      comp_order[which(duplicated(comp_order))]=which.max(Cor_mat[which(duplicated(comp_order)),-Top_Correlates])
      if (any(duplicated(comp_order)) == F) { Condition=F }
    }
  } else if (sum(duplicated(comp_order) > 1)){
    print ("You have encountered a new type of error. 
           Please let the author of this R script know so they can implement a fix for it.")
  }
  ## If a component hasn't been resolved yet, add it as the newest component.
  missing_component=setdiff(1:K,comp_order)
  comp_order<-append(comp_order, missing_component)
  return(paste0(K,":",comp_order))
}


#### MAIN ####

library(optparse)
library(ggplot2)
library(dplyr, warn.conflicts=F)
library(tidyr)
library(stringr)
library(readr)

parser <- OptionParser()
parser <- add_option(parser, c("-i", "--input"), type='character', action="store", 
                     dest="input", help="The input data file. This file should contain all components per K per indiviual for all K values.")
parser <- add_option(parser, c("-c", "--colourList"), type='character', action="store", 
                     dest="colourList", help="A file of desired colours, in R compatible formats. One colour per line.")
parser <- add_option(parser, c("-p", "--orderList"), type="character", action='store', 
                     dest='popOrder', help="A file containing one population per line in the desired order.")
parser <- add_option(parser, c("-o", "--outputPlot"), type="character", action='store', default = "OutputPlot",
                     dest='output', help="The desired name of the output plot. [Default: '%default.pdf']")
parser <- add_option(parser, c("-r", "--remove"), type="logical", action='store_true',
                     default = F, dest='remove', 
                     help="If an order list is provided, should populations not in the list be removed from the output plot?
                     Not recommended for final figures, but can help in cases where you are trying to focus on a certain subset of your populations.")

args <- parse_args(parser)
## If no input is given, script will exit and provide Usage information.
if (is.null(args$input) == T ){
  write("No input file given. Halting execution.", stderr())
  print_help(parser)
  quit(status=1)
}

## Read cli options into variables.
input <- args$input
colourFile <- args$colourList
output <- sub(x=args$output, replacement="", pattern=".pdf") ## Will ignore '.pdf' suffix if provided by user
popOrder <- args$popOrder

## read data
raw_data <- read_delim(input, " ", col_types = cols())

## Infer min and max K values.
Kmin <- as.numeric(str_split_fixed(names(raw_data[,3]),":",2)[1])
Kmax <- as.numeric(str_split_fixed(names(raw_data[,ncol(raw_data)]),":",2)[1])

## Sort components of each K according to correlation with components of K-1. This needs to happen per K, 
## otherwise the correlations will not match beyond the first pair of Ks.
header <- names(raw_data) ## Take column names from original data
refcols=c("Ind","Pop") ## 'Ind' and 'Pop' should always be at the start of the reformatted data.
for (K in Kmin:Kmax) { ##                          For each K in the data
  refcols <- c(refcols, fix_colours(K,Kmin)) ##    Use fix_colours to extract the vector of most correlated column names for each Component in the K.
  raw_data <- raw_data[,c(refcols, setdiff(names(raw_data),refcols))] ## Then sort the components of this K in the raw data
}
names(raw_data) <- header ## Finally, fix the column names so that inference of component numbers is done correctly

## flatten data to long format
long_data <- gather(raw_data, temp, value, 3:ncol(raw_data))
## Split K and Component name to separate columns
long_data <- mutate(rowwise(long_data), K=as.numeric(str_split_fixed(temp,":", 2)[[1]]))
long_data <- mutate(rowwise(long_data), Component=as.numeric(str_split_fixed(temp,":", 2)[[2]]))
## Remove temp column (informtion now contained in two columns.)
long_data <- select(long_data, -temp)

## If no colour list is provided, use rainbow() to generate the required number of colours.
## Otherwise, read the colour definitions int a vector.
if (is.null(args$colourList) == T){
  colours=rainbow(Kmax)
} else {
  colours=read_delim(colourFile,"\n", col_types = cols(),col_names = F)
  colours <- colours$X1
}

## Create colour column based on colour vector.
## Each component in each K run is given the colour of the same index as that component from the colours list.
long_data <- mutate(rowwise(long_data), clr=colours[Component])

## Set order of Pops
## If no OrderList is provided, then the populations are sorted alphabetically
if (is.null(popOrder) == F) {
  order <- read.delim(popOrder, header=F, col.names = "Pops")
  long_data$Pop_f <- factor(long_data$Pop, levels=order$Pops)
} else {
  long_data$Pop_f <- long_data$Pop
}

## Early testing dataset subset
# temp_data <- filter(long_data, K == 2)

## Create the named vector (dictionary) of colours needed for scale_fill_manual.
## Each colour is mapped to itself.
col <- as.character(long_data$clr)
names(col) <- as.character(long_data$clr)

if(is.null(args$remove) == F){
  long_data <- drop_na(long_data, 'Pop_f')
}

## Plot the value of each component(y) per individual(x).
## 'clr' is also the categorical variable, which is ok since each category will be seen once per K.
ggplot(long_data, aes(x=Ind , y=value, fill=clr)) +
          geom_bar(stat='identity', width=1) +
  ## Colour bars by colour vector.
  scale_fill_manual(values=col) +
  ## X scale changed per Pop. 0 multiplicative change, and +1 additive.
  ## Creates the white bars between groups.
  scale_x_discrete(expand=c(0,1)) +
  ## Set Y axis label
  ylab("K=") +
  theme_minimal() +
  theme(legend.position = "none", ## No legend
        text = element_text(family="Helvetica"),
        # axis.text.x = element_text(angle = 90, hjust = 1, size = 6),
        strip.text.x =element_text(angle = 90, hjust = 0, size = 4), ## Rotate and resize X axis strip text (Pop Names)
        strip.text.y = element_text(angle = 180), ## Rotate Y axis strip text (K value)
        panel.spacing.x = unit(0,"lines"), 
        panel.spacing.y = unit(0.005,"lines"), ## Sets white space between K plots.
        axis.ticks = element_blank(), ## Remove axis ticks, and axis text (ancestry proportion and sample names)
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        axis.title.x = element_blank(), ## Remove X axis title ("Ind") 
        panel.grid = element_blank()) + ## Remove gridlines from plot
  ## Creates the plot made so far for each K and each Pop.
  ## The plots per POP are then plotted on top of one another to create each K plot. 
  ## The per K plots are plotted below one another
  facet_grid(K~ Pop_f,
             scales="free_x",
             space = "free",
             switch = "y") + ## switches the labels of the Y-axis so it is plotted to the left ([2:15])
  ## Saves the plot as a pdf with specified size.
  ggsave(filename = paste0(output,".pdf"), 
         limitsize=F,
         width=50, height=20,
         units="cm")

## Silently remove the Rplots.pdf file, if one was created.
if (file.exists("Rplots.pdf") && output != "Rplots") {
    invisible(file.remove("Rplots.pdf"))
}

