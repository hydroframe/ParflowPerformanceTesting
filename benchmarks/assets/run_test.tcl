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
  file copy -force pfbdiff.py $test_run_dir/.
  file copy -force validate_results.tcl $test_run_dir/.
  file copy -force delete_logs.tcl $test_run_dir/.

  # write a log file to the $test_directory
  # include Date/Time of run, number of runs, PQR, machine name, mem and cpu data
  set systemTime [clock seconds]
  set hostName [exec cat /proc/sys/kernel/hostname]
  set cpuInfo [exec cat /proc/cpuinfo]
  set memInfo [exec cat /proc/meminfo]
  set env [exec env]
  set time_stamp [clock format $systemTime -format { %D %T }]

  set output_file [open $test_directory/test_case.log w]
  puts $output_file "Test Started: $time_stamp\n"
  puts $output_file "Test Run Count: $number_of_runs\n"
  puts $output_file "Test Configuration: $P $Q $R\n"
  puts $output_file "MachineName: $hostName\n"
  puts $output_file "CPU Info: $cpuInfo\n"
  puts $output_file "Mem Info: $memInfo\n"
  puts $output_file "Environment:\n$env\n"
  close $output_file

  # Create trials directory
  set test_trials_directory [file join $test_directory trials]
  file mkdir $test_trials_directory

  # Files to copy every trial
  set per_trial_files [lmap extension "out.kinsol.log out.log out.timing.csv out.txt" {file normalize [file join $output_dir [concat "$runname.$extension"]]}]
  # Files to only copy once
  set per_test_files [lmap extension "out.pftcl out.pfmetadata pfidb" {file normalize [file join $output_dir [concat "$runname.$extension"]]}]

  # run the test
  cd $test_run_dir

  # Setup ParFlow environment
  set ::env(PARFLOW_DIR) $::env(PARFLOW_DIR)
  set ::env(runname) $runname

  # Run multiple trials depending on domain configuration file
  for { set i 1 } { $i <= $number_of_runs } { incr i } {

    # Create trial directory under the test's trials directory
    set trial_dir [file join $test_trials_directory $i]
    file mkdir $trial_dir

    # Execute the test script
    # use time to clock the run externally of parlfow's internal timing
    exec /usr/bin/time --verbose tclsh $scriptname $P $Q $R $T >& [file join $trial_dir run_time.log]

    # Validate outputs and copy outputs
    file copy -force validate_results.tcl $output_dir

    set current_directory [pwd]
    cd $output_dir

    # Validate
    exec tclsh validate_results.tcl >& $trial_dir/validation.log

    cd $current_directory

    # Copy the output files of interest back for logging.
    file copy -force {*}$per_trial_files $trial_dir

    if { $i == 1 } {
      # Copy the parflow databases and metadata settings for this run back for logging.
      # Unnecessary to copy on a per-trial basis. Only do on first trial.
      # Note, done in here so that outputs directory can be deleted after each
      # run
      file copy -force {*}$per_test_files $test_directory
    }

    # Delete outputs directory at the end of the trial
    file delete -force $output_dir
  }
}

# for calling script from command line
if { $argc == 5 } {
  lassign $argv test_dir P Q R T
  set test_path [file join [pwd] $test_dir]
  run_test $test_path $P $Q $R $T
}
