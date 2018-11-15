# AdmixturePlotter
An R script to generate plots for ADMIXTURE runs, for multiple K values. 

You can run either script without specifying any arguments to get a short usage explanation.

# CVErrorBoxplotPlotter.R
This is a script to plot the CV error for multiple replicates per K value in box-and-whisker format. The expected input is a space- or 
tab-separated table with each column being a K value, and each row a replicate. A header is expected of the K value the replicates in 
the column correspond to.

Example input for K=2 to 5 (space separated):
```
2 3 4 5
0.49993 0.47984 0.47426 0.47029
0.49993 0.47985 0.47427 0.47028
0.49992 0.47985 0.47430 0.47032
0.49993 0.47984 0.47424 0.47033
0.49994 0.47984 0.47428 0.47033
```

`CVErrorBoxplotPlotter.R` can then be ran by specifying the input and output file names.
```bash
CVErrorBoxplotPlotter.R CVErrors.input.txt CVErrorBoxPlot
```
This will create a figure named **CVErrorBoxPlot.png**.

# AdmixturePlotter.perK.R
This is a script to plot ADMIXTURE output for multiple K values.  The expected input file is a space separated compound dataset of all 
the results per component per K, with labelling of individual and population name. Once again, a header is expected. Each line 
correctponds to one individual. The first two columns correspont to the Individual ID and population respectively. The rest of the columns 
correspond to components within each ADMIXTURE run to be plotted, with `2:1` corresponding the component 1 of the K=2 run, `2:2` the 
second component of that run, `3:1` the first component of the K=3 ADMIXTURE run, etc. 

Example input for K=2 to 5, for 5 individuals:
```
Ind Pop 2:1 2:2 3:1 3:2 3:3 4:1 4:2 4:3 4:4 5:1 5:2 5:3 5:4 5:5
Ind1 Pop1 0.942951 0.057049 0.012524 0.987466 0.000010 0.000010 0.315992 0.683988 0.000010 0.118408 0.881562 0.000010 0.000010 0.000010
Ind2 Pop2 0.914518 0.085482 0.125482 0.006548 0.867970 0.864029 0.000010 0.014720 0.121241 0.000010 0.012874 0.864779 0.000436 0.121901
Ind3 Pop2 0.927737 0.072263 0.107645 0.019653 0.872702 0.867123 0.000010 0.029861 0.103005 0.000010 0.020055 0.867397 0.009572 0.102967
Ind4 Pop2 0.929991 0.070009 0.103765 0.011336 0.884900 0.880428 0.000010 0.019200 0.100363 0.000010 0.010325 0.880608 0.008083 0.100974
Ind5 Pop3 0.933301 0.066699 0.098573 0.011919 0.889508 0.885705 0.000010 0.017836 0.096449 0.000010 0.016165 0.886247 0.001159 0.096418
```

You are also expected to provide the script with a colour definitions file. An example colour definition file is provided at 
`ExampleColourList.txt` that defines a set of colours up to K=20. In the first 21 lines, the colours are being defined. Lines 24-42 
define the corespondance of each colour to each component for each K value. for Example, `clr3` is the colour vector for K=3 and 
specifies that component `3:1` should use colour `c1`, `3:2` should use `c2` and `3:3` should use `c3`. 

`AdmixturePlotter.perK.R` can then be ran by specifying the input data, the colour file and output file name. The output will always be 
in pdf format.

```bash
AdmixturePlotter.perK.R SampleData.input.txt ExampleColourList.txt SamplePlot
```
This will create a figure named **SamplePlot.pdf**.

It is possible to set the order of populations in the resulting plot by using population order list.this should be a text file with all 
plotted populations, one population per line. the path to ths list should be provided as a fourth positional argument. Any populations whose order is not specified in the list, but are part of the datasset, will be plotted in population "NA". This makes it easy to check if your population order list is missing any populations from your dataset. 

```bash
AdmixturePlotter.perK.R SampleData.input.txt ExampleColourList.txt SamplePlot PopOrder.txt
```
