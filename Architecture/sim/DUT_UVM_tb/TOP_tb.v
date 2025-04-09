`timescale 1ns / 1ps

module TOP_tb #(

    parameter MESH_SIZE_X = 3,  //declare number of CLB's in x axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
    parameter MESH_SIZE_Y = 3,  //declared in number of CLB's in y axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
        
    parameter CLB_NUM_BLE = 3,
    parameter CLB_NUM_INPUTS = 12,
    parameter CLB_TRACK_INPUTS = CLB_NUM_INPUTS/4,

    parameter SWBX_WIDTH = 5,

    parameter CX_INPUTS = (SWBX_WIDTH * 2) + (2 * CLB_NUM_BLE),
    parameter CX_LOG_INPUTS = $clog2(CX_INPUTS),  
    parameter CX_OUTPUTS = (2 * SWBX_WIDTH) + (2 * CLB_TRACK_INPUTS),

    parameter DATA_IN_WIDTH = CLB_TRACK_INPUTS,
    parameter DATA_OUT_WIDTH = CLB_NUM_BLE,
    parameter IO_WIDTH = ((DATA_IN_WIDTH + DATA_OUT_WIDTH) / 2) , //probably should be even seeing as I'm currently dividing the IO block into 2 for I and O.

    //bitstream param
    parameter IO_CONFIG_WIDTH = ((MESH_SIZE_X * 2 + MESH_SIZE_Y * 2) * IO_WIDTH * 2),
    parameter CLB_CONFIG_WIDTH = (MESH_SIZE_X * MESH_SIZE_Y * 267),
    parameter CX_CONFIG_WIDTH = ((((MESH_SIZE_Y+1) * MESH_SIZE_X) + ((MESH_SIZE_X+1) * MESH_SIZE_Y)) * 64),
    parameter SWBX_CONFIG_WIDTH = ((MESH_SIZE_Y+1) * (MESH_SIZE_X + 1) * 40),


    //useful sim params
    parameter CONFIG_WIDTH = IO_CONFIG_WIDTH + CLB_CONFIG_WIDTH + CX_CONFIG_WIDTH + SWBX_CONFIG_WIDTH,
    
    parameter DATA_OUT_WIRE_WIDTH = ((MESH_SIZE_X + MESH_SIZE_Y) * 2 * DATA_OUT_WIDTH),
    parameter DATA_IN_WIRE_WIDTH = ((MESH_SIZE_X + MESH_SIZE_Y) * 2 * DATA_IN_WIDTH)

    )

    ();

    wire config_in, config_clk, config_en, clk, config_out, expected_config_out, sim_done;

    wire [DATA_OUT_WIRE_WIDTH - 1:0] data_out, expected_dataout;
    wire [DATA_IN_WIRE_WIDTH - 1:0] data_in;
   
    TOP_STIM_GEN # (
    
    .DATA_IN_WIRE_WIDTH(DATA_IN_WIRE_WIDTH),
    .DATA_OUT_WIRE_WIDTH(DATA_OUT_WIRE_WIDTH),
    .CONFIG_WIDTH(CONFIG_WIDTH)
    
    ) stim_gen (
    
    .config_in(config_in),
    .config_clk(config_clk),
    .config_en(config_en),

    .clk(clk),
    .data_in(data_in),
    
    .expected_dataout(expected_dataout),
    .expected_config_out(expected_config_out),
    
    .sim_done(sim_done)
    
    );
    
    TOP_SCOREBOARD #(
    
    .DATA_IN_WIRE_WIDTH(DATA_IN_WIRE_WIDTH),
    .DATA_OUT_WIRE_WIDTH(DATA_OUT_WIRE_WIDTH),
    .CONFIG_WIDTH(CONFIG_WIDTH)
    
    ) scoreboard (
    
    .sim_done(sim_done),
    .dataout(data_out),
    .config_out(config_out),
    .clk(clk),
    .config_clk(config_clk),
    
    .expected_dataout(expected_dataout),
    .expected_config_out(expected_config_out)

    );
    
    top #(

    .MESH_SIZE_X(MESH_SIZE_X),
    .MESH_SIZE_Y(MESH_SIZE_Y),
    .CLB_NUM_BLE(CLB_NUM_BLE),
    .CLB_NUM_INPUTS(CLB_NUM_INPUTS),
    .CLB_TRACK_INPUTS(CLB_TRACK_INPUTS),
    .SWBX_WIDTH(SWBX_WIDTH),
    .CX_INPUTS(CX_INPUTS),
    .CX_LOG_INPUTS(CX_LOG_INPUTS),
    .CX_OUTPUTS(CX_OUTPUTS),
    .DATA_IN_WIDTH(DATA_IN_WIDTH),
    .DATA_OUT_WIDTH(DATA_OUT_WIDTH),
    .IO_WIDTH(IO_WIDTH)

    ) DUT (
    
    .config_in(config_in),
    .config_clk(config_clk),
    .config_en(config_en),
    .config_out(config_out),
    
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out)
    
    );
       
endmodule
