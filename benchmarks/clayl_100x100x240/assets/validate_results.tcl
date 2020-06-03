 # Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*
set runname $::env(runname)
source ../pftest.tcl

set sig_digits 9
set py_test_epsilon 9

set passed 1

if $passed {
    puts "$runname : PASSED"
} {
    puts "$runname : FAILED"
}
