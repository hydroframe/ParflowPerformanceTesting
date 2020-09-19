#############################################################
#
# Run the SnakeRiver domain defined by shapefile
# 
# add constant rain
# add 5 layers
# add var dz
# add indicator file & soil properties
# spinup
# turn off spinup and add restart pressure
# turn off constant rain, add CLM
# add silo CLM output
# increase max iterations from 25 to 80
# add NLDAS forcings for 1 year wy2015
# change CLM outputs to daily instead of hourly
# change PF outputs to daily instead of hourly
# add CLM restarts written
# remove single file CLM out
# turn off silo outs since pfb files are written
# add sinks
# decrease krylov dimensions
# increase max lin iterations
# increase krylov dimensions from 100 to 250
# increase timestep from .05 to 1
# change output directory
# change CLM reuse count
# increase max iterations from 250 to 10000
# change boundary condition to seepage face
# update output folder name
# add tfg
# increase krylov dims to 500
# increase krylov dims to 1000
# decrease krylov dims to 250, rename snake_river_clm
# remove clm, go to const rain
#############################################################

set tcl_precision 17

set runname snake_river
source solver_params.tcl

set folder_name outputs

file mkdir $folder_name
cd $folder_name

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

pfset FileVersion 4



 #-----------------------------------------------------------------------------
 # StopTime
 #-----------------------------------------------------------------------------
 set StopTime [lindex $argv 3]

 #-----------------------------------------------------------------------------
 # Set Processor topology 
 #-----------------------------------------------------------------------------
 pfset Process.Topology.P        [lindex $argv 0]
 pfset Process.Topology.Q        [lindex $argv 1]
 pfset Process.Topology.R        [lindex $argv 2]
 
 pfset TimingInfo.StopTime        $StopTime
 
 
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

#---------------------------------------------------------
# Copy necessary files
#---------------------------------------------------------

#Slope files
set slopex SnakeRiverShape_Str3Ep0_smth.rvth_1500.mx0.5.mn5.sec0.up_slopex.pfb
set slopey SnakeRiverShape_Str3Ep0_smth.rvth_1500.mx0.5.mn5.sec0.up_slopey.pfb

file copy -force ../input_files/$slopex .
file copy -force ../input_files/$slopey .

#Solid file
set solid SnakeRiverShape.pfsol

file copy -force ../input_files/$solid .
file copy -force ../undist.tcl .


#indicator file
set indicator SnakeRiverShape_3d-grid.v3.pfb
file copy -force ../input_files/$indicator .

set initial_pressure SnakeRiverShape.out.press.00015.pfb
file copy -force ../input_files/$initial_pressure .
#PME file
#file copy -force ../input_files/SnakeRiverShape_PME.pfb .

#CLM Inputs
#file copy -force ../clm_input/drv_clmin.dat .
#file copy -force ../clm_input/drv_vegp.dat  .
#file copy -force ../clm_input/drv_vegm.alluv.dat  . 

#---------------------------------------------------------
# Computational Grid
#---------------------------------------------------------
pfset ComputationalGrid.Lower.X           0.0
pfset ComputationalGrid.Lower.Y           0.0
pfset ComputationalGrid.Lower.Z           0.0

pfset ComputationalGrid.NX 704
pfset ComputationalGrid.NY 736
pfset ComputationalGrid.NZ 5

pfset ComputationalGrid.DX 1000.0
pfset ComputationalGrid.DY 1000.0
pfset ComputationalGrid.DZ 200.0

#---------------------------------------------------------
# The Names of the GeomInputs
#---------------------------------------------------------

pfset GeomInput.Names                 "domaininput indi_input"

pfset GeomInput.domaininput.GeomName  domain

pfset GeomInput.domaininput.InputType  SolidFile
pfset GeomInput.domaininput.GeomNames  domain
pfset GeomInput.domaininput.FileName $solid

pfset Geom.domain.Patches "land top sink bottom "

