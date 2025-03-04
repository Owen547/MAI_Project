`timescale 1ns / 1ps

module shift_reg
    #(
    parameter CONFIG_WIDTH = 65 // if this is declared below 3 could cause issues due to concatenation format for bit shifting.
    )

    (
    input config_in,
    input config_clk,
    input config_en,
    output [CONFIG_WIDTH-1:0] config_bits,
    output config_out
    );

    reg [CONFIG_WIDTH-1:0] config_shift = 0;
    reg [CONFIG_WIDTH-1:0] config_mem = 0;

    always @(posedge config_clk) begin
        if (config_en == 1) begin
            config_shift <= {config_shift[CONFIG_WIDTH-2:0], config_in};
        end
    end

    always @(negedge config_en) begin
        config_mem <= config_shift;
    end

    assign config_out = config_shift[CONFIG_WIDTH - 1];

    assign config_bits = config_mem;

endmodule