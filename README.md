# AdmixturePlotter
An set of scripts to generate plots for ADMIXTURE runs, for multiple K values. 

# CompileData.sh
This is an example script for compiling the data from multiple K runs and replicates into the input formats for `CVErrorBoxplotPlotter.R` and `AdmixturePlotter.R`.

`CompileData.sh` assumes a folder structure of `OUTPUT_FOLDER/K_Value/Replicate_Number/Result.Q` with a `Logs` folder within each `K_Value` folder, which contains the logfile of all replicates from the admixture runs of that K. In turn these logfiles should be named `<K_Value>_<Replicate_Number>.log`. Given that structure, one should copy and edit the script to include their own paths to their bed format data, the Eigenstrat individual file of the dataset, and the range of K values admixture was ran for. The script can then be ran to produce the correct format of data.

Example directory structure within output folder, for a run of 5 replicates with K=3-4:
```bash
/PATH/TO/MY/ADMIXTURE/OUTPUT/ $ ls -l *
2:	## The K value for the admixture runs
total 0
drwxrwsr-x 2 user group 4.0K Sep  1  2018 1/	## Output for K=2 run replicate 1
drwxrwsr-x 2 user group 4.0K Sep  1  2018 2/	## Output for K=2 run replicate 2
drwxrwsr-x 2 user group 4.0K Sep  1  2018 3/	## Output for K=2 run replicate 3
drwxrwsr-x 2 user group 4.0K Sep  1  2018 4/	## Output for K=2 run replicate 4
drwxrwsr-x 2 user group 4.0K Sep  1  2018 5/	## Output for K=2 run replicate 5
drwxrwsr-x 2 user group 4.0K Sep  1  2018 Logs/	## The logfiles from all replicates with this K value go in here.

3:	## The K value for the admixture runs
total 0
drwxrwsr-x 2 user group 4.0K Sep  1  2018 1/	## Output for K=3 run replicate 1
drwxrwsr-x 2 user group 4.0K Sep  1  2018 2/	## Output for K=3 run replicate 2
drwxrwsr-x 2 user group 4.0K Sep  1  2018 3/	## Output for K=3 run replicate 3
drwxrwsr-x 2 user group 4.0K Sep  1  2018 4/	## Output for K=3 run replicate 4
drwxrwsr-x 2 user group 4.0K Sep  1  2018 5/	## Output for K=3 run replicate 5
drwxrwsr-x 2 user group 4.0K Sep  1  2018 Logs/	## The logfiles from all replicates with this K value go in here.

4:	## The K value for the admixture runs
total 0
drwxrwsr-x 2 user group 4.0K Sep  1  2018 1/	## Output for K=4 run replicate 1
drwxrwsr-x 2 user group 4.0K Sep  1  2018 2/	## Output for K=4 run replicate 2
drwxrwsr-x 2 user group 4.0K Sep  1  2018 3/	## Output for K=4 run replicate 3
drwxrwsr-x 2 user group 4.0K Sep  1  2018 4/	## Output for K=4 run replicate 4
drwxrwsr-x 2 user group 4.0K Sep  1  2018 5/	## Output for K=4 run replicate 5
drwxrwsr-x 2 user group 4.0K Sep  1  2018 Logs/	## The logfiles from all replicates with this K value go in here.
```

And within each K result folder:
```bash
/PATH/TO/MY/ADMIXTURE/OUTPUT/ $ cd 2

/PATH/TO/MY/ADMIXTURE/OUTPUT/2 $ ls -l *
## These are the contents of each subfolder of the K2 runs.
1:	## Output for K=2 run replicate 1
total 7.7M
-rw-rw-r-- 1 user group 3.8M Sep  1  2018 Admixture.Output.2.P
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q
-rw-rw-r-- 1 user group  18K Sep  1  2018 Admixture.Output.2.Q_bias
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q_se

2:	## Output for K=2 run replicate 2
total 7.7M
-rw-rw-r-- 1 user group 3.8M Sep  1  2018 Admixture.Output.2.P
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q
-rw-rw-r-- 1 user group  18K Sep  1  2018 Admixture.Output.2.Q_bias
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q_se

3:	## Output for K=2 run replicate 3
total 7.7M
-rw-rw-r-- 1 user group 3.8M Sep  1  2018 Admixture.Output.2.P
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q
-rw-rw-r-- 1 user group  18K Sep  1  2018 Admixture.Output.2.Q_bias
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q_se

4:	## Output for K=2 run replicate 4
total 7.7M
-rw-rw-r-- 1 user group 3.8M Sep  1  2018 Admixture.Output.2.P
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q
-rw-rw-r-- 1 user group  18K Sep  1  2018 Admixture.Output.2.Q_bias
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q_se

5:	## Output for K=2 run replicate 5
total 7.7M
-rw-rw-r-- 1 user group 3.8M Sep  1  2018 Admixture.Output.2.P
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q
-rw-rw-r-- 1 user group  18K Sep  1  2018 Admixture.Output.2.Q_bias
-rw-rw-r-- 1 user group  17K Sep  1  2018 Admixture.Output.2.Q_se

Logs:	## The logfiles from all replicates with this K value go in here. 
total 320K
-rw-rw-r-- 1 user group 30K Sep  1  2018 K2_1.log	## Logfile of K=2 run, replicate 1.
-rw-rw-r-- 1 user group 30K Sep  1  2018 K2_2.log	## Logfile of K=2 run, replicate 2.
-rw-rw-r-- 1 user group 30K Sep  1  2018 K2_3.log	## Logfile of K=2 run, replicate 3.
-rw-rw-r-- 1 user group 30K Sep  1  2018 K2_4.log	## Logfile of K=2 run, replicate 4.
-rw-rw-r-- 1 user group 30K Sep  1  2018 K2_5.log	## Logfile of K=2 run, replicate 5.
```

