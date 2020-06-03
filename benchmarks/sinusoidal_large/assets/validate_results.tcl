 # Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*
set runname $::env(runname)
source ../pftest.tcl

set sig_digits 9
set py_test_epsilon 9

set passed 1

# TODO add validation.
# PS: When adding validation, make sure to turn on outputs in the run script

if $passed {
    puts "$runname : PASSED"
} {
    puts "$runname : FAILED"
}
