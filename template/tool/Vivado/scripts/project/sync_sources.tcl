# ============================================================
# Sync new/changed RTL files from src/ and lib/ into an existing project.
# Usage: vivado -mode tcl -source sync_sources.tcl
# ============================================================
set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir .. common function.tcl]
source [file join $script_dir config.tcl]

set xpr [file join $project_dir ${project_name}.xpr]
if {![file exists $xpr]} {
    error "project not found: $xpr (run create_project.tcl first)"
}
open_project $xpr

puts "==> syncing sources"
sync_sources_from_dir $src_dir
sync_sources_from_dir $lib_dir
set_top_or_warn $top_module

puts "==> done"