#--------------------------------------------
# variable dz assignments
#------------------------------------------
pfset Solver.Nonlinear.VariableDz   True
pfset dzScale.GeomNames            domain
pfset dzScale.Type            nzList
pfset dzScale.nzListNumber 5

pfset Cell.0.dzScale.Value 0.5
# 100 m * .01 = 1m 
pfset Cell.1.dzScale.Value 0.005
# 100 m * .006 = 0.6 m 
pfset Cell.2.dzScale.Value 0.003
# 100 m * 0.003 = 0.3 m 
pfset Cell.3.dzScale.Value 0.0015
# 100 m * 0.001 = 0.1m = 10 cm which is default top Noah layer
pfset Cell.4.dzScale.Value 0.0005

#-----------------------------------------------------------------------------
# Subsurface Indicator Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.indi_input.InputType    IndicatorField
pfset GeomInput.indi_input.GeomNames    "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 g1 g2 g3 g4 g5 g6 g7 g8 b1 b2"
pfset Geom.indi_input.FileName          $indicator

pfset GeomInput.s1.Value    1
pfset GeomInput.s2.Value    2
pfset GeomInput.s3.Value    3
pfset GeomInput.s4.Value    4
pfset GeomInput.s5.Value    5
pfset GeomInput.s6.Value    6
pfset GeomInput.s7.Value    7
pfset GeomInput.s8.Value    8
pfset GeomInput.s9.Value    9
pfset GeomInput.s10.Value   10
pfset GeomInput.s11.Value   11
pfset GeomInput.s12.Value   12
pfset GeomInput.s13.Value   13

pfset GeomInput.g1.Value    21
pfset GeomInput.g2.Value    22
pfset GeomInput.g3.Value    23
pfset GeomInput.g4.Value    24
pfset GeomInput.g5.Value    25
pfset GeomInput.g6.Value    26
pfset GeomInput.g7.Value    27
pfset GeomInput.g8.Value    28
pfset GeomInput.b1.Value    19
pfset GeomInput.b2.Value    20


#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names                 "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 g1 g2 g3 g4 g5 g6 g7 g8 b1 b2"

# Values in m/hour

pfset Geom.domain.Perm.Type             Constant
pfset Geom.domain.Perm.Value            0.02

pfset Geom.s1.Perm.Type                 Constant
pfset Geom.s1.Perm.Value                0.269022595

pfset Geom.s2.Perm.Type                 Constant
pfset Geom.s2.Perm.Value                0.043630356

pfset Geom.s3.Perm.Type                 Constant
pfset Geom.s3.Perm.Value                0.015841225

pfset Geom.s4.Perm.Type                 Constant
pfset Geom.s4.Perm.Value                0.007582087

pfset Geom.s5.Perm.Type                 Constant
pfset Geom.s5.Perm.Value                0.01818816

pfset Geom.s6.Perm.Type                 Constant
pfset Geom.s6.Perm.Value                0.005009435

pfset Geom.s7.Perm.Type                 Constant
pfset Geom.s7.Perm.Value                 0.005492736

pfset Geom.s8.Perm.Type            Constant
pfset Geom.s8.Perm.Value           0.004675077

pfset Geom.s9.Perm.Type            Constant
pfset Geom.s9.Perm.Value           0.003386794

pfset Geom.s10.Perm.Type            Constant
pfset Geom.s10.Perm.Value           0.004783973

pfset Geom.s11.Perm.Type            Constant
pfset Geom.s11.Perm.Value           0.003979136

pfset Geom.s12.Perm.Type            Constant
pfset Geom.s12.Perm.Value           0.006162952

pfset Geom.s13.Perm.Type            Constant
pfset Geom.s13.Perm.Value           0.005009435

#perm(19) = 0.005
#perm(20) = 0.01
#perm(21) = 0.02
#perm(22) =  0.03
#perm(23) =  0.04
#perm(24) = 0.05
#perm(25) =  0.06
#perm(26) =  0.08
#perm(27) = 0.1
#perm(28) = 0.2
#


