# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


#set tcl_precision 16

#-----------------------------------------------------------------------------
# File input version number
#-----------------------------------------------------------------------------
pfset FileVersion 4

#-----------------------------------------------------------------------------
# Process Topology
#-----------------------------------------------------------------------------

pfset Process.Topology.P        [lindex $argv 0]
pfset Process.Topology.Q        [lindex $argv 1]
pfset Process.Topology.R        [lindex $argv 2]

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X                0.0
pfset ComputationalGrid.Lower.Y                0.0
pfset ComputationalGrid.Lower.Z                0.0

pfset ComputationalGrid.DX                      1000.0
pfset ComputationalGrid.DY                      1000.0
pfset ComputationalGrid.DZ                       20.0

pfset ComputationalGrid.NX                      41
pfset ComputationalGrid.NY                      41
pfset ComputationalGrid.NZ                      24

set name NLDAS
set var [list "APCP" "DLWR" "DSWR" "Press" "SPFH" "Temp" "UGRD" "VGRD"]

set end 0 
  for {set i 0} {$i <= $end} {incr i} {
     foreach v $var {
      set t1 [expr $i * 24 + 1]
      set t2 [ expr $t1 + 23]
      puts $t1
      puts $t2
     set filename [format "../NLDAS/%s.%s.%06d_to_%06d.pfb" $name $v $t1 $t2]
     puts $filename
    pfdist $filename
    # pfundist $filename
}
}
