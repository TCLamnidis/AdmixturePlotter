#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=F)
library(tidyr)
library(stringr)
library(readr)
args <- commandArgs(TRUE)
## If no input is given, script will exit and provide Usage information.
if (is.na(args[1]) == T || is.na(args[2]) == T ){
  print("Usage: Rscript AdmixturePlotter.R input colourfile [output plot] [pop order] [remove]")
  quit(status=1)
}
input <- args[1]
colourFile <- args[2]

## If no output name is given, script will default to "OutputPlot.pdf"
if (is.na(args[3]) == T) {
  output <- "OutputPlot"
} else {
  output <- output <- sub(x=args[3], replacement="", pattern=".pdf") ## Will ignore '.pdf' suffix if provided by user
}

## read in the colour vectors for each K
source(colourFile)

## read data
raw_data <- read_delim(input, " ", col_types = cols())
## flatten data to long format
long_data <- gather(raw_data, temp, value, 3:ncol(raw_data))
## Split K and Component name to separate columns
long_data <- mutate(rowwise(long_data), K=as.numeric(str_split_fixed(temp,":", 2)[[1]]))
long_data <- mutate(rowwise(long_data), Component=as.numeric(str_split_fixed(temp,":", 2)[[2]]))
## Remove temp column (informtion now contained in two columns.)
long_data <- select(long_data, -temp)

## Create colour column based on sources colour vectors
## Each component in each K run is given the colour that shares the same index in the sourced vectors as the component.
## i.e. K=2 component=1 gets the colour corresponding to the first element of the colour vector for K=2 (clr2[1]).
long_data <- mutate(rowwise(long_data), clr=eval(parse(text=paste0("clr", K)))[Component])


## Set order of Pops
if (is.na(args[4]) == F) {
  order <- read.delim(args[4], header=F, col.names = "Pops")
  long_data$Pop_f <- factor(long_data$Pop, levels=order$Pops)
} else {
  ## If no OrderList is provided, then the populations are sorted alphabetically
  long_data$Pop_f <- long_data$Pop
}

## Early testing dataset subset
# temp_data <- filter(long_data, K == 2)

## Create the named vector (dictionary) of colours needed for scale_fill_manual.
## Each colour is mapped to itself.
col <- as.character(long_data$clr)
names(col) <- as.character(long_data$clr)

if(is.na(args[5])== F){
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
 
if (file.exists("Rplots.pdf") && output != "Rplots") {
    invisible(file.remove("Rplots.pdf"))
}

