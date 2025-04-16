`timescale 1ns / 1ps

module adder_top #(
    parameter WIDTH = 8
    )

    (
    output reg cout, //MSB, determines if answer is positive or negative
    output reg [WIDTH-1:0] s,
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input cin, // if 1, subtract, if 0, add. This is XOR'ed with b
    input clk
    );
    
      
    wire [WIDTH:0] carry; 
    assign carry[0] = cin;
    wire  [WIDTH-1:0] intermediate;
    genvar index;

    generate 

        for (index = 0; index < WIDTH; index = index + 1) begin
            
            full_adder FA(.a(a[index]), .b(b[index]), .s(intermediate[index]), .cin(carry[index]), .cout(carry[index+1]));

        end 

    endgenerate

    always @(posedge clk) begin
    
        s <= intermediate;
        cout <= carry[WIDTH];
        
    end
    

   
endmodule