`timescale 1ns / 1ps

module mux #(parameter SEL = 4, parameter INPUTS = 16) (
    input [INPUTS - 1:0] data_in,
    input [SEL - 1:0] sel,
    output data_out
    );
    
//    genvar index;
//    generate
//    for (index = 0; index < INPUTS; index = index + 1) begin
//        assign data_out = (sel == index) ? data_in[index] : 1'dz;
//    end
//    endgenerate
    
    wire integer index;
    
    assign index = sel;
    
    assign data_out = data_in[sel];
    
endmodule