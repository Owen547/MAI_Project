`timescale 1ns / 1ps

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