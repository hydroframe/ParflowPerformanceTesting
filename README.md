# ParflowPerformanceTesting

[Instructions on how to do github pull of code and/or singularity container]

[Instructions on how to run run-perf-testsuit.sh]

Raw data process
* Once output from parflow simulation has been verified as correct, then do not need to save that.
* Need to save all raw performance data.
* [Need a script that takes raw performance data and creates a master csv file]

Summary csv file format
* [Ask Michael to propose this]
* Not specific to a particular plot, so contains all of the raw performance data.

Plots we forsee needing
* execution time versus time stamp on the commit for all the cores of a node on a particular 
  machine with one series per OpenMP, CUDA, and MPI.  One of these graphs per  (tcl file, forcing data, machine)
* [all plots used in Michael's thesis.  Michael please list here.]

--------------------------------------------

performanceData/
  [people can do pull requests to share their data]
  [each subdirectory is going to have very specific structure, one per pull request?]

runscripts/
  run-perf-testsuit.sh, run some default configuration for all of the benchmarks, will have a
                        usage message that describes how to run the script and how all of the default
                        configurations and parameters were selected

benchmarks/
  tcl files for each benchmark and a parameter handling script if parameterizable
  
  sinusoidal.tcl
  sinusoidal-run.sh
  
