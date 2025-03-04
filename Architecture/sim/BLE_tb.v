`timescale 1ns / 1ps

module BLE_tb();

    reg config_in, config_clk, config_en;
    
    reg clk;
    
    reg [5:0] data_in;
    
    wire data_out, config_out;  
    
    reg [64:0] config_bits, previous_config;


    BLE UUT (
        .config_in(config_in),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_out),
        .clk(clk),
        .data_in(data_in),
        .data_out(data_out)
        );
    
    task configure_BLE (input [64:0] config_bits); 
    integer i;
    begin
       i = 0;
       config_en = 1;
       while (i < 65) begin
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
       
    task cycle_data_in (); begin
        while (data_in < 6'b111111) begin
            data_in = data_in + 1;
            #5;
        end
    end
    endtask
    
    task unenabled_config_changes ();
    integer j;
    begin
       j = 0;
       config_en = 0;
       while (j < 65) begin
            config_clk = 0;
            config_in = config_bits[j];
            #2;
            config_clk = 1;
            #2;
            j = j + 1;
       end
//       config_en = 0;
    end 
    endtask
    
    task check_config_out();
    integer k;
    reg [64:0] previous_config;
    begin
        k = 0;
        previous_config = config_bits;
        for (k = 0; k < 65; k = k + 1) begin
            config_en = 1;
            config_clk = 0;
            config_in = 0;
            #2;
            config_clk = 1;
            if (config_out != previous_config[k]) begin
               $display ("config out doesn't match the previous config");
               $stop;
            end
            #2;
        end
        config_en = 0;
        config_clk = 0;
   end
   endtask 
    
    
    initial begin
        clk <= 0;
        forever begin 
            #5;
            clk <= ~clk;
        end
    end     
    
    initial begin
        data_in = 0;
        config_en = 0;
        config_in = 0;
        config_clk = 0;
        config_bits = 65'b00000010000000000000010000000000000010000000000001000000001000000;
        configure_BLE(config_bits);
        #5;
        cycle_data_in();
        #5;
        previous_config = config_bits;
        unenabled_config_changes();
        #5;
        check_config_out();
        $finish();   
    end
        
        
endmodule
