source test_config.tcl

set dirs [glob -nocomplain -type d *]
if { [llength $dirs] > 0 } {
    puts "Deleting Logs..."
    foreach dir [lsearch -inline -all [lsort $dirs]  "case*"] {	
    	#Delete the whole directory
    	file delete -force $dir
       #go into the subdirectory
       # cd $dir
       # file delete {*}[glob -nocomplain *.log]
       # file delete {*}[glob -nocomplain $runname.out.*]  
       # cd ..
     }
}
