`timescale 1ns / 1ps


module madd_top #(
    parameter WIDTH = 3
    )

    (
    output [(2*WIDTH)-1:0] s,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input [WIDTH-1:0] c,
    input clk
    );
    
    reg [WIDTH-1:0] a_pipe, b_pipe;
    reg [(2*WIDTH)-1:0] mult_result;
    reg [WIDTH-1:0] c_pipe_1, c_pipe_2;
    wire [(2*WIDTH)-1:0] mult_result_wire;

    assign s = c_pipe_2 + mult_result;
    assign mult_result_wire = a_pipe * b_pipe;

    always @(posedge clk) begin
        a_pipe <= a;
        b_pipe <= b;
        mult_result <= mult_result_wire;
        c_pipe_1 <= c;
        c_pipe_2 <= c_pipe_1;
    end




endmodule