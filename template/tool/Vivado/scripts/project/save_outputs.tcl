# ============================================================
# Run implementation and export artifacts to tool/Vivado/output/<project>/.
# Usage: vivado -mode tcl -source save_outputs.tcl
# Prerequisite: a create_project.tcl run with valid part/top/constraints.
# ============================================================
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir .. common function.tcl]
source [file join $script_dir config.tcl]

set xpr [file join $project_dir ${project_name}.xpr]
if {![file exists $xpr]} {
    error "project not found: $xpr (run create_project.tcl first)"
}
open_project $xpr

puts "==> launching implementation (write_bitstream)"
if {[llength [get_runs -quiet impl_1]] == 0} {
    error "impl_1 run not found: open the project, check that synthesis/implementation runs exist"
}
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set progress [get_property PROGRESS [get_runs impl_1]]
if {$progress ne "100%"} {
    error "impl_1 did not complete (PROGRESS=$progress); check the run log"
}

file mkdir $output_dir
set runs_dir [file join $project_dir ${project_name}.runs impl_1]
foreach f [glob -nocomplain -directory $runs_dir *.bit] {
    file copy -force $f $output_dir
    puts "  copied: [file tail $f]"
}

# Block Design handoff files (optional, only if the project contains a BD)
set bd_dir [file join $project_dir ${project_name}.gen sources_1 bd]
foreach f [glob -nocomplain -directory $bd_dir *] {
    if {[file isdirectory $f]} {
        foreach h [glob -nocomplain -directory [file join $f hw_handoff] *.hwh] {
            file copy -force $h $output_dir
            puts "  copied: [file tail $h]"
        }
    }
}

puts "==> outputs written to: $output_dir"
