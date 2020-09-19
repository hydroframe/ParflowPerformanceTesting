
set tcl_precision 17

set runname SnakeRiverShape

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

set StartTime 0
set StopTime 10

lassign $argv runname StartTime StopTime
 
pfundist [append xslope $runname "_Str3Ep0_smth.rvth_1500.mx0.5.mn5.sec0.up_slopex.pfb"]
pfundist [append yslope $runname "_Str3Ep0_smth.rvth_1500.mx0.5.mn5.sec0.up_slopey.pfb"]
pfundist [append pme_file $runname "_PME.pfb"]
pfundist [append indicator_file $runname "_3d-grid.v3.pfb"]

pfundist $runname.out.specific_storage.pfb
pfundist $runname.out.perm_x.pfb
pfundist $runname.out.perm_y.pfb
pfundist $runname.out.perm_z.pfb
pfundist $runname.out.porosity.pfb
pfundist $runname.out.mask.pfb

#possible soil vars
# satur press obf et
set var [list "satur" "press"] 
set clm [list "eflx_lh_tot" "qflx_evap_soi" "swe_out" "eflx_lwrad_out" "qflx_evap_tot" "t_grnd" "eflx_sh_tot" "qflx_evap_veg" "t_soil" "eflx_soil_grnd" "qflx_infl" "qflx_evap_grnd" "qflx_tran_veg" ]
 for {set i $StartTime} { $i <= $StopTime } {incr i} { 
  set step [format "%05d" $i]
    foreach clm_var $clm {
        pfundist $runname.out.$clm_var.$step.pfb
    }
	foreach soil_var $var {
		pfundist $runname.out.$soil_var.$step.pfb
	}
}
 # for {set i $StartTime} { $i <= $StopTime } {incr i} {
  # set step [format "%05d" $i]
 # pfundist $runname.out.satur.$step.pfb
  # pfundist $runname.out.press.$step.pfb
 # pfundist $runname.out.obf.$step.pfb
 # pfundist $runname.out.et.$step.pfb
   # pfundist $runname.out.clm_output.$step.C.pfb
   # pfundist clm.rst.$step 
# }
