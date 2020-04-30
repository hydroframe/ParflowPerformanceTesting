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

set P [lindex $argv 0]
set Q [lindex $argv 1]
set R [lindex $argv 2]
set T [lindex $argv 3]

set dirs [glob -nocomplain -type d *]

if { [llength $dirs] > 0 } {
    puts "Running Tests..."    
    foreach dir [lsearch -inline -all [lsort $dirs]  "case*"] {	
       set current_dir [pwd]
       set test_path [file join $current_dir $dir]
       run_test $test_path $P  $Q  $R $T
       cd $current_dir 
    }
}
puts "Finished Tests"
# collect the stats from the run
exec tclsh collect_stats.tcl
