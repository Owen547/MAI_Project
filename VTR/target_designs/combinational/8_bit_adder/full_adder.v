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
    output cout,
    output s,
    input a,
    input b,
    input cin
    );

    wire [1:0] intermediate;

    assign intermediate = a + b + cin;

    assign s = intermediate[0];
    assign cout = intermediate[1];

endmodule