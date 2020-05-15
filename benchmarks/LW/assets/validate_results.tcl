 # Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*
set runname $::env(runname)
source pftest.tcl

set sig_digits 9
set py_test_epsilon 9

set passed 1


if ![pftestFile $runname.out.press.00000.pfb "Max difference in Pressure" $sig_digits] {
    set passed 0
}

set status [catch { exec python3 pfbdiff.py -q -e=1e-$py_test_epsilon $runname.out.press.00000.pfb ./correct_output/$runname.out.press.00000.pfb } result]
if { $status != 0 } {
  set passed 0
  puts $result
}

if ![pftestFile $runname.out.satur.00000.pfb "Max difference in Saturation" $sig_digits] {
    set passed 0
}

set status [catch { exec python3 pfbdiff.py -q -e=1e-$py_test_epsilon ./$runname.out.satur.00000.pfb ./correct_output/$runname.out.satur.00000.pfb } result]
if { $status != 0 } {
  set passed 0
  puts $result
}

foreach file "LW.out.eflx_lh_tot.00012.pfb
    LW.out.qflx_evap_soi.00012.pfb LW.out.swe_out.00012.pfb
    LW.out.eflx_lwrad_out.00012.pfb LW.out.qflx_evap_tot.00012.pfb
    LW.out.t_grnd.00012.pfb LW.out.eflx_sh_tot.00012.pfb
    LW.out.qflx_evap_veg.00012.pfb LW.out.t_soil.00012.pfb
    LW.out.eflx_soil_grnd.00012.pfb LW.out.qflx_infl.00012.pfb
    LW.out.qflx_evap_grnd.00012.pfb LW.out.qflx_tran_veg.00012.pfb" {

    if ![pftestFile $file "Max difference in $file" $sig_digits] {
    set passed 0
    }

    set status [catch { exec python3 pfbdiff.py -q -e=1e-$py_test_epsilon $file correct_output/$file  } result]
    if { $status != 0 } {
      set passed 0
      puts $result
    }

}

if $passed {
    puts "$runname : PASSED"
} {
    puts "$runname : FAILED"
}
