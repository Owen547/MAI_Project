`timescale 1ns / 1ps

module connector_box 
#(
    parameter INPUTS = 16, //this should be CLB outputs plus SWBX_WIDTH
    parameter LOG_INPUTS = $clog2(INPUTS),  
    parameter OUTPUTS = 16 //this should be CLB_track inputs plus SWBX WIDTH
)
(
    input config_in,
    input config_clk,
    input config_en,
    input sys_reset,
    output config_out,

    input [INPUTS-1:0] data_in,
    output [OUTPUTS-1:0] data_out
);

    wire [OUTPUTS:0] config_bus;
    assign config_bus[0] = config_in;
    assign config_out = config_bus[OUTPUTS];
    
    genvar index;

    generate

    for (index=0; index < OUTPUTS; index=index+1) begin

        prog_mux #(
            .SEL(LOG_INPUTS), 
            .INPUTS(INPUTS)
        ) 
        programmable_mux (
            .data_in(data_in),
            .config_in(config_bus[index]),
            .sys_reset(sys_reset),
            .config_clk(config_clk),
            .config_en(config_en),
            .data_out(data_out[index]),
            .config_out(config_bus[index + 1])
        );

    end

    endgenerate
    
endmodule