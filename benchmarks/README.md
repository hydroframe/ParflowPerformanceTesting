# ParFlow Solver Configuration Testing

## OVERVIEW

 The performance test framework allows a user to run various domains against several solver configurations 
 in single or batch runs. Statistics will be gathered at the end of each domain simulation.


## INCLUDED FILES

 * solver_configs/caseXX/solver_params.tcl - Solver configuration to apply for this test
 * collect_stats.tcl - script to collect stats from all the test cases in a domain
 * purge_log_files.tcl - script to purge all the log files generated from a run
 * exec_test_suite.tcl - wrapper script to run all tests in a domain from root of test directory
 * run_test.tcl - script to run a single solver configuration for a test domain
 * run_tests.tcl - wrapper script to run all tests for a domain from within domain directory 
 * README.md - this file
 * pfbdiff.py - python script to compare output files for differences
 * Domain SubFolders - Each problem domain is given its own folder
 * Domain SubFolders/tests.tcl - Defines the set of solver configurations to use for this test domain
 * Domain SubFolders/DomainName.tcl - adapted TCL script to use when testing
 * Domain SubFolders/results.csv - the collected results from the
 * Domain SubFolders/test_config.tcl - Domain specific information, where to find the test directory, runname, etc.
 * Domain SubFolders/validate_results.tcl - Script to run any post test validations of output data
 

## QUICKSTART
From this directory, run:
```
$ tclsh exec_test_suite.tcl LW 1 1 1 12
```

## RUNNING

 You must have Parflow installed and an environment variable named $PARFLOW_DIR which points to the directory where the 
 bin folder is located (standard Parflow requirements). 
 
 Python 3.4+ for post test validation

 /usr/bin/time available

 To run all the test cases for a Domain, from this folder run 
 ```bash
 $ tclsh exec_test_suite.tcl domainName P Q R T
 ```
 where domainName is the name of a Domain SubFolder and P Q R are integers which define the computation grid,
 and T is the StopTime you want the simulation to use.
 
  

## TO ADD A NEW DOMAIN
 
 Each new domain should be added as a Domain SubFolder to the main test directory. 
 Test cases are defined as folders in the Domain SubFolder and require a solver_params.tcl file.
 A domain run script (DomainName.tcl) should be edited to use supplied parameters for P Q R T.
 Additional modifications to DomainName.tcl required:
 * Comment out existing settings for solver configurations set by solver_params.tcl
 * Create a caseDefault test folder and place the original solver configurations in the solver_params.tcl there.
 * Copy any other test folders from existing test domain into new domain
 * Move the validation portion of the script to the validate_results.tcl script.
 * Insert the following code block to set the solver configurations at runtime: 
 ```tcl
 
 set runname <domainname>
 
 source solver_params.tcl

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
```
* add the following to the .gitignore:
```
<domainname>/**/solver_params.tcl
```

## To Add or Change Solver Configurations for a Domain

Modify the list of solver configurations defined in the subdomain's test.tcl file. 

For example, clayl/tests.tcl


## To Delete Test Logs

Use the purge_log_files.tcl script to remove log files for all subdomains.


