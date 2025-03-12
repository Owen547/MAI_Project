`timescale 1ns / 1ps

module io_block #(WIDTH = 6) (
    input config_in,
    input config_clk,
    input config_en,
    output config_out,

    input [WIDTH - 1:0] data_in, cx_io, // cx_io is data from connector into io
    output [WIDTH - 1:0] data_out, io_cx // io_cx is data bus from io to cx

    );

    wire [(WIDTH*2) - 1:0] config_bits;

    genvar index;
    
    shift_reg #(
        .CONFIG_WIDTH(WIDTH*2)
    ) 
    config_mem (
        .config_in(config_in),
        .config_en(config_en),
        .config_clk(config_clk),
        .config_out(config_out),
        .config_bits(config_bits)
    );

    generate

    for (index=0; index<WIDTH; index=index+1) begin

        io io (

            .config_bits(config_bits[(index * 2) + 1 -: 2]),

            .data_in(data_in[index]), 
            .cx_io(cx_io[index]),

            .data_out(data_out[index]), 
            .io_cx(io_cx[index])

        );

    end

    endgenerate

endmodule