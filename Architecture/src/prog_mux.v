`timescale 1ns / 1ps

module prog_mux 
#(
    parameter SEL = 4, 
    parameter INPUTS = 16
) 
(
    
    input config_in,
    input config_clk,
    input config_en,
    output config_out,

    input [INPUTS-1:0] data_in,
    output data_out
    
);

    wire [SEL-1:0] config_bits;
    
    shift_reg #(
        .CONFIG_WIDTH(SEL)
    ) 
    config_mem (
        .config_in(config_in),
        .config_en(config_en),
        .config_clk(config_clk),
        .config_out(config_out),
        .config_bits(config_bits)
        );
    
    mux #(SEL, INPUTS) mux_i(
        .data_in(data_in),
        .sel(config_bits),
        .data_out(data_out));
        
endmodule