pfset Geom.b1.Perm.Type            Constant
pfset Geom.b1.Perm.Value           0.005

pfset Geom.b2.Perm.Type            Constant
pfset Geom.b2.Perm.Value           0.01

pfset Geom.g1.Perm.Type            Constant
pfset Geom.g1.Perm.Value           0.02

pfset Geom.g2.Perm.Type            Constant
pfset Geom.g2.Perm.Value           0.03

pfset Geom.g3.Perm.Type            Constant
pfset Geom.g3.Perm.Value           0.04

pfset Geom.g4.Perm.Type            Constant
pfset Geom.g4.Perm.Value           0.05

pfset Geom.g5.Perm.Type            Constant
pfset Geom.g5.Perm.Value           0.06

pfset Geom.g6.Perm.Type            Constant
pfset Geom.g6.Perm.Value           0.08

pfset Geom.g7.Perm.Type            Constant
pfset Geom.g7.Perm.Value           0.1

pfset Geom.g8.Perm.Type            Constant
pfset Geom.g8.Perm.Value           0.2


#pfset Geom.g1.Perm.Type            Constant
#pfset Geom.g1.Perm.Value           1.10541E-06

#pfset Geom.g2.Perm.Type            Constant
#pfset Geom.g2.Perm.Value           2.20557E-05

#pfset Geom.g3.Perm.Type            Constant
#pfset Geom.g3.Perm.Value           0.000277665

#pfset Geom.g4.Perm.Type            Constant
#pfset Geom.g4.Perm.Value           0.00034956

#pfset Geom.g5.Perm.Type            Constant
#pfset Geom.g5.Perm.Value           0.0034956

#pfset Geom.g6.Perm.Type            Constant
#pfset Geom.g6.Perm.Value           0.011054058

#pfset Geom.g7.Perm.Type            Constant
#pfset Geom.g7.Perm.Value           0.055401526

#pfset Geom.g8.Perm.Type            Constant
#pfset Geom.g8.Perm.Value           0.440069967

#-----------------------------------------------------------------------------
# Permeability (values in m/hr)
#-----------------------------------------------------------------------------
# pfset Geom.Perm.Names                 "domain"

# # Values in m/hour

# pfset Geom.domain.Perm.Type             Constant
# pfset Geom.domain.Perm.Value 0.02849


# pfset Perm.TensorType               TensorByGeom

# pfset Geom.Perm.TensorByGeom.Names  "domain"

# pfset Geom.domain.Perm.TensorValX  1.0d0
# pfset Geom.domain.Perm.TensorValY  1.0d0
# pfset Geom.domain.Perm.TensorValZ  1.0d0

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
pfset TimingInfo.BaseUnit 1
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime 0
pfset TimingInfo.StopTime $StopTime
#pfset TimingInfo.StopTime	72.0
pfset TimingInfo.DumpInterval 24.0
pfset TimeStep.Type              Constant
pfset TimeStep.Value 1
#pfset TimeStep.Type Growth
#pfset TimeStep.InitialStep 0.01
#pfset TimeStep.GrowthFactor 1.4
#pfset TimeStep.MaxStep 1.0
#pfset TimeStep.MinStep 0.0001


#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
pfset Geom.Porosity.GeomNames           "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 g1 g2 g3 g4 g5 g6 g7 g8"

pfset Geom.domain.Porosity.Type         Constant
pfset Geom.domain.Porosity.Value        0.33

pfset Geom.s1.Porosity.Type    Constant
pfset Geom.s1.Porosity.Value   0.375

pfset Geom.s2.Porosity.Type    Constant
pfset Geom.s2.Porosity.Value   0.39

pfset Geom.s3.Porosity.Type    Constant
pfset Geom.s3.Porosity.Value   0.387

pfset Geom.s4.Porosity.Type    Constant
pfset Geom.s4.Porosity.Value   0.439

pfset Geom.s5.Porosity.Type    Constant
pfset Geom.s5.Porosity.Value   0.489

