`timescale 1ns / 1ps

module switch_box #(

    parameter WIDTH = 2

    )

    (

    input config_in,
    input config_clk,
    input config_en,
    input sys_reset,

    output config_out,

    input [WIDTH - 1:0] l_in,
    output [WIDTH - 1:0] l_out,

    input [WIDTH - 1:0] t_in,
    output [WIDTH - 1:0] t_out,

    input [WIDTH - 1:0] r_in,
    output [WIDTH - 1:0] r_out,

    input [WIDTH - 1:0] b_in,
    output [WIDTH - 1:0] b_out
    
    );

    localparam NUM_MUX = WIDTH * 4;
    
    wire [NUM_MUX:0]config_bus;
    assign config_bus[0] = config_in;
    assign config_out = config_bus[NUM_MUX];
    
    genvar index;

    generate
        
    for (index=0; index < WIDTH; index=index+1) begin
        
        wire [3:0] left   = { b_in[index], r_in[index], t_in[index], 1'b0 };
        wire [3:0] top    = { b_in[index], r_in[index], l_in[index], 1'b0 };
        wire [3:0] right  = { b_in[index], t_in[index], l_in[index], 1'b0 };
        wire [3:0] bottom = { r_in[index], t_in[index], l_in[index], 1'b0 };
        prog_mux #(2, 4) mux_left (
            .data_in(left),
            .config_in(config_bus[index * (WIDTH - 1)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .sys_reset(sys_reset),
            .data_out(l_out[index]),
            .config_out(config_bus[index * (WIDTH - 1) + 1]));
        prog_mux #(2, 4) mux_top (
            .data_in(top),
            .config_in(config_bus[index * (WIDTH - 1) + 1]),
            .config_clk(config_clk),
            .config_en(config_en),
            .sys_reset(sys_reset),
            .data_out(t_out[index]),
            .config_out(config_bus[index * (WIDTH - 1) + 2]));
        prog_mux #(2, 4) mux_right (
            .data_in(right),
            .config_in(config_bus[index * (WIDTH - 1) + 2]),
            .config_clk(config_clk),
            .config_en(config_en),
            .sys_reset(sys_reset),
            .data_out(r_out[index]),
            .config_out(config_bus[index * (WIDTH - 1) + 3]));
        prog_mux #(2, 4) mux_bottom (
            .data_in(bottom),
            .config_in(config_bus[index * (WIDTH - 1) + 3]),
            .config_clk(config_clk),
            .config_en(config_en),
            .sys_reset(sys_reset),
            .data_out(b_out[index]),
            .config_out(config_bus[index * (WIDTH - 1) + 4]));

    end

    endgenerate
    
endmodule