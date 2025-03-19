`timescale 1ns / 1ps

module TEST_TOP_tb #(

    parameter MESH_SIZE_X = 6,  //declare number of CLB's in x axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
    parameter MESH_SIZE_Y = 6,  //declared in number of CLB's in y axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
        
    parameter CLB_NUM_BLE = 3,
    parameter CLB_NUM_INPUTS = 12,
    parameter CLB_TRACK_INPUTS = CLB_NUM_INPUTS/4,

    parameter SWBX_WIDTH = 5,

    parameter CX_INPUTS = (SWBX_WIDTH * 2) + (2 * CLB_NUM_BLE),
    parameter CX_LOG_INPUTS = $clog2(CX_INPUTS),  
    parameter CX_OUTPUTS = (2 * SWBX_WIDTH) + (2 * CLB_TRACK_INPUTS),

    parameter DATA_IN_WIDTH = CLB_TRACK_INPUTS,
    parameter DATA_OUT_WIDTH = CLB_NUM_BLE,
    parameter IO_WIDTH = ((DATA_IN_WIDTH + DATA_OUT_WIDTH) / 2) //probably should be even seeing as I'm currently dividing the IO block into 2 for I and O.

    // //bitstream param
    // parameter IO_CONFIG_WIDTH = ((MESH_SIZE_X * 2 + MESH_SIZE_Y * 2) * IO_WIDTH * 2),
    // parameter CLB_CONFIG_WIDTH = (MESH_SIZE_X * MESH_SIZE_Y * 267),
    // parameter CX_CONFIG_WIDTH = ((((MESH_SIZE_Y+1) * MESH_SIZE_X) + ((MESH_SIZE_X+1) * MESH_SIZE_Y)) * 64),
    // parameter SWBX_CONFIG_WIDTH = ((MESH_SIZE_Y+1) * (MESH_SIZE_X + 1) * 40),

    // parameter CONFIG_WIDTH = IO_CONFIG_WIDTH + CLB_CONFIG_WIDTH + CX_CONFIG_WIDTH + SWBX_CONFIG_WIDTH

    )

    (
        
    output [11:0] data_out,
    output config_out
        
    );
    
    localparam CONFIG_WIDTH = 707;

    reg [CONFIG_WIDTH - 1 : 0] config_bits;

    reg config_in, config_clk, config_en, clk;

    reg [11:0] data_in;
   
    task initialise_config_signals ();
    begin
        config_en = 0;
        config_in = 0;
        config_clk = 0;
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
            #2;
            i = i + 1;
       end
       config_en = 0;
       config_clk = 0;
       #5;
    end 
    endtask

    task cycle_data_in(input max_value); begin
        while (data_in < max_value) begin
            data_in = data_in + 1;
            #5;
        end
    end
    endtask

    test_top #(

    .CLB_NUM_BLE(CLB_NUM_BLE),
    .CLB_NUM_INPUTS(CLB_NUM_INPUTS),
    .CLB_TRACK_INPUTS(CLB_TRACK_INPUTS),
    .SWBX_WIDTH(SWBX_WIDTH),
    .CX_INPUTS(CX_INPUTS),
    .CX_LOG_INPUTS(CX_LOG_INPUTS),
    .CX_OUTPUTS(CX_OUTPUTS),
    .DATA_IN_WIDTH(DATA_IN_WIDTH),
    .DATA_OUT_WIDTH(DATA_OUT_WIDTH),
    .IO_WIDTH(IO_WIDTH)

    ) DUT (
    
    .config_in(config_in),
    .config_clk(config_clk),
    .config_en(config_en),
    .config_out(config_out),
    
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out)
    
    );
    
    integer config_file, scan_file;
    
    initial begin

        config_file = $fopen("/home/owen/College/MAI_Project/VTR/Bit_gen/temp_config.txt", "r");

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
    
    assign s[7] = data_out[3];
    assign s[3] = data_out[10];
    // assign cout
    assign s[1] = data_out [26];

    initial begin
        data_in = 0;
        a = 8'b00000001;
        b = 8'b00000001;
        data_in[31] = a[0];
        data_in[30] = b[0];

        initialise_config_signals();
        configure_top_module(config_bits);
        #5;
        data_in [11:10] = 2'b11;
        #15;
//        cycle_data_in((2**8) - 1);
        $finish;
    end
    
endmodule