pfset Geom.s6.Porosity.Type    Constant
pfset Geom.s6.Porosity.Value   0.399

pfset Geom.s7.Porosity.Type    Constant
pfset Geom.s7.Porosity.Value   0.384

pfset Geom.s8.Porosity.Type            Constant
pfset Geom.s8.Porosity.Value           0.482

pfset Geom.s9.Porosity.Type            Constant
pfset Geom.s9.Porosity.Value           0.442

pfset Geom.s10.Porosity.Type            Constant
pfset Geom.s10.Porosity.Value           0.385

pfset Geom.s11.Porosity.Type            Constant
pfset Geom.s11.Porosity.Value           0.481

pfset Geom.s12.Porosity.Type            Constant
pfset Geom.s12.Porosity.Value           0.459

pfset Geom.s13.Porosity.Type            Constant
pfset Geom.s13.Porosity.Value           0.399

pfset Geom.g1.Porosity.Type            Constant
pfset Geom.g1.Porosity.Value           0.33

pfset Geom.g2.Porosity.Type            Constant
pfset Geom.g2.Porosity.Value           0.33

pfset Geom.g3.Porosity.Type            Constant
pfset Geom.g3.Porosity.Value           0.33

pfset Geom.g4.Porosity.Type            Constant
pfset Geom.g4.Porosity.Value           0.33

pfset Geom.g5.Porosity.Type            Constant
pfset Geom.g5.Porosity.Value           0.33

pfset Geom.g6.Porosity.Type            Constant
pfset Geom.g6.Porosity.Value           0.33

pfset Geom.g7.Porosity.Type            Constant
pfset Geom.g7.Porosity.Value           0.33

pfset Geom.g8.Porosity.Type            Constant
pfset Geom.g8.Porosity.Value           0.33


#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
# pfset Geom.Porosity.GeomNames           "domain"

# pfset Geom.domain.Porosity.Type         Constant
# pfset Geom.domain.Porosity.Value 0.39738
#pfset Geom.domain.Porosity.Value        0.00000001

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName domain

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------

pfset Phase.RelPerm.Type               VanGenuchten
pfset Phase.RelPerm.GeomNames      "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13"
#pfset Phase.RelPerm.GeomNames      "domain s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13"
#pfset Phase.RelPerm.GeomNames      "domain"

pfset Geom.domain.RelPerm.Alpha    1.
pfset Geom.domain.RelPerm.N        3.
pfset Geom.domain.RelPerm.NumSamplePoints   20000
pfset Geom.domain.RelPerm.MinPressureHead   -300
pfset Geom.domain.RelPerm.InterpolationMethod  Linear


pfset Geom.s1.RelPerm.Alpha        3.548
#pfset Geom.s1.RelPerm.Alpha        2.5
pfset Geom.s1.RelPerm.N            4.162
pfset Geom.s1.RelPerm.NumSamplePoints   20000
pfset Geom.s1.RelPerm.MinPressureHead   -300
pfset Geom.s1.RelPerm.InterpolationMethod  Linear

pfset Geom.s2.RelPerm.Alpha        3.467
pfset Geom.s2.RelPerm.N            2.738
pfset Geom.s2.RelPerm.NumSamplePoints   20000
pfset Geom.s2.RelPerm.MinPressureHead   -300
pfset Geom.s2.RelPerm.InterpolationMethod  Linear

pfset Geom.s3.RelPerm.Alpha        2.692
pfset Geom.s3.RelPerm.N            2.445
pfset Geom.s3.RelPerm.NumSamplePoints   20000
pfset Geom.s3.RelPerm.MinPressureHead   -300
pfset Geom.s3.RelPerm.InterpolationMethod  Linear

pfset Geom.s4.RelPerm.Alpha        0.501
pfset Geom.s4.RelPerm.N            2.659
pfset Geom.s4.RelPerm.NumSamplePoints   20000
pfset Geom.s4.RelPerm.MinPressureHead   -300
pfset Geom.s4.RelPerm.InterpolationMethod  Linear

