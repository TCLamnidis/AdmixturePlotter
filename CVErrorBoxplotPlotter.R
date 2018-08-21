#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
if (is.na(args[1]) == T || is.na(args[2]) == T ){
  print("Usage: Rscript CVErrorBoxplotPlotter.R input output")
  quit(status=1)
}
input <- args[1]
output <- paste0(sub(x=args[2], replacement="", pattern=".png"),".png") ## Will ignore '.png' suffix if provided by user

## CV error distribution for the top K replicates
CVs = read.table(input, header=T)

## box plot for CV errors of all replicates
png(output, height=20, width=1.5*ncol(CVs), res=300, units="cm")
par(cex.main=1.2, cex.axis=1, cex.lab=1)
par(mar=c(5.1,4.6,4.1,2.1))
boxplot(CVs, xlab="K", ylab="CV error", xaxt="n", main="")
mtext(3, text=input, line=2.2, cex=1.3, font=2)
mtext(3, text="CV error for all replicates", line=0.8, cex=1.2)
axis(side=1, at=1:ncol(CVs), label=(1:ncol(CVs))+1)
dev.off()