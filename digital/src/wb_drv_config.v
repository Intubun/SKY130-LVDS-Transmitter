`default_nettype none
`timescale 1ns/1ns

/*

Based on https://github.com/mattvenn/wishbone_buttons_leds/

*/


module wb_drv_config #(
        
        // -----     Address config for the Wishbone bus     -----
        
        //Config for the baseaddress for all registers (offset for all adresses)
        parameter [31:0]    BASE_ADDRESS        = 32'h0300_0000,

        // Address for the Delay Cells (both output will delay in sync, for multichannel data coms)
        parameter [31:0]    DELAY_SYNC_ADDRESS  = BASE_ADDRESS,

        // Address for the Delay Cells (P outputs, upper 2 Byte Pullup and lower 2 Byte Pulldown, high means active)
        parameter [31:0]    DELAY_P_ADDRESS     = BASE_ADDRESS+1,
    
        // Address for the Delay Cells (N Output, upper 2 Byte Pullup and lower 2 Byte Pulldown, high means active)
        parameter [31:0]    DELAY_N_ADDRESS     = BASE_ADDRESS+2,

        // Address for the steering current (Number of high bits * 0.5mA)
        parameter [31:0]    DRV_CURRENT         = BASE_ADDRESS+3
    
    ) (
    `ifdef USE_POWER_PINS
        inout vccd1,    // User area 1 1.8V supply
        inout vssd1,    // User area 1 digital ground
    `endif

        //Clock signal
        input wire      clk,

        //Reset all
        input wire      reset,

        // -----     Wishbone Interface     -----

        input wire          i_wb_cyc,       // wishbone transaction
        input wire          i_wb_stb,       // strobe (data valid and accepted as long as !o_wb_stall)
        input wire          i_wb_we,        // write enable (HIGH: Read/Write, LOW: Read only)
        input wire [31:0]   i_wb_addr,      // address line
        input wire [31:0]   i_wb_data,      // input data (write)

        output reg          o_wb_ack,       // req is completed
        output wire          o_wb_stall,     // cannot accept req
        output reg [31:0]   o_wb_data,      // output data (read)

        // -----     Delay Config     -----

        output reg [15:0]   o_del_sync,     // syncronous delay for both outputs (Pulldowns)
        output reg [15:0]   o_del_sync_inv, // syncronous delay for both outputs (Pullups)

        output reg [15:0]   o_del_p,        // differential delay for the positive output (Pulldowns)
        output reg [15:0]   o_del_p_inv,    // differential delay for the positive output (Pullups)

        output reg [15:0]   o_del_n,        // differential delay for the negative output (Pulldowns)
        output reg [15:0]   o_del_n_inv,    // differential delay for the negative output (Pullups)

        // -----     Output Drive current     -----
        
        output reg [31:0]   o_current      // output current adjustment (enable extra current mirrors, 0.25mA / active Bit)

    );

    
    initial begin
        o_del_sync      <=  'hffff_0000;
        o_del_sync_inv  <=  'h0000_ffff;
        o_del_p         <=  'hffff_0000;
        o_del_p_inv     <=  'h0000_ffff;
        o_del_n         <=  'hffff_0000;
        o_del_n_inv     <=  'h0000_ffff;
        o_current       <=  'h0000_0000;
    end

    assign o_wb_stall = 0;


    // writes
    always @(posedge clk) begin
        if(reset) begin
            o_del_sync      <=  'hffff_0000;
            o_del_sync_inv  <=  'h0000_ffff;
            o_del_p         <=  'hffff_0000;
            o_del_p_inv     <=  'h0000_ffff;
            o_del_n         <=  'hffff_0000;
            o_del_n_inv     <=  'h0000_ffff;
            o_current      <=  1;
            
            
        end else if(i_wb_stb && i_wb_cyc && i_wb_we && !o_wb_stall) begin
            if(i_wb_addr == DELAY_SYNC_ADDRESS) begin
                o_del_sync      <=  i_wb_data[15:0];
                o_del_sync_inv  <=  ~i_wb_data[31:16];
            end
            if(i_wb_addr == DELAY_P_ADDRESS) begin
                o_del_p         <=  i_wb_data[15:0];
                o_del_p_inv     <=  ~i_wb_data[31:16];
            end
            if(i_wb_addr == DELAY_N_ADDRESS) begin
                o_del_n         <=  i_wb_data[15:0];
                o_del_n_inv     <=  ~i_wb_data[31:16];
            end
            if(i_wb_addr == DRV_CURRENT) begin
                o_current      <=  i_wb_data;
            end
        end
    end

    //reads
    always @(posedge clk) begin
        if(reset) begin
            o_wb_data   <= 0;
        end else if (i_wb_stb && i_wb_cyc && !i_wb_we && !o_wb_stall) begin
            if(i_wb_addr == DELAY_SYNC_ADDRESS) begin
                o_wb_data <= {o_del_sync, o_del_sync_inv};
            end
            if(i_wb_addr == DELAY_P_ADDRESS) begin
                o_wb_data <= {o_del_p, o_del_p_inv};
            end
            if(i_wb_addr == DELAY_N_ADDRESS) begin
                o_wb_data <= {o_del_n, o_del_n_inv};
            end
            if(i_wb_addr == DRV_CURRENT) begin
                o_wb_data <= o_current;
            end
        end
    
    end

    //ack
    always @(posedge clk) begin
        if(reset)
            o_wb_ack <= 0;
        else
            o_wb_ack <= (i_wb_stb && !o_wb_stall && (i_wb_addr == DELAY_SYNC_ADDRESS || i_wb_addr == DELAY_P_ADDRESS || i_wb_addr == DELAY_N_ADDRESS || i_wb_addr == DRV_CURRENT));

    end


endmodule