pfset Geom.s5.RelPerm.Alpha        0.661
pfset Geom.s5.RelPerm.N            2.659
pfset Geom.s5.RelPerm.NumSamplePoints   20000
pfset Geom.s5.RelPerm.MinPressureHead   -300
pfset Geom.s5.RelPerm.InterpolationMethod  Linear

pfset Geom.s6.RelPerm.Alpha        1.122
pfset Geom.s6.RelPerm.N            2.479
pfset Geom.s6.RelPerm.NumSamplePoints   20000
pfset Geom.s6.RelPerm.MinPressureHead   -300
pfset Geom.s6.RelPerm.InterpolationMethod  Linear

pfset Geom.s7.RelPerm.Alpha        2.089
pfset Geom.s7.RelPerm.N            2.318
pfset Geom.s7.RelPerm.NumSamplePoints   20000
pfset Geom.s7.RelPerm.MinPressureHead   -300
pfset Geom.s7.RelPerm.InterpolationMethod  Linear

pfset Geom.s8.RelPerm.Alpha        0.832
pfset Geom.s8.RelPerm.N            2.514
pfset Geom.s8.RelPerm.NumSamplePoints   20000
pfset Geom.s8.RelPerm.MinPressureHead   -300
pfset Geom.s8.RelPerm.InterpolationMethod  Linear

pfset Geom.s9.RelPerm.Alpha        1.585
pfset Geom.s9.RelPerm.N            2.413
pfset Geom.s9.RelPerm.NumSamplePoints   20000
pfset Geom.s9.RelPerm.MinPressureHead   -300
pfset Geom.s9.RelPerm.InterpolationMethod  Linear

pfset Geom.s10.RelPerm.Alpha        3.311
#pfset Geom.s10.RelPerm.Alpha        2.
pfset Geom.s10.RelPerm.N            2.202
pfset Geom.s10.RelPerm.NumSamplePoints   20000
pfset Geom.s10.RelPerm.MinPressureHead   -300
pfset Geom.s10.RelPerm.InterpolationMethod  Linear

pfset Geom.s11.RelPerm.Alpha        1.622
pfset Geom.s11.RelPerm.N            2.318
pfset Geom.s11.RelPerm.NumSamplePoints   20000
pfset Geom.s11.RelPerm.MinPressureHead   -300
pfset Geom.s11.RelPerm.InterpolationMethod  Linear

pfset Geom.s12.RelPerm.Alpha        1.514
pfset Geom.s12.RelPerm.N            2.259
pfset Geom.s12.RelPerm.NumSamplePoints   20000
pfset Geom.s12.RelPerm.MinPressureHead   -300
pfset Geom.s12.RelPerm.InterpolationMethod  Linear

pfset Geom.s13.RelPerm.Alpha        1.122
pfset Geom.s13.RelPerm.N            2.479
pfset Geom.s13.RelPerm.NumSamplePoints   20000
pfset Geom.s13.RelPerm.MinPressureHead   -300
pfset Geom.s13.RelPerm.InterpolationMethod  Linear


#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

pfset Phase.Saturation.Type              VanGenuchten
pfset Phase.Saturation.GeomNames         "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13"
#pfset Phase.Saturation.GeomNames         "domain s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13"
#pfset Phase.Saturation.GeomNames         "domain"
#
# @RMM added very low Sres to help with dry / large evap
#
pfset Geom.domain.Saturation.Alpha        1.
pfset Geom.domain.Saturation.N            3.
#pfset Geom.domain.Saturation.SRes         0.1
pfset Geom.domain.Saturation.SRes         0.001
pfset Geom.domain.Saturation.SSat         1.0

pfset Geom.s1.Saturation.Alpha        3.548
pfset Geom.s1.Saturation.N            4.162
pfset Geom.s1.Saturation.SRes         0.0001
#pfset Geom.s1.Saturation.SRes         0.1
pfset Geom.s1.Saturation.SSat         1.0

