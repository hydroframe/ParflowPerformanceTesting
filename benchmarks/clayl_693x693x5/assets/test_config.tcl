# configuration file for Parflow test domain

# set the number of runs that will be averaged
set number_of_runs 1

# set the directory where the parflow script will run from
set test_run_dir ./

# set the runname for this test domain
set runname pf_clayl

# define the Parflow run script file
set scriptname clayl_fixed_size.tcl

# mirror the test's output directory for Parflow outputs
# output dir relative to test_run_dir
set output_dir ./outputs

# ClayL domain configuration
set clayl_NX 693
set clayl_NY 693
set clayl_NZ 5
