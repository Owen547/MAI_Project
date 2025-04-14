`timescale 1ns / 1ps

module shift_reg
    #(
    parameter CONFIG_WIDTH = 65 //this wont work for a bit width of 1.. special case in io..
    )

    (
    input config_in,
    input config_clk,
    input config_en,
    input sys_reset,

    output [CONFIG_WIDTH-1:0] config_bits,
    output config_out
    );

    reg [CONFIG_WIDTH-1:0] config_shift = 0;
    reg [CONFIG_WIDTH-1:0] config_mem = 0;

    always @(posedge config_clk, posedge sys_reset) begin

        if (sys_reset) begin
            config_shift <= 0;
        end

        else if (config_en == 1) begin
            config_shift <= {config_shift[CONFIG_WIDTH-2:0], config_in};
        end
    end

    always @(negedge config_en, posedge sys_reset) begin

        if (sys_reset) begin
            config_mem <= 0;
        end
        
        else begin
            config_mem <= config_shift;
        end
        
    end

    assign config_out = config_shift[CONFIG_WIDTH - 1];

    assign config_bits = config_mem;

endmodule