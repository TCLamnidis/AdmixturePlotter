#!/usr/bin/env Rscript
library(stringr)

args <- commandArgs(TRUE)
if (is.na(args[1]) == T || is.na(args[2]) == T ){
  print("Usage: Rscript CVErrorBoxplotPlotter.R input output")
  quit(status=1)
}
input <- args[1]
output <- paste0(sub(x=args[2], replacement="", pattern=".png"),".png") ## Will ignore '.png' suffix if provided by user

## CV error distribution for the top K replicates
CVs = read.table(input, header=T)
minK <- str_remove(names(CVs), "X") [1]
maxK <- rev(str_remove(names(CVs), "X")) [1]
## box plot for CV errors of all replicates
png(output, height=20, width=1.5*ncol(CVs), res=300, units="cm")
par(cex.main=1.2, cex.axis=1, cex.lab=1)
par(mar=c(5.1,4.6,4.1,2.1))
boxplot(CVs, xlab="K", ylab="CV error", xaxt="n", main="")
# mtext(3, text=input, line=2.2, cex=1.3, font=2)
mtext(3, text="CV error for all replicates", line=1.5, cex=1.3, font=2)
axis(side=1, at=1:ncol(CVs), label=minK:maxK)
dev.off()