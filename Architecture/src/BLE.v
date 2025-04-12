`timescale 1ns / 1ps

module BLE
#(

CONFIG_WIDTH = 65

)
(
    input config_in,
    input config_clk,
    input config_en,
    input sys_reset,

    output config_out,
    
    input clk,
    input [5:0] data_in,
    output reg data_out
);
    
    wire lut_out;
    
    reg flip_flop = 0;
    wire flip_flop_en;
    
    wire [CONFIG_WIDTH-1:0] config_bits;
    wire [CONFIG_WIDTH-2:0] config_bits_without_ff_enable;
       
    shift_reg config_bit_reg (
        .config_in(config_in),
        .config_en(config_en),
        .config_clk(config_clk),
        .config_out(config_out),
        .sys_reset(sys_reset),
        .config_bits(config_bits)
    );
    
    wire integer int_index;

    assign int_index = data_in;
    
    assign config_bits_without_ff_enable = config_bits [CONFIG_WIDTH - 1:1];

    assign lut_out = config_bits_without_ff_enable[int_index];

    assign flip_flop_en = config_bits[0];
    
    always @(posedge clk, posedge sys_reset) begin
        if (sys_reset) begin
            flip_flop <= 0;
        end

        else begin
            flip_flop <= lut_out;
        end

    end

    always @(*) begin
        if (flip_flop_en) begin
            data_out <= flip_flop;
        end else begin
            data_out <= lut_out;
        end
    end
    
endmodule
