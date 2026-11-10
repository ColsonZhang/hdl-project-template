// Generic testbench skeleton (part of the HDL project template).
// Copy this file to <rtl_dir>/testbench/<DutName>_tb.sv and keep:
//     file name == module name == `make topmodule=` value
// It relies on src/common/default_pkg.sv for clock/reset/delay/print tasks.
import default_pkg::*;

`define TB_MODULE_NAME template_tb

module `TB_MODULE_NAME();

// ------------------------------------------------------------------
// parameters
// ------------------------------------------------------------------
parameter WATCH_DOG_MAX_NUM = 10_000_000;   // in clock cycles
parameter DUMP_WAVE_EN      = 1;
parameter string DUMP_WAVE_TYPE = "vcd";        // "vcd"; see the fsdb note below

// Test data root. ROOT_DIR is injected by tool/VCS/Makefile:
//   +define+ROOT_DIR=\"...\"
// Keep data outside git: test/testbench_data/<dataset>/ is git-ignored.
parameter string PATH_PREFIX = $sformatf("%s/test/testbench_data/example/", `ROOT_DIR); // TODO: dataset

// ------------------------------------------------------------------
// system signals (provided by default_pkg)
// ------------------------------------------------------------------
logic        clk, rst, rst_n;
logic [63:0] clk_cnt;

assign clk     = sys_clk;
assign rst     = sys_rst;
assign rst_n   = sys_rst_n;
assign clk_cnt = sys_clk_cnt;

// ------------------------------------------------------------------
// DUT - instantiate your design with named ports
// ------------------------------------------------------------------
// <DutName> #(
//     .PARAM(PARAM)
// ) <DutName>_inst (
//     .clk(clk),
//     .rst(rst),
//     ...
// );

// Xilinx global-set/reset model is optional for simulations that use
// Xilinx primitives. Put glbl.v under lib/ and uncomment:
// `define XILINX_GLBL_ENABLE
// `ifdef XILINX_GLBL_ENABLE
//     glbl glbl_inst();
// `endif

// ------------------------------------------------------------------
// main initial: clock + reset + stimulus + watchdog
// ------------------------------------------------------------------
initial begin
    sys_clock_set(10);       // CLK_CYCLE = 10 time units (-timescale=1ps/1ps => 10 ps)
    sys_info_sim_start();
    fork
        main_procedure();
        task_watch_dog(WATCH_DOG_MAX_NUM);
        sys_clock_run();
        sys_count_run();
    join
end

// ------------------------------------------------------------------
// waveform dump -> tool/VCS/out/<tb name>.vcd
// ------------------------------------------------------------------
initial begin : dump_wave
    if (DUMP_WAVE_EN == 1 && DUMP_WAVE_TYPE == "vcd") begin
        string dump_path;
        dump_path = $sformatf("out/%s.vcd", get_testbench_name($sformatf("%m")));
        $dumpfile(dump_path);
        // Narrow down scopes for big designs: $dumpvars(1, `TB_MODULE_NAME.<inst>);
        $dumpvars(0, `TB_MODULE_NAME);
        $dumpon;
    end
    // FSDB output: set DUMP_WAVE_TYPE="fsdb", uncomment the block below and
    // compile with Verdi PLI available.
    // else if (DUMP_WAVE_TYPE == "fsdb") begin
    //     string dump_path;
    //     dump_path = $sformatf("out/%s.fsdb", get_testbench_name($sformatf("%m")));
    //     $fsdbDumpfile(dump_path);
    //     $fsdbDumpvars(0, `TB_MODULE_NAME);
    // end
end

// ------------------------------------------------------------------
// stimulus
// ------------------------------------------------------------------
task main_procedure();
    sys_reset(100);
    sys_delay(100);

    // TODO: drive inputs / wait for done signals, e.g.
    //     @(posedge <dut>_done);
    // Reading test data:
    //     $readmemh({PATH_PREFIX, "weights.txt"}, weight_mem);
    // Exporting results (compare outside the repository):
    //     $writememh({PATH_PREFIX, "dump_feat.txt"}, feat_mem);

    sys_set_color("blue");
    $display("Time:%8d\t clk-cnt:%8d (%m)", $time, sys_clk_cnt);
    sys_unset_color();

    sys_info_sim_end();
    $finish();
endtask

// ------------------------------------------------------------------
// watchdog: abort simulation if it runs too long
// ------------------------------------------------------------------
task task_watch_dog(input [63:0] max_time);
    sys_delay(max_time);
    sys_set_color("red");
    $display("ERROR: Watch dog timeout.");
    sys_unset_color();
    $finish();
endtask

endmodule