pfset Geom.s2.Saturation.Alpha        3.467
#pfset Geom.s2.Saturation.Alpha        2.5
pfset Geom.s2.Saturation.N            2.738
pfset Geom.s2.Saturation.SRes         0.0001
#pfset Geom.s2.Saturation.SRes         0.1
pfset Geom.s2.Saturation.SSat         1.0

pfset Geom.s3.Saturation.Alpha        2.692
pfset Geom.s3.Saturation.N            2.445
pfset Geom.s3.Saturation.SRes         0.0001
#pfset Geom.s3.Saturation.SRes         0.1
pfset Geom.s3.Saturation.SSat         1.0

pfset Geom.s4.Saturation.Alpha        0.501
pfset Geom.s4.Saturation.N            2.659
#pfset Geom.s4.Saturation.SRes         0.0001
pfset Geom.s4.Saturation.SRes         0.1
pfset Geom.s4.Saturation.SSat         1.0

pfset Geom.s5.Saturation.Alpha        0.661
pfset Geom.s5.Saturation.N            2.659
pfset Geom.s5.Saturation.SRes         0.0001
#pfset Geom.s5.Saturation.SRes         0.1
pfset Geom.s5.Saturation.SSat         1.0

pfset Geom.s6.Saturation.Alpha        1.122
pfset Geom.s6.Saturation.N            2.479
pfset Geom.s6.Saturation.SRes         0.0001
#pfset Geom.s6.Saturation.SRes         0.1
pfset Geom.s6.Saturation.SSat         1.0

pfset Geom.s7.Saturation.Alpha        2.089
pfset Geom.s7.Saturation.N            2.318
pfset Geom.s7.Saturation.SRes         0.0001
#pfset Geom.s7.Saturation.SRes         0.1
pfset Geom.s7.Saturation.SSat         1.0

pfset Geom.s8.Saturation.Alpha        0.832
pfset Geom.s8.Saturation.N            2.514
pfset Geom.s8.Saturation.SRes         0.0001
#pfset Geom.s8.Saturation.SRes         0.1
pfset Geom.s8.Saturation.SSat         1.0

pfset Geom.s9.Saturation.Alpha        1.585
pfset Geom.s9.Saturation.N            2.413
pfset Geom.s9.Saturation.SRes         0.0001
#pfset Geom.s9.Saturation.SRes         0.1
pfset Geom.s9.Saturation.SSat         1.0

pfset Geom.s10.Saturation.Alpha        3.311
#pfset Geom.s10.Saturation.Alpha        2.
pfset Geom.s10.Saturation.N            2.202
pfset Geom.s10.Saturation.SRes         0.0001
#pfset Geom.s10.Saturation.SRes         0.1
pfset Geom.s10.Saturation.SSat         1.0

pfset Geom.s11.Saturation.Alpha        1.622
pfset Geom.s11.Saturation.N            2.318
pfset Geom.s11.Saturation.SRes         0.0001
#pfset Geom.s11.Saturation.SRes         0.1
pfset Geom.s11.Saturation.SSat         1.0

pfset Geom.s12.Saturation.Alpha        1.514
pfset Geom.s12.Saturation.N            2.259
pfset Geom.s12.Saturation.SRes         0.0001
#pfset Geom.s12.Saturation.SRes         0.1
pfset Geom.s12.Saturation.SSat         1.0

pfset Geom.s13.Saturation.Alpha        1.122
pfset Geom.s13.Saturation.N            2.479
pfset Geom.s13.Saturation.SRes         0.0001
#pfset Geom.s13.Saturation.SRes         0.1
pfset Geom.s13.Saturation.SSat         1.0

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------

# pfset Phase.RelPerm.Type               VanGenuchten
# pfset Phase.RelPerm.GeomNames      "domain"


# pfset Geom.domain.RelPerm.Alpha    1.
# pfset Geom.domain.RelPerm.N        2.

#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

# pfset Phase.Saturation.Type              VanGenuchten
# pfset Phase.Saturation.GeomNames         "domain"

