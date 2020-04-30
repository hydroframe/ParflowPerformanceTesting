#
# run parflow script with test specific solver settings#
#
proc run_test { test_directory P Q R T } {
    # test_directory - directory where solver settings stored
    # P - Processor count for X
	# Q - Processor count for Y
	# R - Processor count for Z
	# T - # of time steps to run simulation for
	#
  
  # get the test configuration file for the domain
  source test_config.tcl
  
  # copy the parflow test,  solver config, diff compare, and validation
  # scripts to the run directory
  file copy -force $scriptname $test_run_dir/.
  file copy -force $test_directory/solver_params.tcl $test_run_dir/.
  file copy -force ../pfbdiff.py $test_run_dir/.
  file copy -force validate_results.tcl $test_run_dir/.
  file copy -force ../delete_logs.tcl $test_run_dir/.
  
  # write a log file to the $test_directory
  # include Date/Time of run, number of runs, PQR, machine name, mem and cpu data
  set systemTime [clock seconds]
  set hostName [exec cat /proc/sys/kernel/hostname]
  set cpuInfo [exec cat /proc/cpuinfo]
  set memInfo [exec cat /proc/meminfo]
  set output_file [open $test_directory/test_case.log w]
  puts -nonewline $output_file "Test Started: " 
  puts $output_file [clock format $systemTime -format { %D %T }]
  puts $output_file "Test Run Count: $number_of_runs"
  puts $output_file "Test Configuration: $P $Q $R"
  puts $output_file "MachineName: $hostName"
  puts $output_file "CPU Info: $cpuInfo"
  puts $output_file "Mem Info: $memInfo"
  close $output_file 


  # run the test
  cd $test_run_dir
  set ::env(PARFLOW_DIR) $::env(PARFLOW_DIR)
  set ::env(runname) $runname
  file delete $test_directory/time.log 
  # generate multiple runs depending on domain configuration file
  for { set i 1 } { $i <= $number_of_runs } { incr i } { 
	# use time to clock the run externally of parlfow's internal timing  
	exec /usr/bin/time --verbose tclsh $scriptname $P $Q $R $T >& $test_directory/run_time_$i.log
    file copy -force validate_results.tcl $output_dir/.
    set cwd [pwd]
    cd $output_dir
    exec tclsh validate_results.tcl >& $test_directory/validation_$i.log    
    # copy the results files back for logging
	file copy -force "$runname.out.kinsol.log" $test_directory/$runname.out.kinsol.log.$i 
    file copy -force "$runname.out.log" $test_directory/$runname.out.log.$i    
    file copy -force "$runname.out.timing.csv" $test_directory/$runname.out.timing.csv.$i    
    cd $cwd
  }
  puts [pwd]
  # copy the parflow db settings for this run back for logging
  file copy -force "$output_dir/$runname.out.pftcl" $test_directory/.  
  
  file delete -force $output_dir/pfbdiff.py
  if { [file exists $output_dir/validate_results.tcl] == 1 } {
    file delete -force $output_dir/validate_results.tcl
   }
}

# for calling script from command line
if { $argc == 5 } {  
  lassign $argv a P Q R T
  set test_path [file join [pwd] $a]
  run_test $test_path $P $Q $R $T  
}
