# ============================================================
# VCS simulation entry (generic HDL project template)
# ------------------------------------------------------------
#   make topmodule=<tb_module> compile   # filelist -> vcs -> out/simv
#   make topmodule=<tb_module> run       # run simulation
#   make clean                           # clean build artifacts
# NOTE: run these commands from this directory (tool/VCS).
# ============================================================

topmodule ?= template_tb

PYTHON ?= python3
SIM_THREADS ?= 4
CORENUM ?= 16
CURRENT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
ROOT_DIR := $(abspath $(CURRENT_DIR)/../../)

FILELIST=./filelist/$(topmodule).f
SEARCH_PATH=../../src ../../lib

Mdir=./csrc
makeDirs= mkdir -p out log csrc

# Compile-time defines shared by the filelist generator and VCS.
# ROOT_DIR lets testbenches locate test data without hard-coded absolute paths;
# add project-specific defines here as needed (e.g. +define+SIM_ONLY).
vcsDefines := \
	+define+ROOT_DIR=\"$(ROOT_DIR)\" \
	+define+USE_VCS_SIMULATION

vcsFiles := 	-l ./log/compile.log \
				-o ./out/simv \
				-f $(FILELIST) 

vcsBaseCommand = 	vcs -full64 \
					$(vcsDefines)\
					+v2k \
					-xlrm module_xmr \
					-sverilog \
					-Mdir=$(Mdir) \
					-kdb \
					-debug_access \
					+lint=TFIPC-L \
					-top  $(topmodule) \
					-j $(CORENUM) \
					-timescale=1ps/1ps

vcsCompileCommand = $(vcsBaseCommand) $(vcsFiles)

make_filelist:
	$(PYTHON) ../VeribleFilelist/main.py -t $(topmodule) -s ${SEARCH_PATH} -d "${vcsDefines}"

lint: make_filelist
	$(makeDirs)

compile: lint 
	$(vcsCompileCommand)

compile_gui: lint
	$(vcsCompileCommand) -debug_access+all

compile_fgp: lint
	$(vcsCompileCommand) -fgp

compile_prof: lint
	$(vcsCompileCommand) -simprofile -debug_access+pp

run:
	./out/simv -l log/run.log

run_gui:
	./out/simv -gui

run_fgp:
	./out/simv -l log/run.log -fgp=num_threads:$(SIM_THREADS), allow_less_cores, multisocket, sync:busywait, auto_affinity -xdprof=diag:ruse, -Xdprof=timeline 

run_prof:
	./out/simv -l log/run.log +prof

clean:
	\rm -rf simv* *.log *.vpd *.dump csrc *.sim *.mra *.log ucli.key session* *.db vcs.key out/simv* tmp DVEfiles  temp $(Mdir)

remove:
	rm -rf out/*.vcd out/verdi_config_file log/*.log

.PHONY: make_filelist lint compile compile_gui compile_fgp compile_prof \
        run run_gui run_fgp run_prof clean remove