# pfset Geom.domain.Saturation.Alpha        1.0
# pfset Geom.domain.Saturation.N            2.
# pfset Geom.domain.Saturation.SRes         0.2
# pfset Geom.domain.Saturation.SSat         1.0

#----------------------------------------------------------------------------
# Mobility
#----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                         ""

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names "constant rainrec"
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      1
pfset Cycle.constant.Repeat             -1

# rainfall and recession time periods are defined here
# rain for 0.2 hour, recession for 30 hours

pfset Cycle.rainrec.Names                 "rain rec"
pfset Cycle.rainrec.rain.Length           10.
pfset Cycle.rainrec.rec.Length            30.
pfset Cycle.rainrec.Repeat                -1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames "land top sink bottom "

# zero head boundaries for ocean, sink and lake boundaries
# pfset Patch.ocean.BCPressure.Type       DirEquilRefPatch
# pfset Patch.ocean.BCPressure.Type       FluxConst

# pfset Patch.ocean.BCPressure.Cycle      "constant"
# pfset Patch.ocean.BCPressure.RefGeom        domain
# pfset Patch.ocean.BCPressure.RefPatch     bottom
# pfset Patch.ocean.BCPressure.alltime.Value  0.

#pfset Patch.sink.BCPressure.Type       DirEquilRefPatch
#pfset Patch.sink.BCPressure.Type       OverlandFlow

pfset Patch.sink.BCPressure.Type       SeepageFace
#pfset Patch.sink.BCPressure.Type       OverlandFlow

pfset Patch.sink.BCPressure.Cycle      "constant"
#pfset Patch.sink.BCPressure.RefGeom        domain
#pfset Patch.sink.BCPressure.RefPatch     bottom
pfset Patch.sink.BCPressure.alltime.Value  -0.001
#pfset Patch.sink.BCPressure.Cycle		      "rainrec"
#pfset Patch.sink.BCPressure.rain.Value	      -0.05
#pfset Patch.sink.BCPressure.rec.Value	      0.0000

#pfset Patch.lake.BCPressure.Type       DirEquilRefPatch
# pfset Patch.lake.BCPressure.Type       OverlandFlow

# pfset Patch.lake.BCPressure.Cycle      "constant"
# pfset Patch.lake.BCPressure.RefGeom        domain
# pfset Patch.lake.BCPressure.RefPatch     bottom
# pfset Patch.lake.BCPressure.alltime.Value  0.0
#pfset Patch.lake.BCPressure.Cycle		      "rainrec"
#pfset Patch.lake.BCPressure.rain.Value	      -0.05
#pfset Patch.lake.BCPressure.rec.Value	      0.0000

#no flow boundaries for the land borders and the bottom
pfset Patch.land.BCPressure.Type		      FluxConst
pfset Patch.land.BCPressure.Cycle		      "constant"
pfset Patch.land.BCPressure.alltime.Value	      0.0

pfset Patch.bottom.BCPressure.Type		      FluxConst
pfset Patch.bottom.BCPressure.Cycle		      "constant"
pfset Patch.bottom.BCPressure.alltime.Value	      0.0


## overland flow boundary condition with rainfall then nothing
pfset Patch.top.BCPressure.Type OverlandFlow
pfset Patch.top.BCPressure.Cycle "rainrec"
pfset Patch.top.BCPressure.rain.Value -0.05
pfset Patch.top.BCPressure.rec.Value 0.0000
#pfset Patch.top.BCPressure.Cycle "constant"
#pfset Patch.top.BCPressure.alltime.Value 0.000


# PmE flux
#pfset Solver.EvapTransFile True
#pfset Solver.EvapTrans.FileName SnakeRiverShape_PME.pfb

#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------

pfset TopoSlopesX.Type "PFBFile"
pfset TopoSlopesX.GeomNames "domain"

pfset TopoSlopesX.FileName $slopex


#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------

pfset TopoSlopesY.Type "PFBFile"
pfset TopoSlopesY.GeomNames "domain"

