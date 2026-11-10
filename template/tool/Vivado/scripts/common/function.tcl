# ============================================================
# Vivado generic helper functions (Tcl)
# ============================================================
# Sourced by scripts/project/*.tcl; all paths are derived from this file's
# location, so the repository can be cloned anywhere.

proc get_repo_root {} {
    set script_dir [file dirname [file normalize [info script]]]
    return [file normalize [file join $script_dir .. .. .. ..]]
}

# Recursively collect .sv/.v files, skipping testbench/ and abandon/ dirs.
proc get_files_recursive {root} {
    set result {}
    if {![file exists $root]} {
        return $result
    }
    foreach path [glob -nocomplain -directory $root *] {
        set name [file tail $path]
        if {[file isdirectory $path]} {
            if {$name eq "abandon" || $name eq "testbench"} {
                continue
            }
            set result [concat $result [get_files_recursive $path]]
        } elseif {[string match "*.sv" $path] || [string match "*.v" $path]} {
            lappend result [file normalize $path]
        }
    }
    return $result
}

proc add_sources_from_dir {root} {
    set files [get_files_recursive $root]
    if {[llength $files] > 0} {
        add_files -fileset sources_1 -norecurse $files
        update_compile_order -fileset sources_1
    }
    puts "  sources from $root : [llength $files] file(s)"
    return [llength $files]
}

# Add only files not already present in the project (for sync after edits).
proc sync_sources_from_dir {root} {
    set existing {}
    foreach f [get_files -quiet] {
        lappend existing [file normalize $f]
    }
    set added 0
    foreach f [get_files_recursive $root] {
        if {[lsearch -exact $existing $f] < 0} {
            add_files -fileset sources_1 -norecurse $f
            incr added
        }
    }
    if {$added > 0} {
        update_compile_order -fileset sources_1
    }
    puts "  synced $root : +$added file(s)"
    return $added
}

proc set_top_or_warn {top} {
    if {$top eq ""} {
        puts "WARNING: top_module is empty in config.tcl"
        return
    }
    if {[llength [get_files -quiet]] == 0} {
        puts "WARNING: no source files in project yet"
        return
    }
    set_property top $top [current_fileset]
    puts "  top module set to: $top"
}

proc read_xdc_or_warn {xdc_file} {
    if {![file exists $xdc_file]} {
        puts "WARNING: constraint file not found: $xdc_file"
        return
    }
    add_files -fileset constrs_1 -norecurse $xdc_file
    puts "  constraints added: $xdc_file"
}
