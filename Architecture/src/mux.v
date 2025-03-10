`timescale 1ns / 1ps

module mux #(parameter SEL = 4, parameter INPUTS = 16) (
    input [INPUTS - 1:0] data_in,
    input [SEL - 1:0] sel,
    output data_out
    );
    
    wire integer index;
    
    assign index = sel;
    
    assign data_out = data_in[sel];
    
endmodule