pfset TopoSlopesY.FileName $slopey

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

# set water table to be at the bottom of the domain, the top layer is initially dry
pfset ICPressure.Type                                   HydroStaticPatch
#pfset ICPressure.GeomNames                              domain
#pfset Geom.domain.ICPressure.Value 0.0

pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   bottom
pfset ICPressure.Type                                   PFBFile
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.FileName					$initial_pressure

#---------
##  Distribute inputs
#---------

pfdist -nz 1 $slopex
pfdist -nz 1 $slopey
pfdist $indicator
pfdist $initial_pressure
#pfdist SnakeRiverShape_PME.pfb


#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------

#pfset TopoSlopesX.Type "Constant"
#pfset TopoSlopesX.GeomNames "domain"
#pfset TopoSlopesX.Geom.domain.Value 0.01
#pfset TopoSlopesX.Geom.domain.Value -0.01
#pfset TopoSlopesX.Geom.domain.Value 0.0

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------


#pfset TopoSlopesY.Type "Constant"
#pfset TopoSlopesY.GeomNames "domain"
#pfset TopoSlopesY.Geom.domain.Value 0.001
#pfset TopoSlopesY.Geom.domain.Value -0.01
#pfset TopoSlopesY.Geom.domain.Value 0.0

#---------------------------------------------------------
# Mannings coefficient
#---------------------------------------------------------

pfset Mannings.Type "Constant"
pfset Mannings.GeomNames "domain"
pfset Mannings.Geom.domain.Value 2.e-6
pfset Mannings.Geom.domain.Value 0.0000044
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
pfset Solver.MaxIter                                    100000

pfset Solver.TerrainFollowingGrid                     True
#pfset Solver.TerrainFollowingGrid                    False


pfset Solver.Nonlinear.MaxIter                           10000
pfset Solver.Nonlinear.ResidualTol                       1e-4
pfset Solver.Nonlinear.EtaChoice                         EtaConstant
#pfset Solver.Nonlinear.EtaValue                          1e-3
#pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol                       	 1e-25

pfset Solver.Linear.KrylovDimension                      250
pfset Solver.Linear.MaxRestarts                           8
pfset Solver.MaxConvergenceFailures                       5

#pfset Solver.Linear.Preconditioner                       PFMGOctree
#pfset Solver.Linear.Preconditioner.MGSemi.MaxIter        1
#pfset Solver.Linear.Preconditioner.MGSemi.MaxLevels      100

#pfset Solver.Linear.Preconditioner.PCMatrixType     FullJacobian
pfset Solver.WriteSiloPressure                        False
pfset Solver.PrintSubsurfData                         True
pfset Solver.PrintMask                                True
pfset Solver.PrintVelocities                          False
pfset Solver.PrintSaturation                          True
pfset Solver.PrintPressure                            True
pfset Solver.PrintCLM                                 False
#Writing output (no binary except Pressure, all silo):
pfset Solver.PrintSubsurfData                         True 
#pfset Solver.PrintLSMSink                        True 
#pfset Solver.PrintSaturation                          True
pfset Solver.WriteCLMBinary                           False

pfset Solver.WriteSiloSpecificStorage                  False
pfset Solver.WriteSiloMannings                         False
pfset Solver.WriteSiloMask                             False
pfset Solver.WriteSiloSlopes                          False
pfset Solver.WriteSiloSubsurfData                     False
pfset Solver.WriteSiloPressure                        False
pfset Solver.WriteSiloSaturation                       False
pfset Solver.WriteSiloEvapTrans                       False
pfset Solver.WriteSiloEvapTransSum                     False
pfset Solver.WriteSiloOverlandSum                     False
pfset Solver.WriteSiloCLM                             False


pfset OverlandFlowSpinUp 								0


#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

pfrun $runname
pfundist $runname
exec tclsh undist.tcl $runname 0 $StopTime
puts "ParFlow run Complete"

#pfwritedb $runname

