`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2016 01:26:30 PM
// Design Name: 
// Module Name: full_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module full_adder(
    output reg cout,
    output reg s,
    input a,
    input b,
    input cin,
    input clk,
    input reset
    );

    wire [1:0] intermediate;

    always @(posedge clk, reset) begin

            s = intermediate[0];
            cout = intermediate[1];

    end

    assign intermediate = a + b + cin;


endmodule