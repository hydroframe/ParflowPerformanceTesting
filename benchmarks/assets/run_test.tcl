lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

# @IJB This is stupid. I wrote this with 8.6 in mind, but 8.5 doesnt have lmap
if { [info tclversion] < 8.6 } {
  # Shamelessly stolen from https://en.wikibooks.org/wiki/Tcl_Programming/Examples
  proc lmap {_var list body} {
    upvar 1 $_var var
    set res {}
    foreach var $list {lappend res [uplevel 1 $body]}
    set res
  }
}

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

  # Create absolute paths
  # Where the main test directory is, including intially copied assets and case* directories
  set test_root_directory [file normalize [pwd]]
  # Directory where test script is run
  set test_run_dir [file normalize $test_run_dir]
  # The case* directory
  set test_directory [file normalize [ file join $test_run_dir $test_directory]]
  # Directory where output files reside after running test script
  set output_dir [file normalize [file join $test_run_dir $output_dir]]
  # Directory in case* directory where individual trial directories live.
  set test_trials_directory [file join $test_directory trials]

  # Input assets files
  # assets that will need to be moved into the test_dir before running
  set test_dir_assets [concat [file join $test_directory/solver_params.tcl] [lmap file "$scriptname delete_logs.tcl" {file join $test_root_directory $file}]]
  # Assets that will need to be moved into the output_dir after running
  set output_dir_assets [lmap file "pftest.tcl pfbdiff.py validate_results.tcl" {file join $test_root_directory $file}]

  # Output files
  # Files to only copy once
  set per_test_files [lmap extension "out.pftcl out.pfmetadata pfidb" { file join $output_dir [ concat "$runname.$extension" ] }]
  # Files to copy every trial
  set per_trial_files [lmap extension "out.kinsol.log out.log out.timing.csv out.txt" {  file join $output_dir [ concat "$runname.$extension" ] }]

  # Create trials directory
  file mkdir $test_trials_directory

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

  # Copy tests assets
  file copy -force {*}$test_dir_assets $test_run_dir/.

  # run the test
  cd $test_run_dir

  # Setup ParFlow environment
  set ::env(PARFLOW_DIR) $::env(PARFLOW_DIR)
  set ::env(runname) $runname

  # Run multiple trials depending on domain configuration file
  for { set i 1 } { $i <= $number_of_runs } { incr i } {

    # Create trial directory under the test's trials directory
    set trial_directory [file join $test_trials_directory $i]
    file mkdir $trial_directory

    # Execute the test script
    # use time to clock the run externally of parlfow's internal timing
    exec /usr/bin/time --verbose tclsh $scriptname $P $Q $R $T >& [file join $trial_directory run_time.log]

    # Copy output assets
    file copy -force {*}$output_dir_assets $output_dir

    cd $output_dir

    # Validate
    exec tclsh validate_results.tcl >& $trial_directory/validation.log
    cd $test_run_dir

    # Copy the output files of interest back for logging.
    file copy -force {*}$per_trial_files $trial_directory

    # copy hpctoolkit directory if it exists
    set hpc_toolkit_outputs [glob -nocomplain [file join $output_dir hpctoolkit]*]
    if { [llength $hpc_toolkit_outputs] > 0 } {
      file copy -force {*}$hpc_toolkit_outputs $trial_directory
    }

    if { $i == 1 } {
      # Copy the parflow databases and metadata settings for this run back for logging.
      # Unnecessary to copy on a per-trial basis. Only do on first trial.
      # Note, done in here so that outputs directory can be deleted after each
      # run
      file copy -force {*}$per_test_files $test_directory

      # if hpctoolkit stuff exists, create and copy hpcstruct file for this configuration
      if { [llength $hpc_toolkit_outputs] > 0 } {
        set parflow_path [file join $Parflow::PARFLOW_DIR bin parflow]
        set hpcstruct_file [file join $test_directory parflow.hpcstruct]

        exec hpcstruct $parflow_path -o $hpcstruct_file >&@stdout

        if { ! [file exists $hpcstruct_file] } {
          puts "Could not create hpcstruct file"
        }
      }
    }

    # Delete outputs directory at the end of the trial
    file delete -force $output_dir
  }

  cd $test_root_directory
}

# for calling script from command line
if { $argc == 5 } {
  lassign $argv test_directory P Q R T
  set test_path [file join [pwd] $test_directory]
  run_test $test_path $P $Q $R $T
}
