#  This runs the tilted-v catchment problem
#  similar to that in Kollet and Maxwell (2006) AWR

set tcl_precision 17

set runname conus_tfg
#set runname CONUS_tfg.cpu

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

pfset FileVersion 4

source solver_params.tcl

#-----------------------------------------------------------------------------
# StopTime Options (12.0 72.0 120.0)
#-----------------------------------------------------------------------------
set StopTime [lindex $argv 3]

#-----------------------------------------------------------------------------
# Set Processor topology 
#-----------------------------------------------------------------------------
pfset Process.Topology.P        [lindex $argv 0]
pfset Process.Topology.Q        [lindex $argv 1]
pfset Process.Topology.R        [lindex $argv 2]

# if {$argc > 2} {
# 	set XProc [lindex $argv 0]
# 	set YProc [lindex $argv 1]
# 	set ZProc [lindex $argv 2]
# } else {
# 	set XProc 1
# 	set YProc 1
# 	set ZProc 1
# }

# if {$argc == 4} {
# 	set DO_RUN 1
# } else {
# 	set DO_RUN 0
# }

# pfset Process.Topology.P $XProc
# pfset Process.Topology.Q $YProc
# pfset Process.Topology.R $ZProc

set slopenamex slopex.trim2
set slopenamey slopey.trim2

file mkdir "outputs"
cd "./outputs"
file copy -force "../$slopenamex.pfb" .
file copy -force "../$slopenamey.pfb" .

#---------------------------------------------------------
# Computational Grid
#---------------------------------------------------------
pfset ComputationalGrid.Lower.X          25000.0
pfset ComputationalGrid.Lower.Y          25000.0
pfset ComputationalGrid.Lower.X          0.0
pfset ComputationalGrid.Lower.Y          0.0
pfset ComputationalGrid.Lower.Z           0.0


pfset ComputationalGrid.NX                750
pfset ComputationalGrid.NY                750
pfset ComputationalGrid.NZ                2

pfset ComputationalGrid.DX	             1000.0
pfset ComputationalGrid.DY               1000.0
pfset ComputationalGrid.DZ	             100.0

#---------------------------------------------------------
# The Names of the GeomInputs
#---------------------------------------------------------
pfset GeomInput.Names                 "domaininput"

pfset GeomInput.domaininput.GeomName  domain
pfset GeomInput.domaininput.InputType  Box

pfset Geom.domain.Lower.X                        0.0
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                        0.0

pfset Geom.domain.Upper.X                        750000.0
pfset Geom.domain.Upper.Y                        750000.0
pfset Geom.domain.Upper.Z                        200.0
pfset Geom.domain.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"




#--------------------------------------------
# variable dz assignments
#------------------------------------------
pfset Solver.Nonlinear.VariableDz   True
pfset dzScale.GeomNames            domain
pfset dzScale.Type            nzList
pfset dzScale.nzListNumber       2
pfset Cell.0.dzScale.Value 1.0
pfset Cell.1.dzScale.Value 0.01

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names                 "domain"


pfset Geom.domain.Perm.Type            Constant
pfset Geom.domain.Perm.Value           10.0

pfset Perm.TensorType               TensorByGeom

pfset Geom.Perm.TensorByGeom.Names  "domain"

pfset Geom.domain.Perm.TensorValX  1.0d0
pfset Geom.domain.Perm.TensorValY  1.0d0
pfset Geom.domain.Perm.TensorValZ  1.0d0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------

pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       "domain"
pfset Geom.domain.SpecificStorage.Value 1.0e-4

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names "water"

pfset Phase.water.Density.Type	        Constant
pfset Phase.water.Density.Value	        1.0

pfset Phase.water.Viscosity.Type	Constant
pfset Phase.water.Viscosity.Value	1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------

pfset Contaminants.Names			""

#-----------------------------------------------------------------------------
# Retardation
#-----------------------------------------------------------------------------

pfset Geom.Retardation.GeomNames           ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity				1.0

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------

#
pfset TimingInfo.BaseUnit        100000.
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        100000.
#pfset TimingInfo.StopTime        $StopTime
pfset TimingInfo.DumpInterval    100000.
pfset TimeStep.Type              Constant
pfset TimeStep.Value             100000.

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

pfset Geom.Porosity.GeomNames          "domain"

pfset Geom.domain.Porosity.Type          Constant
pfset Geom.domain.Porosity.Value         0.3

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName domain

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------

pfset Phase.RelPerm.Type               VanGenuchten
pfset Phase.RelPerm.GeomNames          "domain"

pfset Geom.domain.RelPerm.Alpha         1.0
pfset Geom.domain.RelPerm.N             2.

#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

pfset Phase.Saturation.Type              VanGenuchten
pfset Phase.Saturation.GeomNames         "domain"

pfset Geom.domain.Saturation.Alpha        1.0
pfset Geom.domain.Saturation.N            2.
pfset Geom.domain.Saturation.SRes         0.2
pfset Geom.domain.Saturation.SSat         1.0



#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                           ""

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names "constant"
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      1
pfset Cycle.constant.Repeat             -1



#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   "land top  bottom"

#no flow boundaries for the land borders and the bottom
pfset Patch.land.BCPressure.Type		      FluxConst
pfset Patch.land.BCPressure.Cycle		      "constant"
pfset Patch.land.BCPressure.alltime.Value	      0.0

pfset Patch.bottom.BCPressure.Type		      FluxConst
pfset Patch.bottom.BCPressure.Cycle		      "constant"
pfset Patch.bottom.BCPressure.alltime.Value	      0.0


