# ============================================================
# Create the Vivado project from config.tcl and add RTL sources.
# Usage: vivado -mode tcl -source create_project.tcl
# ============================================================
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir .. common function.tcl]
source [file join $script_dir config.tcl]

puts "==> creating project: $project_name"
# Plain part project (template default). For a board project, see config.tcl
# and replace -part $part_name with the appropriate -board option.
create_project -force $project_name $project_dir -part $part_name

puts "==> adding sources"
add_sources_from_dir $src_dir
add_sources_from_dir $lib_dir

set_top_or_warn $top_module
read_xdc_or_warn [file join $xdc_dir $xdc_file]

puts "==> done: [file join $project_dir ${project_name}.xpr]"
puts "==> next: edit RTL, then run  source sync_sources.tcl  and  source save_outputs.tcl"
