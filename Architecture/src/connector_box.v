`timescale 1ns / 1ps

module connector_box 
#(
    parameter INPUTS = 16,
    parameter LOG_INPUTS = $clog2(INPUTS),  
    parameter OUTPUTS = 16
)
(
    input config_in,
    input config_clk,
    input config_en,
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
            .config_clk(config_clk),
            .config_en(config_en),
            .data_out(data_out[index]),
            .config_out(config_bus[index + 1])
        );

    end

    endgenerate
    
endmodule