## overland flow boundary condition with rainfall then nothing
pfset Patch.top.BCPressure.Type		      OverlandKinematic
#pfset Patch.top.BCPressure.Type		      OverlandDiffusive
pfset Patch.top.BCPressure.Type		      SeepageFace

#pfset Patch.top.BCPressure.Type		      FluxConst

pfset Patch.top.BCPressure.Cycle		      "constant"
pfset Patch.top.BCPressure.alltime.Value	      0.0
pfset Patch.top.BCPressure.rec.Value	      0.0000

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]

pfset Patch.x-lower.BCPressure.Type                   FluxConst
pfset Patch.x-lower.BCPressure.Cycle                  "constant"
pfset Patch.x-lower.BCPressure.alltime.Value          0.0

pfset Patch.y-lower.BCPressure.Type                   FluxConst
pfset Patch.y-lower.BCPressure.Cycle                  "constant"
pfset Patch.y-lower.BCPressure.alltime.Value          0.0

pfset Patch.z-lower.BCPressure.Type                   FluxConst
pfset Patch.z-lower.BCPressure.Cycle                  "constant"
pfset Patch.z-lower.BCPressure.alltime.Value           0.0

pfset Patch.x-upper.BCPressure.Type                   FluxConst
pfset Patch.x-upper.BCPressure.Cycle                  "constant"
pfset Patch.x-upper.BCPressure.alltime.Value          0.0

pfset Patch.y-upper.BCPressure.Type                   FluxConst
pfset Patch.y-upper.BCPressure.Cycle                  "constant"
pfset Patch.y-upper.BCPressure.alltime.Value          0.0

pfset Patch.z-upper.BCPressure.Type                   SeepageFace
pfset Patch.z-upper.BCPressure.Cycle                  "constant"
pfset Patch.z-upper.BCPressure.alltime.Value             -0.00001


pfset ComputationalGrid.NZ                1



set slopenamex slopex.trim2
set slopenamey slopey.trim2


pfset TopoSlopesX.Type "PFBFile"
pfset TopoSlopesX.GeomNames "domain"
pfset TopoSlopesX.FileName "$slopenamex.pfb"
pfdist "$slopenamex.pfb"

pfset TopoSlopesY.Type "PFBFile"
pfset TopoSlopesY.GeomNames "domain"
pfset TopoSlopesY.FileName "$slopenamey.pfb"
pfdist "$slopenamey.pfb"

pfset ComputationalGrid.NZ                2


#---------------------------------------------------------
# Mannings coefficient
#---------------------------------------------------------

pfset Mannings.Type "Constant"
pfset Mannings.GeomNames "domain"
pfset Mannings.Geom.domain.Value 2.e-6
#pfset Mannings.Geom.domain.Value 0.0000044
#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value        0.0

#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------

pfset KnownSolution                                    NoKnownSolution


#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------

pfset Solver                                             Richards
pfset Solver.MaxIter                                     2500

pfset Solver.Nonlinear.MaxIter                           5000
pfset Solver.Nonlinear.ResidualTol                       1e-4
#pfset Solver.Nonlinear.ResidualTol                       1e-7

pfset Solver.TerrainFollowingGrid                       True
#pfset Solver.TerrainFollowingGrid.SlopeUpwindFormulation   Upwind

#pfset Solver.Nonlinear.EtaChoice                         EtaConstant

#pfset Solver.Nonlinear.EtaValue                          0.05
#pfset Solver.Nonlinear.UseJacobian                       True
#pfset Solver.Nonlinear.UseJacobian                       False
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol				 1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      20
pfset Solver.Linear.MaxRestarts                           2

#pfset Solver.Linear.Preconditioner                       PFMGOctree
#pfset Solver.Linear.Preconditioner                       PFMG
#pfset Solver.Linear.Preconditioner                       MGSemi
#pfset Solver.Linear.Preconditioner.PCMatrixType FullJacobian

 ###Test Settings
pfset Solver.Nonlinear.UseJacobian                       $UseJacobian 
pfset Solver.Nonlinear.EtaValue                          $EtaValue
pfset Solver.Linear.Preconditioner                       $Preconditioner

if {[info exists PCMatrixType]} {
	pfset Solver.Linear.Preconditioner.PCMatrixType          $PCMatrixType
}

if {[info exists MaxIter]} { 
  pfset Solver.Linear.Preconditioner.$Preconditioner.MaxIter         $MaxIter
}

if {[info exists MaxLevels]} { 
  pfset Solver.Linear.Preconditioner.$Preconditioner.MaxLevels         $MaxLevels
}

if {[info exists Smoother]} { 
  pfset Solver.Linear.Preconditioner.$Preconditioner.Smoother         $Smoother
}

if {[info exists RAPType]} {
  pfset Solver.Linear.Preconditioner.$Preconditioner.RAPType          $RAPType
}


pfset Solver.PrintSubsurf				False
pfset  Solver.Drop                                      1E-30
pfset Solver.AbsTol                                     1E-9

pfset Solver.PrintTopoSlopes   True
pfset Solver.PrintSubsurface   True

pfset Solver.WriteSiloSubsurfData False
pfset Solver.WriteSiloPressure False
pfset Solver.WriteSiloSlopes False

pfset Solver.WriteSiloSaturation False
pfset Solver.WriteSiloConcentration False

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

# set water table to be at the bottom of the domain, the top layer is initially dry
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      45.0

pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   z-lower

#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

pfwritedb $runname

#if {$DO_RUN} {
puts "Running..."
pfrun $runname
pfundist $runname
pfundist $slopenamex
pfundist $slopenamey
puts "Finished!"
#}
