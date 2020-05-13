#!/usr/bin/env tclsh
# Expand command line arguments to individual variables
lassign $argv suite_dir P Q R T

#Get absolute path to the benchmarks directory
set path_to_benchmarks [file dirname [file normalize [info script]]]
set assets_dir [file join $path_to_benchmarks assets]

# absolute path to suite_dir (with no trailing slashes)
set suite_dir [file normalize $suite_dir ]
set suite_assets [file join $suite_dir assets ]
set suite_outputs [file join $suite_dir outputs ]

source [ file join $suite_assets tests.tcl ]
source [ file join $suite_assets test_config.tcl ]

# Timestamp for "uniqueness"
set time_stamp [clock format [clock seconds] -format %m-%d-%y_%H-%M-%S]
set time_stamped_dir [file join $suite_outputs $time_stamp]

# Full paths to framework assets
set test_framework_assets [lmap i [glob -directory $assets_dir * ] {file join $assets_dir $i} ]
# Full paths to suite assets
set test_suite_assets [lmap i [glob -directory [file join $suite_dir assets] * ] { file join $suite_dir $i } ]

# If suite's output directory does not already exist, create it
if { ![file exists $suite_outputs] } {
  file mkdir $suite_outputs
}
# Create (hopefully) unique directory for this execution of the test suite
file mkdir $time_stamped_dir
# Copy all necessary test framework assets
foreach asset [concat $test_framework_assets $test_suite_assets] {
  # Link absolute path to asset to $time_stamped_dir/filename
  # This reduces the amount of replicated data on disk, which can be substantial
  # Assumes that assets are immutable
  file link [file join $time_stamped_dir [file tail $asset]] $asset
  # Previously:
  # file copy -force $asset $time_stamped_dir/.
}

# Delete any existing solver configuration directories (this is now unnecessary)
# Copy appropriate solver configurations
foreach dir $solver_configs {
  file delete -force -- [file join $time_stamped_dir $dir]
  file copy -force [file join solver_configs $dir] [file join $time_stamped_dir $dir]
}

# Move into test directory and execute tests
cd $time_stamped_dir

puts "running"
exec tclsh run_tests.tcl $P $Q $R $T >@stdout
