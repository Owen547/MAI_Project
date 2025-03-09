`timescale 1ns / 1ps

module io_block #(INPUT_WIDTH = 5, OUTPUT_WIDTH = 5) (
    input [] data_in,
    input [SEL - 1:0] sel,
    output data_out
    );
    
    wire integer index;
    
    assign index = sel;
    
    assign data_out = data_in[sel];
    
endmodule