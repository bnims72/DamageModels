README.txt for an automated stress-relaxation module in Matlab, FEBio, and Python

1: Generate the geometry models and optimization models for FEBio. This is performed in MATLAB.
Open the file multifile_run.m.  This file should be adapted for your files such that the sample diameters, heights, and srldisplacements are entered for each sample initially in the first three vectors of the file. 
The complete path to the SRL files and the path to the SRL containing folder (str and path files, respectively), should be edited for each of the files to be run. Also change the "for-loops" to ensure i = the number of files to be run.

Special care should be taken to ensure spaces do not appear in the file paths, as different programs in this routine have different methods to handle the spaces.

Run multifile_run.m in MATLAB by entering "multifile_run" in the command window.

2.  The geometric models and optimization models have been created.  The next step is to run the optimization files.  In the file runner_toppaths.py the module sb.call will execute the arguements.  
The first arguement (variable 'path_to_FEBio') should be the complete path to the FEBio-1/febio.osx (on mac) executable. The second arguement ("-s") indicates that we are doing an optimization. 
The final arguement (a vector with all of the different paths which contain samples) is the complete path to the optimization file (PATH_for_SAMPLE/TEMPLATE_opt.feb).
Finally, the 'samples_pergroup' variable should also be altered for the total number of samples within the groups.

This program creates a file, filesrun.dat, which can be viewed after the program completes and will indicate in this file whether the program had converged ("normal") or failed to converge ("fail") for each model.
A second file is created, file.dat, which will contain the final values for the optimization parameters ksi, E, perm.

Run runner_toppaths.py in the terminal by entering "python runner_toppaths" in the terminal directory containing the program.

3. To visualize the results use the program reader.py.  Like the former program, the input includes the full path directories for the sample groups ("files" variable vector) and the number of samples per grous ("samples_pergroup" variable).

This program requires matplotlib module for plotting the results (http://matplotlib.org/downloads.html). 
You can check whether your computer already has this modulus by opening the terminal, and typing "python".  In python, type "import matplotlib.pyplot".  If this command does not elicit an error, you already have matplotlib installed.  

As each figure is generated you will need to close the figure to proceed to the next figure.  

4. To use the editor module enter “python editor.py” in the terminal.
The program will prompt you to enter the sample numbers (in the order they were initially processed) which you wish to alter (because they originally failed or produced poor fits as assessed in reader.py).
This prompt will continue until you enter a “0” once you have entered all the sample numbers you wish to reprocesses.  The program will then go through each of the optimization files and display the current parameter selections and ask for, for each sample file, to enter a new initial guess, minimum bound, and maximum bound.
Once this has been updated for all the samples, they will be reprocessed and their data will be saved in the file.dat and filesrun.dat files where you can see whether the files converged and the optimized parameters, respectively.  



 