If your folder structure does not follow this system, looking into the code is a good starting point for the commands that can be used to create the desired data.

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

# AdmixturePlotter.R
This is a script to plot ADMIXTURE output for multiple K values. It uses a correlation matrix between different components across
sequential K values to (attempt to) correctly assign consistent colours across Ks. The expected input file is a space separated compound 
dataset of all the results per component per K, with labelling of individual and population name. Once again, a header is expected. Each 
line correctponds to one individual. The first two columns correspont to the Individual ID and population respectively. The rest of the 
columns correspond to components within each ADMIXTURE run to be plotted, with `2:1` corresponding the component 1 of the K=2 run, `2:2` the second component of that run, `3:1` the first component of the K=3 ADMIXTURE run, etc. 

Example input for K=2 to 5, for 5 individuals:
```
Ind Pop 2:1 2:2 3:1 3:2 3:3 4:1 4:2 4:3 4:4 5:1 5:2 5:3 5:4 5:5
Ind1 Pop1 0.942951 0.057049 0.012524 0.987466 0.000010 0.000010 0.315992 0.683988 0.000010 0.118408 0.881562 0.000010 0.000010 0.000010
Ind2 Pop2 0.914518 0.085482 0.125482 0.006548 0.867970 0.864029 0.000010 0.014720 0.121241 0.000010 0.012874 0.864779 0.000436 0.121901
Ind3 Pop2 0.927737 0.072263 0.107645 0.019653 0.872702 0.867123 0.000010 0.029861 0.103005 0.000010 0.020055 0.867397 0.009572 0.102967
Ind4 Pop2 0.929991 0.070009 0.103765 0.011336 0.884900 0.880428 0.000010 0.019200 0.100363 0.000010 0.010325 0.880608 0.008083 0.100974
Ind5 Pop3 0.933301 0.066699 0.098573 0.011919 0.889508 0.885705 0.000010 0.017836 0.096449 0.000010 0.016165 0.886247 0.001159 0.096418
```

`AdmixturePlotter.R` comes with a number of options. Usage information and helptext is shown when the script is provided with the `-h` option.
```
  Usage: ./AdmixturePlotter.R [options]


Options:
	-h, --help
		Show this help message and exit

	-i INPUT, --input=INPUT
		The input data file. This file should contain all components per K per indiviual for all K values.

	-c COLOURLIST, --colourList=COLOURLIST
		A file of desired colours, in R compatible formats. One colour per line.

	-p POPORDER, --popOrder=POPORDER
		A file containing one population per line in the desired order.

	-o OUTPUTPLOT, --outputPlot=OUTPUTPLOT
		The desired name of the output plot. [Default: 'OutputPlot.pdf']

	-r, --remove
		If an order list is provided, should populations not in the list be removed from the output plot?
                     Not recommended for final figures, but can help in cases where you are trying to focus on a certain subset of your populations.
```
`AdmixturePlotter.R` can be ran by specifying the input data alone. The output will always be in pdf format, and will be named according to the provided `-o/--outputPlot` option. If neither of the two options is provided, the resulting figure will be named `OutputPlot.pdf`.

You can provide the script with a colour definitions file with the `-c/--colourList` option. An example colour definition file is provided at `ExampleColourList.txt` that defines a set of colours up to K=20 (Colour source: Haak et al. 2015, Figure S6.3). 

When no colour list is provided, the script will use the R function `rainbow()` to create an appropriate number of colours for assignment. Be warned that with large maximum K values, this may result in components being assigned colours that are visually similar to each other. 

It is possible to set the order of populations in the resulting plot by using population order list. This should be a text file with all 
plotted populations, one population per line. The path to this list should be provided using the `-p/--popOrder`. Any populations whose order is not specified in the list, but are part of the dataset, will be plotted in population "NA" at the right end of the plot. This makes it easy to check if your population order list is missing any populations from your dataset.

In cases where you are trying to plot only a subset of your dataset, you can set a population order list that contains all the populations you wish to include in your plot (in the desired order) in addition to the `-r/--remove` option.

```bash
AdmixturePlotter.R -i SampleData.input.txt -c ExampleColourList.txt -o SamplePlot -p PopOrder.txt [-r]
```

The colours provided in the colour list are appointed to components by index, so it possible to change a specific colour in the output by changing the colour definition of that specific colour in the colour list.

# Troubleshooting
If you run into problems or get unexpected results, please contact the author of this script, or submit an issue via GitHub.
