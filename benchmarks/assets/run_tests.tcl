#*************************************
#
# run all the tests in the subfolders of this directory.
# assumes Parflow installed and accessible from $PARFLOW_DIR
# assumes parflow/test/washita/tcl_scripts accessible with properly distributed NLDAS data.
# assumes any other domain with NLDAS data has already been properly distributed
# before running this script.
#
# usage: $ tclsh run_tests.tcl <path_to_test_run_dir> <P> <Q> <R> <T>
# where P Q R are the Process.Topology values for the Parflow script
# and T is the number of timesteps to run for
# ex: $ tclsh run_tests.tcl /home/user/pfdir/parflow/test/washita/tcl_scripts 2 2 1 72
#
#*************************************
lappend   auto_path $env(PARFLOW_DIR)/bin
source run_test.tcl
source test_config.tcl

lassign $argv P Q R T

# Collect case* directories
set case_dirs [lsort [glob -nocomplain -type d case*]]

# Foreach test run test in that directory
if { [llength $case_dirs] > 0 } {
    puts "Running tests..."
    foreach dir $case_dirs {
        puts "  - Running $dir"
        # Set pat to test directory and run test
        set test_path [file normalize $dir]
        run_test $test_path $P  $Q  $R $T
    }
    puts "Finished tests."
} else {
  puts "No tests to run."
}

# collect the stats from the run
exec tclsh collect_stats.tcl >@stdout
