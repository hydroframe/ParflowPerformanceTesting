# configuration file for Parflow test domain


# set the number of runs that will be averaged
set number_of_runs 1

# set the directory where the parflow script will run from
set test_run_dir ./

# set the runname for this test domain
set runname snake_river

# define the Parflow run script file
set scriptname snake_river.tcl

# mirror the test's output directory for Parflow outputs
# output dir relative to test_run_dir
# TODO: This should not be mirrored, only set once!
set output_dir ./outputs
