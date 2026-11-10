# ============================================================
# Vivado project configuration - EDIT THIS FILE FIRST.
# All other scripts source this file.
# ============================================================

set script_dir [file dirname [file normalize [info script]]]

# Repository root: tool/Vivado/scripts/project -> ../../../../ -> <repo>
set repo_root [file normalize [file join $script_dir .. .. .. ..]]

# ---- to be customized --------------------------------------
set project_name "hdl_project"            ;# project name / output dir name
set part_name    "xczu9eg-ffvb1156-2-e"   ;# TODO: set your FPGA part
set top_module   "top"                    ;# TODO: RTL top module name
set xdc_file     "timing.xdc"             ;# file under tool/Vivado/xdc/
# ------------------------------------------------------------

set vivado_dir  [file normalize [file join $repo_root tool Vivado]]
set src_dir     [file join $repo_root src]
set lib_dir     [file join $repo_root lib]
set xdc_dir     [file normalize [file join $script_dir .. .. xdc]]
set project_dir [file join $vivado_dir projects $project_name]
set output_dir  [file join $vivado_dir output $project_name]

# If you use a board file instead of a plain part, set it here and pass
# -board $board_part to create_project in create_project.tcl.
set board_part ""
