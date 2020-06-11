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

set output_file [open results.csv w]
source test_config.tcl

proc parse_time { time_string } {
    # Get the elapsed time (sec) from either /usr/bin/time output format (h:mm:ss or m:ss)

    # Produce list of floating point values in ascending order: seconds, minutes, and hours (if an hours measurement was listed)
    set time_array [lreverse [lmap str_val [split $time_string ":"] {scan $str_val %f} ]]

    set seconds [lindex $time_array 0]
    set minutes [lindex $time_array 1]
    # Need to check that there was a hours component
    set hours   [if {[llength $time_array] >= 3} {lindex $time_array 2} {expr 0.0}]

    set total_sec [expr $seconds + ($minutes * 60) + ($hours * 60 * 60)]

    return $total_sec
}


set case_dirs [lsort [glob -nocomplain -type d case*] ]
if { [llength $case_dirs] > 0 } {
    puts "Collecting Stats..."
    puts $output_file "StartDate, StartTime, Case, NL_Iter, Lin_Iter, Func, TimeSteps, Runtime, ElapsedTime, NonLin. Func Time, NonLin. Func MFLOPS(mops/s), NonLin. Func FLOP(op), Test Result ,Solver, Preconditioner, Jacobian, PCMatrixType, Smoother, RAPType, Eta, Solver Configuration"
    foreach dir $case_dirs {
        #go into the subdirectory
        cd $dir

        #get the test log file
        set fd [ open "test_case.log" "r"]
        set testlog [read $fd]
        close $fd

        #create some variables to store running totals
        set run_time_sum 0.0
        set nl_tot_sum 0
        set lin_tot_sum 0
        set func_tot_sum 0
        set tot_elapsed_time 0.0
        set nl_f_eval_time_sum 0.0
        set nl_f_eval_mflops_sum 0.0
        set nl_f_eval_flops_sum 0
        set failed ""
        #get the batch run values
        scan [lsearch -inline [split $testlog "\n"] "Test Run Count:*"] %s%s%s%i a b c test_run_count
        scan [lsearch -inline [split $testlog "\n"] "Test Started:*"] %s%s%s%s a b run_start_date run_start_time
        #loop through all the test runs, average the results
        for { set i 1 } { $i <= $test_run_count } { incr i } {
            set trial_dir [file join trials $i ]
            #read the kinsol log file
            set fd [open [file join $trial_dir $runname.out.kinsol.log] "r"]
            set kin [read $fd]
            close $fd

            #get the Kinsol values
            scan [lsearch -inline [lrange [split $kin "\n"] end-10 end] "Nonlin. Its.*"] %s%s%i%i a b nl_it nl_tot
            scan [lsearch -inline [lrange [split $kin "\n"] end-10 end] "Lin. Its.*"] %s%s%i%i a b lin_it lin_tot
            scan [lsearch -inline [lrange [split $kin "\n"] end-10 end] "Func. Evals.*"] %s%s%i%i a b func_it func_tot

            #read the output log file
            set fd [open [file join $trial_dir $runname.out.log] "r"]
            set log [read $fd]
            close $fd
            #get the runtime
            scan [lsearch -inline [split $log "\n"] "Total Run Time*"] %s%s%s%f%s a b c time sec

            #incr the running totals
            set run_time_sum [expr $run_time_sum + $time]
            set nl_tot_sum [expr $nl_tot_sum + $nl_tot]
            set lin_tot_sum [expr $lin_tot_sum + $lin_tot]
            set func_tot_sum [expr $func_tot_sum + $func_tot]

            #read the run time log file
            set fd [open [file join $trial_dir "run_time.log"] "r"]
            set run_time_log [read $fd]
            close $fd

            scan [lsearch -inline [split $run_time_log "\n"] "*Elapsed (wall clock) time*"] %s%s%s%s%s%s%s%s a b c d e f g elapsed_time

            #read the validation log file
            set fd [open [file join $trial_dir "validation.log"] "r"]
            set validation_log [read $fd]
            close $fd
            set failed [lsearch [split $validation_log "\n"] "*FAILED*"]

            set elapsed_time [ parse_time $elapsed_time]

            set tot_elapsed_time [expr $elapsed_time + $tot_elapsed_time]

            #read the timing.csv log file
            set fd [open [file join $trial_dir $runname.out.timing.csv] "r"]
            set timing_csv [read $fd]
            close $fd

            scan [lsearch -inline [split $timing_csv "\n"]  "NL_F_Eval*"] %s a
            lassign [split $a ","] b nl_f_eval_time nl_f_eval_mflops nl_f_eval_flops

            set nl_f_eval_time_sum [expr {$nl_f_eval_time + $nl_f_eval_time_sum} ]
            set nl_f_eval_mflops_sum [expr {$nl_f_eval_mflops + $nl_f_eval_mflops_sum} ]
            set nl_f_eval_flops_sum [expr  {$nl_f_eval_flops + $nl_f_eval_flops_sum}]
        }

        if { $failed != -1 } {
          set test_result "Failed"
        } else {
          set test_result "Passed"
        }


        set nl_f_eval_time [expr $nl_f_eval_time_sum / $test_run_count]
        set nl_f_eval_mflops [expr $nl_f_eval_mflops_sum / $test_run_count]
        set nl_f_eval_flops [expr $nl_f_eval_flops_sum / $test_run_count]

        set time [expr $run_time_sum / $test_run_count]
        set nl_tot [expr $nl_tot_sum / $test_run_count]
        set lin_tot [expr $lin_tot_sum / $test_run_count]
        set func_tot [expr $func_tot_sum / $test_run_count]
        set elapsed_time [expr $tot_elapsed_time / $test_run_count]

        #read the parameters database
        set fd [open "$runname.out.pftcl" "r"]
        set db [read $fd]
        close $fd

        #get the preconditioner type used
        scan [lsearch -inline [split $db "\n"] "*Solver.Linear.Preconditioner *"] %s%s%s a param_PC preconditioner

        #get the stoptime used
        scan [lsearch -inline [split $db "\n"] "*TimingInfo.StopTime *"] %s%s%s a b stoptime

        set vars {}
        set raptype {}

        #get all the solver settings
        foreach j [lsearch -all -inline [split $db "\n"] "*Solver.Linear.Preconditioner.*"] {
          scan $j %s%s%s a param val

          set smoother_line [string map {\" {}} "Solver.Linear.Preconditioner.$preconditioner.Smoother"]
          set rap_line [string map {\" {}} "Solver.Linear.Preconditioner.$preconditioner.RAPType"]

          #get the PCMatrixType value
          if {$param == "Solver.Linear.Preconditioner.PCMatrixType"} {
            set PCMatrixType $val
            continue
          }

          #get the RAPType value
          if { $param == $rap_line } {
            set raptype $val
            continue
          }

          #get the Smoother value
          if { $param == $smoother_line } {
            set Smoother $val
            continue
          }

          #dump all other solver params into this list
          lappend vars $param $val

        }

        #get the Solver value
        scan [lsearch -inline [split $db "\n"] "pfset Solver *"] %s%s%s a param_solver solver

        #get the Jacobian value
        scan [lsearch -inline [split $db "\n"] "*Solver.Nonlinear.UseJacobian*"] %s%s%s a param_jacobian jacobian

        #get the Eta Value
        scan [lsearch -inline [split $db "\n"] "*Solver.Nonlinear.EtaValue*"] %s%s%s a param_eta eta

        #write the values to the CSV file
        puts $output_file "$run_start_date, $run_start_time, $dir, $nl_tot, $lin_tot, $func_tot, $stoptime, $time, $elapsed_time, $nl_f_eval_time, $nl_f_eval_mflops, $nl_f_eval_flops, $test_result, $solver , $preconditioner, $jacobian, $PCMatrixType, $Smoother, $raptype, $eta, $vars"

        #get out of the subdirectory
        cd ..
    }
} else {
    puts "(no subdirectories)"
}
close $output_file
puts "...done!"
