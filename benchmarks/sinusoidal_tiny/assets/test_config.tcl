# configuration file for Parflow test domain


# Load the global configuration
#source ../global_config.tcl

# set the number of runs that will be averaged
set number_of_runs 1

# set the directory where the parflow script will run from
set test_run_dir ./

# Sinusoidal domain configuration
# Replicates Little Washita specified domain configuration
set sinusoidal_NX 41
set sinusoidal_NY 41
set sinusoidal_NZ 50

# set the runname for this test domain
set runname pf_sinusoidal_41x41x50

# define the Parflow run script file
set scriptname sinusoidal_no_size_args.tcl

# set the test's output directory for Parflow outputs
# output dir relative to test_run_dir
set output_dir ./outputs
