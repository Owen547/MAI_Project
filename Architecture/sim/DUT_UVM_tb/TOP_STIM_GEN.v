`timescale 1ns / 1ps

module TOP_STIM_GEN #(
    
    parameter DATA_IN_WIRE_WIDTH = 0,
    parameter DATA_OUT_WIRE_WIDTH = 0,
    parameter CONFIG_WIDTH = 0
    
    )
    
    (
       
    output reg config_in,
    output reg config_clk,
    output reg config_en,
    output reg clk,
    output [DATA_IN_WIRE_WIDTH-1:0] data_in,
    
    output [DATA_OUT_WIRE_WIDTH-1:0] expected_dataout,
    output expected_config_out,
        
    output reg sim_done
    );

    reg [CONFIG_WIDTH - 1 : 0] config_bits, expected_config_mem;

    reg reset;
    
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
    .clk(clk),
    .reset(reset)
    );
             
    task initialise_signals ();
    begin
        expected_config_mem <= 0;
        sim_done <= 0;
        a <= 8'b00000000;
        b <= 8'b00000000;
        cin <= 0;
        config_en <= 0;
        config_in <= 0;
        config_clk <= 0;
    end
    endtask

    task configure_top_module (input [CONFIG_WIDTH-1:0] config_bits); 
    integer i;
    begin
       i = 0;
       config_en <= 1;
       while (i < CONFIG_WIDTH) begin
            @(negedge config_clk) config_in <= config_bits[i];
            i = i + 1;
       end
       @(negedge config_clk) config_en <= 0;;
    end 
    endtask
    
    task randomise_cin(); begin
        cin <= $urandom_range(1);            
    end 
    endtask
    
    
    integer sentinel;
    
    task cycle_data_in(); begin
        sentinel = 1;
        reset <= 0;
        a <= 8'b00000000;
        b <= 8'b00000000;   
        repeat (2) @(posedge clk);
        #5;
        randomise_cin();
        cycle_data_in_b();
        while (sentinel) begin
            b <= 8'b00000000; 
            a <= a + 1;
            randomise_cin();
            #10;
            cycle_data_in_b();
            if (a == 8'b11111111) begin
                sentinel = 0;           
            end
         end
    end
    endtask
    
    task cycle_data_in_a(); begin
        while (a != 8'b11111111) begin
            a <= a + 1;
            #10;
        end
    end
    
    endtask

    task cycle_data_in_b(); begin
        while (b != 8'b11111111) begin
            b <= b + 1;
            #10;
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
    
    initial begin 
        config_clk <= 1;
            forever begin
            #1;
            config_clk <= ~config_clk;
            end
    end   
    
    always @(posedge config_clk) begin
        if (config_en) begin 
            expected_config_mem <= {expected_config_mem[CONFIG_WIDTH-2:0], config_in};
        end
    end  
        

    assign data_in[0] = b[6];
    assign expected_dataout[0] = 0;
    assign data_in[1] = b[7];
    assign expected_dataout[1] = 0;
    assign expected_dataout[2] = 0;
    assign data_in[3] = a[7];
    assign expected_dataout[3] = 0;
    assign expected_dataout[4] = expected_s[7];
    assign data_in[5] = a[5];
    assign expected_dataout[5] = 0;
    assign data_in[6] = b[3];
    assign expected_dataout[6] = 0;
    assign expected_dataout[7] = 0;
    assign data_in[8] = a[3];
    assign expected_dataout[8] = 0;
    assign expected_dataout[9] = expected_cout;
    assign expected_dataout[10] = expected_s[6];
    assign data_in[11] = a[6];
    assign expected_dataout[11] = 0;
    assign data_in[12] = b[4];
    assign expected_dataout[12] = 0;
    assign data_in[13] = b[5];
    assign expected_dataout[13] = 0;
    assign data_in[14] = a[4];
    assign expected_dataout[14] = 0;
    assign expected_dataout[15] = 0;
    assign data_in[16] = a[2];
    assign expected_dataout[16] = 0;
    assign expected_dataout[17] = 0;
    assign data_in[18] = reset;
    assign expected_dataout[18] = 0;
    assign expected_dataout[19] = expected_s[4];
    assign expected_dataout[20] = 0;
    assign expected_dataout[21] = 0;
    assign expected_dataout[22] = expected_s[0];
    assign expected_dataout[23] = 0;
    assign expected_dataout[24] = 0;
    assign expected_dataout[25] = expected_s[5];
    assign expected_dataout[26] = expected_s[3];
    assign data_in[27] = b[1];
    assign expected_dataout[27] = 0;
    assign expected_dataout[28] = expected_s[1];
    assign expected_dataout[29] = expected_s[2];
    assign data_in[30] = a[0];
    assign expected_dataout[30] = 0;
    assign data_in[31] = b[0];
    assign expected_dataout[31] = 0;
    assign data_in[32] = cin;
    assign expected_dataout[32] = 0;
    assign expected_dataout[33] = 0;
    assign data_in[34] = b[2];
    assign expected_dataout[34] = 0;
    assign data_in[35] = a[1];
    assign expected_dataout[35] = 0;
    

    //assign expected config out
    assign expected_config_out = expected_config_mem[CONFIG_WIDTH-1];
    
    initial begin
        reset = 1;
        initialise_signals();
        configure_top_module(config_bits);
        #10;
        cycle_data_in();
        #10;
        configure_top_module(config_bits);
        #10;
        sim_done <= 1;        
    end
    
endmodule
