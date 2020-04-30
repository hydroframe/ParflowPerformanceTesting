lassign $argv suite_dir P Q R T

file copy -force run_test.tcl $suite_dir/.
file copy -force run_tests.tcl $suite_dir/.
file copy -force collect_stats.tcl $suite_dir/.
file copy -force pftest.tcl $suite_dir/.

source $suite_dir/tests.tcl

foreach dir $solver_configs {
	file delete -force -- $suite_dir/$dir
	file copy -force solver_configs/$dir $suite_dir/$dir
}

cd $suite_dir

exec tclsh run_tests.tcl $P $Q $R $T
