`timescale 1ns / 1ps

module TOP_STIM_GEN #(
    
    parameter DATA_IN_WIRE_WIDTH = 0,
    parameter DATA_OUT_WIRE_WIDTH = 0,
    parameter CONFIG_WIDTH = 0,
    parameter CONFIG_CLOCK_PERIOD = 100
    
    )
    
    (
       
    output reg config_in,
    output reg config_clk,
    output reg config_en,
    output reg clk,
    output reg sys_reset,
    output reg [DATA_IN_WIRE_WIDTH-1:0] data_in,
    
    output [DATA_OUT_WIRE_WIDTH-1:0] expected_dataout,
    output expected_config_out,
        
    output reg sim_done,
    
    output integer current_clock,
    output reg clock_finished,
    input clock_result
    
    
    );

    reg [CONFIG_WIDTH - 1 : 0] config_bits, expected_config_mem;            
           
    task sys_init();
    begin
    initialise_signals();
    #1;
    sys_reset <= 0;
    config_en <= 1;
    repeat(5) begin
        @(negedge config_clk);
    end
    config_en <= 0;
    end
    endtask      

    task initialise_signals ();
    begin
        sys_reset <= 1;
        expected_config_mem <= 0;
        sim_done <= 0;
        data_in <= 0;
        config_en <= 0;
        config_in <= 0;
        config_clk <= 0;
        current_clock = 375;
        clock_finished = 0;
    end
    endtask

    task configure_top_module (input [CONFIG_WIDTH-1:0] config_bits); 
    begin
       i = 0;
       config_en <= 1;
       while (i < CONFIG_WIDTH) begin
            @(negedge config_clk) config_in <= config_bits[i];
            i = i + 1;
       end
       @(negedge config_clk) config_en <= 0;
    end 
    endtask 
       
    integer sentinel, i;
    
    task cycle_data_in(input integer cycles); begin
        data_in <= 0;
        repeat (2) @(posedge clk);
        @(negedge clk);
        for (sentinel = 0;sentinel < cycles;sentinel = sentinel + 1) begin
            randomise_data_in();
            @(negedge clk);
        end
    end
    endtask
    
    task randomise_data_in(); begin

        for (i = 0;i<DATA_IN_WIRE_WIDTH; i = i + 1) begin
        
            if (i == 14) begin
                data_in[i] <= 0;
            end
            else begin
                data_in[i] <= $urandom_range(1);
            end

        end
        
        
    end
    endtask
    
    integer current, last, step, upper, lower;
    
    task find_max_clock(input integer cycles); begin
        current = 375;
        lower = 0;
        upper = 750;
        last = 0;
        step = 375;
        while ((step > 0) && (current > 4)) begin
        
            clock_finished <= 0;
            data_in = 0;
            current_clock <= current;
            repeat(2) @(negedge clk); 
            cycle_data_in(cycles);
            
            data_in = 0;
            clock_finished <= 1;
            #5;
            
            if (clock_result) begin
                last = current;
                current = current - ((current - lower)/2);
                upper = last;
                step = last - current;
            end
            
            else begin
                last = current;
                current = current + ((upper - current)/2);
                lower = last;
                step = current - last;
            end
           
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
            #((current_clock/2) - 1);
            #1;
            clk <= ~clk;
        end
    end 
    
    initial begin 
        config_clk <= 1;
            forever begin
            #(CONFIG_CLOCK_PERIOD/2);
            config_clk <= ~config_clk;
            end
    end   
    
    always @(posedge config_clk) begin
        if (config_en) begin 
            expected_config_mem <= {expected_config_mem[CONFIG_WIDTH-2:0], config_in};
        end
    end  
    
    //////////////////////// Add assigns and signal declarations for target design here
assign expected_dataout[0] = 0;

assign expected_dataout[1] = expected_s[2];

assign expected_dataout[2] = 0;

assign a[2] = data_in[3];

assign expected_dataout[3] = 0;

assign a[3] = data_in[4];

assign expected_dataout[4] = 0;

assign b[3] = data_in[5];

assign expected_dataout[5] = 0;

assign b[1] = data_in[6];

assign expected_dataout[6] = 0;

assign a[0] = data_in[7];

assign expected_dataout[7] = 0;

assign cin = data_in[8];

assign expected_dataout[8] = 0;

assign a[4] = data_in[9];

assign expected_dataout[9] = 0;

assign b[0] = data_in[10];

assign expected_dataout[10] = 0;

assign a[1] = data_in[11];

assign expected_dataout[11] = 0;

assign b[5] = data_in[12];

assign expected_dataout[12] = 0;

assign expected_dataout[13] = expected_s[5];

assign b[4] = data_in[14];

assign expected_dataout[14] = 0;

assign expected_dataout[15] = 0;

assign expected_dataout[16] = expected_s[3];

assign expected_dataout[17] = 0;

assign expected_dataout[18] = expected_s[6];

assign a[5] = data_in[19];

assign expected_dataout[19] = 0;

assign expected_dataout[20] = expected_s[4];

assign expected_dataout[21] = 0;

assign expected_dataout[22] = 0;

assign expected_dataout[23] = 0;

assign expected_dataout[24] = expected_s[7];

assign a[7] = data_in[25];

assign expected_dataout[25] = 0;

assign a[6] = data_in[26];

assign expected_dataout[26] = 0;

assign expected_dataout[27] = 0;

assign expected_dataout[28] = 0;

assign expected_dataout[29] = 0;

assign expected_dataout[30] = 0;

assign expected_dataout[31] = 0;

assign expected_dataout[32] = 0;

assign expected_dataout[33] = 0;

assign expected_dataout[34] = 0;

assign expected_dataout[35] = 0;

assign expected_dataout[36] = 0;

assign expected_dataout[37] = 0;

assign b[2] = data_in[38];

assign expected_dataout[38] = 0;

assign expected_dataout[39] = expected_s[1];

assign expected_dataout[40] = expected_s[0];

assign expected_dataout[41] = 0;

assign b[7] = data_in[42];

assign expected_dataout[42] = 0;

assign expected_dataout[43] = 0;

assign expected_dataout[44] = 0;

assign expected_dataout[45] = expected_cout;

assign expected_dataout[46] = 0;

assign b[6] = data_in[47];

assign expected_dataout[47] = 0;

wire [7:0] expected_s;

wire [7:0] a;

wire [7:0] b;

wire [0:0] cin;

wire [0:0] expected_cout;

    //////////////////////// Instantiate target design to capture expected outputs

//    adder_top target_design (
//    .cout(expected_cout),
//    .s(expected_s),
//    .a(a),
//    .b(b),
//    .cin(cin),
//    .clk(clk)
//    );

    madd_top target_design (
    .s(expected_s),
    .a(a),
    .b(b),
    .c(c),
    .clk(clk)
    );

    ////////////////////////

    //assign expected config out
    assign expected_config_out = expected_config_mem[CONFIG_WIDTH-1];
    
    initial begin
        sys_init();
        configure_top_module(config_bits);
        #10;
        find_max_clock(500);
        #10;
        configure_top_module(config_bits);
        #10;
        sim_done <= 1;        
    end
    
endmodule
