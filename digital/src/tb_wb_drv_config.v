
//
// TESTBENCH FILE!!!
//

`timescale 1ns/1ns
`default_nettype none

module wb_drv_config_tb();


reg         tb_clk;
reg         tb_reset;
reg         tb_i_wb_cyc;
reg         tb_i_wb_stb;
reg         tb_i_wb_we;
reg [31:0]  tb_i_wb_addr;
reg [31:0]  tb_i_wb_data;
wire        tb_o_wb_ack;
wire        tb_o_wb_stall;
wire [31:0] tb_o_wb_data;

wire [15:0] tb_o_del_sync;
wire [15:0] tb_o_del_sync_inv;

wire [15:0] tb_o_del_p;
wire [15:0] tb_o_del_p_inv;

wire [15:0] tb_o_del_n;
wire [15:0] tb_o_del_n_inv;

wire [31:0] tb_o_current;


wb_drv_config #() DUT (
    tb_clk,
    tb_reset,
    tb_i_wb_cyc,
    tb_i_wb_stb,
    tb_i_wb_we,
    tb_i_wb_addr,
    tb_i_wb_data,
    tb_o_wb_ack,
    tb_o_wb_stall,
    tb_o_wb_data,
    tb_o_del_sync,
    tb_o_del_sync_inv,
    tb_o_del_p,
    tb_o_del_p_inv,
    tb_o_del_n,
    tb_o_del_n_inv,
    tb_o_current
    
    );

initial
    begin
        tb_clk          <=      0;
        tb_reset        <=      0;
        tb_i_wb_cyc     <=      1;
        tb_i_wb_stb     <=      1;
        tb_i_wb_we      <=      1;
        tb_i_wb_addr    <=      0;
        tb_i_wb_data    <=      0;



    end

initial
    begin
        #12
        tb_i_wb_addr = 'h0300_0000;
        tb_i_wb_data = 'hffff_ffff;
        #10
        tb_i_wb_addr = 'h0300_0000;
        tb_i_wb_data = 'h0000_0000;
        #10
        tb_i_wb_addr = 'h0300_0001;
        tb_i_wb_data = 'hffff_ffff;
        #10
        tb_i_wb_addr = 'h0300_0001;
        tb_i_wb_data = 'h0000_0000;
        #10
        tb_i_wb_addr = 'h0300_0002;
        tb_i_wb_data = 'hffff_ffff;
        #10
        tb_i_wb_addr = 'h0300_0002;
        tb_i_wb_data = 'h0000_0000;
        #10
        tb_i_wb_addr = 'h0300_0003;
        tb_i_wb_data = 'hffff_ffff;
        #10
        tb_i_wb_addr = 'h0300_0003;
        tb_i_wb_data = 'h0000_0000;

        #10
        tb_i_wb_addr = 'h0300_0000;
        tb_i_wb_data = 'h0000_0000;

        #50 $finish;

    end

always begin
    #5 tb_clk = ~tb_clk;
end

initial
    begin
        $dumpfile("./analysis/DUT.vcd");
        $dumpvars(0, DUT);
    end


endmodule