`timescale 1ns / 1ps

module adder_top(
    output cout, //MSB, determines if answer is positive or negative
    output [7:0] s,
    input [7:0] a,
    input [7:0] b,
    input cin, // if 1, subtract, if 0, add. This is XOR'ed with b
    input clk
    );
    
      
    wire [8:0] carry; 
    assign carry[0] = cin;

    genvar index;

    generate 

        for (index = 0; index < 8; index = index + 1) begin
            
            full_adder FA(.a(a[index]), .b(b[index]), .s(s[index]), .cin(carry[index]), .cout(carry[index+1]), .clk(clk));

        end 

    endgenerate
    
    assign cout = carry[8];
   
endmodule