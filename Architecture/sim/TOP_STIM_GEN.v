`timescale 1ns / 1ps

module TOP_STIM_GEN #(
    
    parameter DATA_IN_WIRE_WIDTH = 0,
    parameter DATA_OUT_WIRE_WIDTH = 0,
    parameter CONFIG_WIDTH = 0
    
    )
    
    (
       
    output config_in,
    output config_clk,
    output config_en,
    output clk,
    output [DATA_IN_WIRE_WIDTH-1:0] data_in,
    
    output [DATA_OUT_WIRE_WIDTH-1:0] expected_dataout,
    output expected_config_out,
        
    output reg sim_done
    );

    reg [CONFIG_WIDTH - 1 : 0] config_bits, expected_config_mem;

    reg config_in, config_clk, config_en, clk;

    wire [DATA_IN_WIRE_WIDTH - 1:0] data_in;
    
    //declare and join up the target design here
    //easier than passing concatenated data_in/data_out values, but that would be the more universal approach. i.e 
    //it would be agnostic to the target design
    
    reg [7:0] a, b;
    reg cin;
    
    wire [7:0] expected_s;    
    wire expected_cout;
    
    adder_top target_design (
    .cout(expected_cout),
    .s(expected_s),
    .a(a),
    .b(b),
    .cin(cin),
    .clk(clk)
    );
             
    task initialise_signals ();
    begin
        expected_config_mem = 0;
        sim_done = 0;
        a = 8'b00000000;
        b = 8'b00000000;
        cin = 0;
        config_en = 0;
        config_in = 0;
        config_clk = 0;
    end
    endtask
    
    task handle_expected_config_mem(); 
    begin
    
        expected_config_mem <= {expected_config_mem[CONFIG_WIDTH-2:0], config_in};
     
    end 
    endtask

    task configure_top_module (input [CONFIG_WIDTH-1:0] config_bits); 
    integer i;
    begin
       i = 0;
       config_en = 1;
       while (i < CONFIG_WIDTH) begin
            config_clk = 0;
            config_in = config_bits[i];
            #2;
            config_clk = 1;
            handle_expected_config_mem();
            #2;
            i = i + 1;
       end
       config_en = 0;
       config_clk = 0;
    end 
    endtask

    task cycle_data_in(); begin
    
        a = 8'b00000000;
        while (a != 8'b11111111) begin
            b = 8'b00000000;  
            while (b != 8'b11111111) begin
                b = b + 1;
                #5;
            end
            a = a + 1;
            #5;
        end
        
    end
    endtask
    
    task cycle_data_in_a(); begin
        while (a != 8'b11111111) begin
            a = a + 1;
            #5;
        end
    end
    
    endtask

    task cycle_data_in_b(); begin
        while (b != 8'b11111111) begin
            b = b + 1;
            #5;
        end
    end
    endtask
   

    integer config_file, scan_file;
    
    initial begin

        config_file = $fopen("/home/owen/College/MAI_Project/VTR/Bit_gen/bitstream.txt", "r");

        if (config_file == 0) begin
            $display("bitstream file handle was NULL");
            $finish;
        end

        else begin
            scan_file = $fscanf(config_file, "%b\n", config_bits); 
        end

    end

    initial begin
        clk <= 0;
        forever begin 
            #5;
            clk <= ~clk;
        end
    end 
       
    assign data_in[0] = a[4];
    assign expected_dataout[0] = 0;
    assign data_in[1] = a[5];
    assign expected_dataout[1] = 0;
    assign expected_dataout[2] = 0;
    assign data_in[3] = b[5];
    assign expected_dataout[3] = 0;
    assign expected_dataout[4] = 0;
    assign data_in[5] = b[4];
    assign expected_dataout[5] = 0;
    assign expected_dataout[6] = 0;
    assign expected_dataout[7] = 0;
    assign expected_dataout[8] = 0;
    assign expected_dataout[9] = expected_s[5];
    assign expected_dataout[10] = expected_s[4];
    assign expected_dataout[11] = 0;
    assign expected_dataout[12] = 0;
    assign expected_dataout[13] = 0;
    assign expected_dataout[14] = 0;
    assign data_in[15] = a[6];
    assign expected_dataout[15] = 0;
    assign expected_dataout[16] = expected_s[6];
    assign data_in[17] = b[6];
    assign expected_dataout[17] = 0;
    assign expected_dataout[18] = expected_s[1];
    assign expected_dataout[19] = expected_s[3];
    assign expected_dataout[20] = expected_s[2];
    assign expected_dataout[21] = expected_s[7];
    assign expected_dataout[22] = expected_cout;
    assign data_in[23] = a[7];
    assign expected_dataout[23] = 0;
    assign data_in[24] = b[2];
    assign expected_dataout[24] = 0;
    assign expected_dataout[25] = expected_s[0];
    assign data_in[26] = a[3];
    assign expected_dataout[26] = 0;
    assign expected_dataout[27] = 0;
    assign data_in[28] = b[7];
    assign expected_dataout[28] = 0;
    assign data_in[29] = b[1];
    assign expected_dataout[29] = 0;
    assign data_in[30] = a[0];
    assign expected_dataout[30] = 0;
    assign data_in[31] = a[1];
    assign expected_dataout[31] = 0;
    assign data_in[32] = cin;
    assign expected_dataout[32] = 0;
    assign data_in[33] = a[2];
    assign expected_dataout[33] = 0;
    assign data_in[34] = b[0];
    assign expected_dataout[34] = 0;
    assign data_in[35] = b[3];
    assign expected_dataout[35] = 0;


    //assign expected config out
    assign expected_config_out = expected_config_mem[CONFIG_WIDTH-1];
    
    initial begin
        initialise_signals();
        configure_top_module(config_bits);
        #10;
        cycle_data_in();
        #10;
        configure_top_module(config_bits);
        #10;
        sim_done = 1;        
    end
    
endmodule
