`timescale 1ns / 1ps


module CONNECTOR_BOX_tb();

reg config_in, config_clk, config_en;

reg [15:0] data_in;

wire [17:0] data_out;

wire config_out;  

reg [71:0] config_bits, previous_config;


connector_box #(
    .LOG_INPUTS(4),
    .INPUTS(16),
    .OUTPUTS(18)
) UUT (
    .config_in(config_in),
    .config_clk(config_clk),
    .config_en(config_en),
    .config_out(config_out),

    .data_in(data_in),
    .data_out(data_out)
);

    task configure_connector (input [71:0] config_bits); 
    integer i;
    begin
       i = 0;
       config_en = 1;
       while (i < 72) begin
            config_clk = 0;
            config_in = config_bits[i];
            #2;
            config_clk = 1;
            #2;
            i = i + 1;
       end
       config_en = 0;
       config_clk = 0;
    end 
    endtask

    task initialise_config_signals ();
    begin
        config_en = 0;
        config_in = 0;
        config_clk = 0;
    end
    endtask

    task cycle_data_in (); 
    begin
        while (data_in < 4'b1111) begin
            data_in = data_in + 1;
            #5;
        end
    end
    endtask

    initial begin
        initialise_config_signals();
        data_in = 0;
        config_bits = 72'b100011000000000000000000100011000000000000000000010000100111000000000000;
        configure_connector(config_bits);
        #5;
        data_in = 16'b0000000000001010;
//        cycle_data_in();
        #5;
        $finish();   
    end



endmodule
