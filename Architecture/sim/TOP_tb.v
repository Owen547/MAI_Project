`timescale 1ns / 1ps

module TOP_tb #(

    parameter MESH_SIZE_X = 3,  //declare number of CLB's in x axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
    parameter MESH_SIZE_Y = 3,  //declared in number of CLB's in y axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
        
    parameter CLB_NUM_BLE = 3,
    parameter CLB_NUM_INPUTS = 12,
    parameter CLB_TRACK_INPUTS = CLB_NUM_INPUTS/4,

    parameter SWBX_WIDTH = 5,

    parameter CX_INPUTS = (SWBX_WIDTH * 2) + (2 * CLB_NUM_BLE),
    parameter CX_LOG_INPUTS = $clog2(CX_INPUTS),  
    parameter CX_OUTPUTS = (2 * SWBX_WIDTH) + (2 * CLB_TRACK_INPUTS),

    parameter DATA_IN_WIDTH = CLB_TRACK_INPUTS,
    parameter DATA_OUT_WIDTH = CLB_NUM_BLE,
    parameter IO_WIDTH = ((DATA_IN_WIDTH + DATA_OUT_WIDTH) / 2) , //probably should be even seeing as I'm currently dividing the IO block into 2 for I and O.

    //bitstream param
    parameter IO_CONFIG_WIDTH = ((MESH_SIZE_X * 2 + MESH_SIZE_Y * 2) * IO_WIDTH * 2),
    parameter CLB_CONFIG_WIDTH = (MESH_SIZE_X * MESH_SIZE_Y * 267),
    parameter CX_CONFIG_WIDTH = ((((MESH_SIZE_Y+1) * MESH_SIZE_X) + ((MESH_SIZE_X+1) * MESH_SIZE_Y)) * 64),
    parameter SWBX_CONFIG_WIDTH = ((MESH_SIZE_Y+1) * (MESH_SIZE_X + 1) * 40),

    parameter CONFIG_WIDTH = IO_CONFIG_WIDTH + CLB_CONFIG_WIDTH + CX_CONFIG_WIDTH + SWBX_CONFIG_WIDTH

    )

    (
        
    output [((MESH_SIZE_X + MESH_SIZE_Y) * 2 * DATA_OUT_WIDTH) - 1:0] data_out,
    output config_out
        
    );

    reg [CONFIG_WIDTH - 1 : 0] config_bits;

    reg config_in, config_clk, config_en, clk;

    wire [((MESH_SIZE_X + MESH_SIZE_Y) * 2 * DATA_IN_WIDTH) - 1:0] data_in;
    
    reg [7:0] a, b;
    
    reg cin;
    
    wire [7:0] s;
    
    wire cout;
   
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
    end 
    endtask

//    task cycle_data_in(input max_value); begin
//        while (a < max_value) begin
//            data_in = data_in + 1;
//            #5;
//        end
//    end
//    endtask

    temp_top #(

    .MESH_SIZE_X(MESH_SIZE_X),
    .MESH_SIZE_Y(MESH_SIZE_Y),
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
    

assign data_in[0] = a[7];
assign data_in[1] = b[6];
assign s[7] = data_out[3];
assign cout = data_out[4];
assign data_in[5] = a[4];
assign data_in[7] = b[4];
assign s[3] = data_out[10];
assign data_in[11] = b[7];
assign data_in[12] = a[6];
assign data_in[13] = a[5];
assign s[6] = data_out[14];
assign s[5] = data_out[18];
assign data_in[19] = b[5];
assign s[4] = data_out[20];
assign s[2] = data_out[21];
assign data_in[23] = a[3];
assign s[1] = data_out[26];
assign data_in[27] = b[2];
assign data_in[28] = b[3];
assign data_in[29] = a[2];
assign data_in[30] = a[1];
assign data_in[31] = b[1];
assign data_in[32] = b[0];
assign data_in[33] = a[0];
assign data_in[34] = cin;
assign s[0] = data_out[35];

wire [2:0] example1, example2;

wire [5:0] catcher;

assign example1 = 3'b000;
assign example2 = 3'b111;

assign catcher = {example1, example2};

    initial begin
    
        initialise_config_signals();
        configure_top_module(config_bits);
        cin = 0;
        a = 8'b11111111;
        b = 8'b11111011;
        #20;
        $finish;
        
    end
    
endmodule
