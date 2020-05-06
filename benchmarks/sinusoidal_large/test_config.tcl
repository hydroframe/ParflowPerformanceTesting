# configuration file for Parflow test domain


# Load the global configuration
#source ../global_config.tcl

# set the number of runs that will be averaged
set number_of_runs 1

# set the directory where the parflow script will run from
set test_run_dir ./

# Sinusoidal domain configuration
# Expected to fill approximately 151 GiB (approximately 162353643520 bytes)
set sinusoidal_NX 4500
set sinusoidal_NY 5239
set sinusoidal_NZ 5

# set the runname for this test domain
set runname pf_sinusoidal_4500x5239x5

# define the Parflow run script file
set scriptname sinusoidal_no_size_args.tcl

# set the test's output directory for Parflow outputs
# output dir relative to test_run_dir
set output_dir ./outputs
