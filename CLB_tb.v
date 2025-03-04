`timescale 1ns / 1ps

module CLB_tb();

    reg config_in;
    reg config_clk;
    reg config_en;
    wire config_out;

    reg [11:0] data_in;
    reg clk;
    wire [2:0] data_out;
    reg [266:0] config_bits;

    CLB #(
        .NUM_INPUTS(12)
        )
        UUT (
        .config_in(config_in), 
        .config_clk(config_clk), 
        .config_en(config_en), 
        .config_out(config_out), 
        .data_in(data_in), 
        .clk(clk), 
        .data_out(data_out)
        );
    
    task configure_CLB (input [266:0] config_bits);
    integer i;
    begin
        i = 0;
        config_en = 1;
        while (i < 267) begin
                $monitor("Value of i is %d\nvalue of config_bit[i] is %b", i, config_bits[i]);
                config_clk = 0;
                config_in = config_bits[i];
                #2;
                config_clk = 1;
                #2;
                i = i + 1'd1;
        end
        config_en = 0;
        config_clk = 0;
        config_in = 0;
    end
    endtask

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        config_en = 0;
        data_in = 12'b000000000101;
        config_in = 0;
        config_bits = 267'b100011000000000000000000100011000000000000000000010000100111000000000000001100000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000110100100000000000000000000000000000000000000000000000000000000;
        #5;
        configure_CLB(config_bits);
        #15;
        $finish;

    end
endmodule
