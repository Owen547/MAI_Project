`timescale 1ns / 1ps

module io_block #(WIDTH = 8) (
    input config_in,
    input config_clk,
    input config_en,
    output config_out,

    input [WIDTH-1:0] data_in, cx_in,
    output [WIDTH-1:0] data_out, cx_out

    );

    wire [(WIDTH*2) - 1:0] config_bits;

    genvar index;

    generate

    shift_reg #(
        .CONFIG_WIDTH((WIDTH*2))
    ) 
    config_mem (
        .config_in(config_in),
        .config_en(config_en),
        .config_clk(config_clk),
        .config_out(config_out),
        .config_bits(config_bits)
    );

    for (index=0; index < WIDTH; index=index+1) begin

        io io (

            .config_bits(config_bits[((index+1) * 2) - 1 -: 2]),

            .data_in(data_in[index]), 
            .cx_in(cx_in[index]),
            .data_out(data_out[index]), 
            .cx_out(cx_out[index])

        );

    end

    endgenerate

endmodule