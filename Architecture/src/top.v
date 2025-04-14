`timescale 1ns / 1ps

module top #(
        
    parameter MESH_SIZE_X = 7,  //declare number of CLB's in x axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
    parameter MESH_SIZE_Y = 7,  //declared in number of CLB's in y axis. Also minimum is 2, anything less and the "island-style" architecture isn't applicable/code doesnt work.
        
    parameter CLB_NUM_BLE = 3,
    parameter CLB_NUM_INPUTS = 12,
    parameter CLB_TRACK_INPUTS = CLB_NUM_INPUTS/4,

    parameter SWBX_WIDTH = 5,

    parameter CX_INPUTS = (SWBX_WIDTH * 2) + (2 * CLB_NUM_BLE),
    parameter CX_LOG_INPUTS = $clog2(CX_INPUTS),
    parameter CX_OUTPUTS = (2 * SWBX_WIDTH) + (2 * CLB_TRACK_INPUTS),

    parameter DATA_IN_WIDTH = CLB_TRACK_INPUTS,
    parameter DATA_OUT_WIDTH = CLB_NUM_BLE,
    parameter IO_WIDTH = (DATA_IN_WIDTH + DATA_OUT_WIDTH) / 2 //probably should be even seeing as I'm currently dividing the IO block into 2 for I and O.

    )

    (
        
    input config_in,
    input config_clk,
    input config_en,
    input clk,
    input sys_reset,
    input [((MESH_SIZE_X + MESH_SIZE_Y) * 2 * DATA_IN_WIDTH) - 1:0] data_in,
    output [((MESH_SIZE_X + MESH_SIZE_Y) * 2 * DATA_OUT_WIDTH) - 1:0] data_out,
    output config_out
        
    );

    wire [(MESH_SIZE_X * 2 + 1) * (MESH_SIZE_Y * 2 + 1) + (2 * MESH_SIZE_X) + (2 * MESH_SIZE_Y):0] config_bus;

    assign config_bus[0] = config_in;
    assign config_out = config_bus[(MESH_SIZE_X * 2 + 1) * (MESH_SIZE_Y * 2 + 1) + (2 * MESH_SIZE_X) + (2 * MESH_SIZE_Y)];

    wire [(CLB_NUM_INPUTS*MESH_SIZE_X*MESH_SIZE_Y) - 1 : 0] CLB_inputs;
    wire [(CLB_NUM_BLE * (MESH_SIZE_X * MESH_SIZE_Y)) - 1 : 0] CLB_outputs;
    wire [(SWBX_WIDTH*4*(MESH_SIZE_X + 1)*(MESH_SIZE_Y + 1)) - 1:0] SWBX_inputs;
    wire [(SWBX_WIDTH*4*(MESH_SIZE_X + 1)*(MESH_SIZE_Y + 1)) - 1:0] SWBX_outputs;
    wire [(DATA_IN_WIDTH) * (MESH_SIZE_X * 2) * (MESH_SIZE_Y * 2) - 1:0] io_cx;
    wire [(DATA_OUT_WIDTH) * (MESH_SIZE_X * 2) * (MESH_SIZE_Y * 2) - 1:0] cx_io;


    genvar y_index, x_index;

    generate

        localparam swbx_interval_x = 4 * SWBX_WIDTH;
        localparam swbx_interval_y = (MESH_SIZE_X+1) * 4 * SWBX_WIDTH;
        localparam swbx_config_interval_x = 2;
        localparam swbx_config_interval_y = ((MESH_SIZE_X * 2) + 1) + ((MESH_SIZE_X * 2) + 3);

        localparam swbx_config_offset = MESH_SIZE_X;
 

        for (y_index=0; y_index<(MESH_SIZE_Y + 1); y_index=y_index+1) begin : swbx_rows

            for (x_index=0; x_index<(MESH_SIZE_X + 1); x_index = x_index+1) begin : swbx_cols

                switch_box #(
                    .WIDTH(SWBX_WIDTH)
                ) switch_box(
                    .config_in(config_bus[swbx_config_offset + (y_index * swbx_config_interval_y) + (x_index * swbx_config_interval_x)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[swbx_config_offset + (y_index * swbx_config_interval_y) + (x_index * swbx_config_interval_x) + 1]),
                    .sys_reset(sys_reset),

                    .l_in(SWBX_inputs[(1 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),
                    .l_out(SWBX_outputs[(1 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),

                    .t_in(SWBX_inputs[(2 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),
                    .t_out(SWBX_outputs[(2 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),

                    .r_in(SWBX_inputs[(3 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),
                    .r_out(SWBX_outputs[(3 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),

                    .b_in(SWBX_inputs[(4 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH]),
                    .b_out(SWBX_outputs[(4 * SWBX_WIDTH) + (y_index * swbx_interval_y) + (x_index * swbx_interval_x) - 1 -: SWBX_WIDTH])
                );

            end

        end


        localparam clb_input_interval_y = MESH_SIZE_X * 4 * CLB_TRACK_INPUTS; //input interval between vertically adjacent CLB's
        localparam clb_input_interval_x = 4 * CLB_TRACK_INPUTS; //input interval between horizontally adjacent CLB's

        localparam clb_output_interval_x = CLB_NUM_BLE ; //output interval between vertically adjacent CLB's
        localparam clb_output_interval_y = MESH_SIZE_X * CLB_NUM_BLE; //output interval between vertically adjacent CLB's

        localparam clb_config_offset = MESH_SIZE_X + (MESH_SIZE_X * 2) + 3; // the config bus offset for the first CLB, i.e. the config bus index that enters the top left CLB
        localparam clb_config_interval_x = 2; //config interval between two horixontally adjacent CLB's
        localparam clb_config_interval_y = ((MESH_SIZE_X * 2) + 3) + ((MESH_SIZE_X * 2) + 1); //config bus index interval between two vertically adjacent CLB's


        for (y_index=0; y_index<MESH_SIZE_Y; y_index=y_index+1) begin : clb_rows

            for (x_index=0; x_index<MESH_SIZE_X; x_index = x_index+1) begin : clb_cols

                CLB #(
                    .NUM_BLE(CLB_NUM_BLE), 
                    .NUM_INPUTS(CLB_NUM_INPUTS)
                ) CLB ( 
                    .config_in(config_bus[clb_config_offset + (x_index * clb_config_interval_x) + (y_index * clb_config_interval_y)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[clb_config_offset + (x_index * clb_config_interval_x) + (y_index * clb_config_interval_y) + 1]),
                    .sys_reset(sys_reset),

                    .data_in({
                    //data in must be specified with left inputs in first position (0th -> xth bit), or specified last in the concatenation. This is the design convention
                    CLB_inputs[(4 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + (x_index * clb_input_interval_x) - 1 -: CLB_TRACK_INPUTS],
                    CLB_inputs[(3 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + (x_index * clb_input_interval_x) - 1 -: CLB_TRACK_INPUTS], 
                    CLB_inputs[(2 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + (x_index * clb_input_interval_x) - 1 -: CLB_TRACK_INPUTS],
                    CLB_inputs[(1 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + (x_index * clb_input_interval_x) - 1 -: CLB_TRACK_INPUTS]  
                    }),
                    .clk(clk),
                    // BLE outputs are specified here
                    .data_out(CLB_outputs[(1*CLB_NUM_BLE) + (y_index * clb_output_interval_y) + (x_index * clb_output_interval_x)- 1 -: CLB_NUM_BLE])
                );


            end

        end

        // unlike CLBs and SWBXs, IO and CXs have unique scenarios, on edge cases, where they need to be declared with different buses as input/output. 
        // This is due to IO occuring only on the edges and connecting to the adjacent connector box inside the design.
        // This is the reasoning for the different instantiations that are below.

        localparam io_config_offset_middle = MESH_SIZE_X + ((MESH_SIZE_X * 2) + 1);
        localparam io_config_interval_y_middle = ((MESH_SIZE_X * 2) + 3) + ((MESH_SIZE_X * 2) + 1);

        localparam io_data_in_offset_middle = (MESH_SIZE_X + 1) * DATA_IN_WIDTH;
        localparam io_data_out_offset_middle = (MESH_SIZE_X + 1) * DATA_OUT_WIDTH;
        
        localparam io_data_in_interval_y_middle = 2 * DATA_IN_WIDTH;
        localparam io_data_out_interval_y_middle = 2 * DATA_OUT_WIDTH;

        localparam right_io_config_offset = (MESH_SIZE_X * 2) + 2;

        localparam bottom_io_config_offset = MESH_SIZE_X + ((MESH_SIZE_X * 2) + 1) + (MESH_SIZE_Y * (((MESH_SIZE_X * 2) + 1) + ((MESH_SIZE_X * 2) + 3)));
        localparam bottom_io_data_in_offset = ((MESH_SIZE_X * DATA_IN_WIDTH) + (2 * MESH_SIZE_Y * DATA_IN_WIDTH) +  (1 * DATA_IN_WIDTH));
        localparam bottom_io_data_out_offset = ((MESH_SIZE_X * DATA_OUT_WIDTH) + (2 * MESH_SIZE_Y * DATA_OUT_WIDTH) +  (1 * DATA_OUT_WIDTH));


        for (y_index=0; y_index<(MESH_SIZE_Y+2); y_index=y_index+1) begin : io_rows

            if (y_index==0) begin

                for (x_index=0; x_index<MESH_SIZE_X; x_index=x_index+1) begin : io_cols

                    io_block #(
                        .WIDTH(IO_WIDTH)
                    )
                    io_top (
                        .config_in(config_bus[x_index]),
                        .config_clk(config_clk),
                        .config_en(config_en),
                        .config_out(config_bus[x_index + 1]),
                        .sys_reset(sys_reset),

                        .data_in(data_in[DATA_IN_WIDTH + (x_index * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH]), 
                        .cx_io(cx_io[DATA_OUT_WIDTH + (x_index * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH]),
                        .data_out(data_out[DATA_OUT_WIDTH + (x_index * DATA_OUT_WIDTH) - 1  -: DATA_OUT_WIDTH]), 
                        .io_cx(io_cx[DATA_IN_WIDTH + (x_index * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH])    
                    );

                end

            end

            else if ((y_index > 0) && (y_index < (MESH_SIZE_Y + 1))) begin
            
                io_block #(
                    .WIDTH(IO_WIDTH)
                )
                io_left (
                    .config_in(config_bus[io_config_offset_middle + ((y_index - 1) * io_config_interval_y_middle)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[io_config_offset_middle + ((y_index - 1) * io_config_interval_y_middle) + 1]),
                    .sys_reset(sys_reset),

                    .data_in(data_in[io_data_in_offset_middle + ((y_index - 1) * io_data_in_interval_y_middle) - 1 -: DATA_IN_WIDTH]), 
                    .cx_io(cx_io[io_data_out_offset_middle + ((y_index - 1) * io_data_out_interval_y_middle) - 1 -: DATA_OUT_WIDTH]),
                    .data_out(data_out[io_data_out_offset_middle + ((y_index - 1) * io_data_out_interval_y_middle) - 1 -: DATA_OUT_WIDTH]), 
                    .io_cx(io_cx[io_data_in_offset_middle + ((y_index - 1) * io_data_in_interval_y_middle) - 1 -: DATA_IN_WIDTH])    
                );

                io_block #(
                    .WIDTH(IO_WIDTH)
                )
                io_right (
                    .config_in(config_bus[io_config_offset_middle + ((y_index - 1) * io_config_interval_y_middle) + right_io_config_offset]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[io_config_offset_middle + ((y_index - 1) * io_config_interval_y_middle) + right_io_config_offset + 1]),
                    .sys_reset(sys_reset),

                    .data_in(data_in[io_data_in_offset_middle + ((y_index - 1) * io_data_in_interval_y_middle) + (1 * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH]), 
                    .cx_io(cx_io[io_data_out_offset_middle + ((y_index - 1) * io_data_out_interval_y_middle) + (1 * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH]),
                    .data_out(data_out[io_data_out_offset_middle + ((y_index - 1) * io_data_out_interval_y_middle) + (1 * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH]), 
                    .io_cx(io_cx[io_data_in_offset_middle + ((y_index - 1) * io_data_in_interval_y_middle) + (1 * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH])    
                );

            end

            else if (y_index == MESH_SIZE_Y + 1) begin

                for (x_index=0; x_index<MESH_SIZE_X; x_index=x_index+1) begin : io_cols

                    io_block #(
                        .WIDTH(IO_WIDTH)
                    )
                    io_bottom (
                        .config_in(config_bus[bottom_io_config_offset + x_index]),
                        .config_clk(config_clk),
                        .config_en(config_en),
                        .config_out(config_bus[bottom_io_config_offset + x_index + 1]),
                        .sys_reset(sys_reset),

                        .data_in(data_in[bottom_io_data_in_offset + (x_index * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH]), 
                        .cx_io(cx_io[bottom_io_data_out_offset + (x_index * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH]),
                        .data_out(data_out[bottom_io_data_out_offset + (x_index * DATA_OUT_WIDTH) - 1  -: DATA_OUT_WIDTH]), 
                        .io_cx(io_cx[bottom_io_data_in_offset + (x_index * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH])    
                    );

                end

            end

        end

        localparam top_cx_config_offset = MESH_SIZE_X + 1;

        for (x_index=0; x_index<MESH_SIZE_X; x_index=x_index+1) begin : cx_cols_top_row

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connector_box (
            .config_in(config_bus[top_cx_config_offset + (x_index * 2)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[top_cx_config_offset + (x_index * 2) + 1]),
            .sys_reset(sys_reset),

            .data_in({  
                        CLB_outputs[CLB_NUM_BLE + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                        SWBX_outputs[(5 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH],
                        io_cx[DATA_IN_WIDTH + (x_index * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH],  
                        SWBX_outputs[(3 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH]
                    }),

            .data_out({ 
                        CLB_inputs[(2 * CLB_TRACK_INPUTS) + (x_index * 4 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                        SWBX_inputs[(5 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH],
                        cx_io[DATA_OUT_WIDTH + (x_index * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH],
                        SWBX_inputs[(3 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH]
                    })
        ); 

        end

        localparam top_left_cx_config_offset = MESH_SIZE_X + (MESH_SIZE_X * 2 + 1) + 1;

        localparam config_interval_y = ((MESH_SIZE_X * 2) + 3) + ((MESH_SIZE_X * 2) + 1);

        for (y_index = 0; y_index <MESH_SIZE_Y;y_index = y_index + 1) begin : cx_rows_left_col

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connector_box (
            .config_in(config_bus[top_left_cx_config_offset + (y_index * config_interval_y)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[top_left_cx_config_offset + (y_index * config_interval_y) + 1]),
            .sys_reset(sys_reset),

            .data_in({  
                        SWBX_outputs[(2 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) - 1 -: SWBX_WIDTH],
                        CLB_outputs[CLB_NUM_BLE + (y_index * clb_output_interval_y) - 1 -: CLB_NUM_BLE],
                        SWBX_outputs[(4 * SWBX_WIDTH ) + (y_index * swbx_interval_y) - 1 -: SWBX_WIDTH],
                        io_cx[((MESH_SIZE_X + 1) * DATA_IN_WIDTH) + (y_index * DATA_IN_WIDTH * 2) - 1 -: DATA_IN_WIDTH]
                    }),

            .data_out({ 
                        SWBX_inputs[(2 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) - 1 -: SWBX_WIDTH],
                        CLB_inputs[(1 * CLB_TRACK_INPUTS) + (y_index *clb_input_interval_y) - 1 -: CLB_TRACK_INPUTS],
                        SWBX_inputs[(4 * SWBX_WIDTH ) + (y_index * swbx_interval_y) - 1 -: SWBX_WIDTH],
                        cx_io[((MESH_SIZE_X + 1) * DATA_OUT_WIDTH) + (y_index * DATA_OUT_WIDTH * 2) - 1 -: DATA_OUT_WIDTH]
                    })
        ); 

        end

        localparam top_right_cx_config_offset = MESH_SIZE_X + (MESH_SIZE_X * 2 + 1) + (MESH_SIZE_X * 2 + 1) ;

        for (y_index = 0; y_index <MESH_SIZE_Y;y_index = y_index + 1) begin : cx_rows_right_col

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connector_box (
            .config_in(config_bus[top_right_cx_config_offset + (y_index * config_interval_y)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[top_right_cx_config_offset + (y_index * config_interval_y) + 1]),
            .sys_reset(sys_reset),

            .data_in({  
                        SWBX_outputs[(2 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + (MESH_SIZE_X * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                        io_cx[((MESH_SIZE_X + 2) * DATA_IN_WIDTH) + (y_index * DATA_IN_WIDTH * 2) - 1 -: DATA_IN_WIDTH],
                        SWBX_outputs[(4 * SWBX_WIDTH ) + (y_index * swbx_interval_y) + (MESH_SIZE_X * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                        CLB_outputs[CLB_NUM_BLE + (y_index * clb_output_interval_y) + ((MESH_SIZE_X - 1) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE]
                    }),

            .data_out({ 
                        SWBX_inputs[(2 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + (MESH_SIZE_X * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                        cx_io[((MESH_SIZE_X + 2) * DATA_OUT_WIDTH) + (y_index * DATA_OUT_WIDTH * 2) - 1 -: DATA_OUT_WIDTH],
                        SWBX_inputs[(4 * SWBX_WIDTH ) + (y_index * swbx_interval_y) + (MESH_SIZE_X * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                        CLB_inputs[(3 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + ((MESH_SIZE_X - 1) * 4 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                    })
        ); 

        end

        localparam bottom_cx_config_offset = MESH_SIZE_X + (MESH_SIZE_Y * config_interval_y) + 1;

        for (x_index=0; x_index<MESH_SIZE_X; x_index=x_index+1) begin : cx_cols_bottom_row

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connector_box (
            .config_in(config_bus[bottom_cx_config_offset + (x_index * 2)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[bottom_cx_config_offset + (x_index * 2) + 1]),
            .sys_reset(sys_reset),

            .data_in({  
                        io_cx[DATA_IN_WIDTH + (x_index * DATA_IN_WIDTH) + (MESH_SIZE_X * DATA_IN_WIDTH) + (2 * MESH_SIZE_Y * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH],
                        SWBX_outputs[(5 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) + (MESH_SIZE_Y * swbx_interval_y) - 1 -: SWBX_WIDTH],
                        CLB_outputs[CLB_NUM_BLE + (x_index * CLB_NUM_BLE) + ((MESH_SIZE_Y- 1) * clb_output_interval_y) - 1 -: CLB_NUM_BLE],
                        SWBX_outputs[(3 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) + (MESH_SIZE_Y * swbx_interval_y) - 1 -: SWBX_WIDTH]
                    }),

            .data_out({ 
                        cx_io[DATA_OUT_WIDTH + (x_index * DATA_OUT_WIDTH) + (MESH_SIZE_X * DATA_IN_WIDTH) + (2 * MESH_SIZE_Y * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH],
                        SWBX_inputs[(5 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) + (MESH_SIZE_Y * swbx_interval_y)  - 1 -: SWBX_WIDTH],
                        CLB_inputs[(4 * CLB_TRACK_INPUTS) + (x_index * 4 * CLB_TRACK_INPUTS)+ ((MESH_SIZE_Y- 1) * clb_input_interval_y) - 1 -: CLB_TRACK_INPUTS],
                        SWBX_inputs[(3 * SWBX_WIDTH ) + (x_index * SWBX_WIDTH * 4) + (MESH_SIZE_Y * swbx_interval_y) - 1 -: SWBX_WIDTH]
                    })
        ); 

        end

        for (y_index=0; y_index<MESH_SIZE_Y; y_index=y_index+1) begin : cx_clb_rows

            for (x_index=1; x_index<MESH_SIZE_X; x_index=x_index+1) begin : cx_clb_cols

                connector_box #(
                    .LOG_INPUTS(CX_LOG_INPUTS),
                    .INPUTS(CX_INPUTS),
                    .OUTPUTS(CX_OUTPUTS)    
                ) connector_box (
                    .config_in(config_bus[top_left_cx_config_offset + (x_index * 2) + (y_index * config_interval_y)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[top_left_cx_config_offset + (x_index * 2) + (y_index * config_interval_y) + 1]),
                    .sys_reset(sys_reset),

                    .data_in({  
                                SWBX_outputs[(2 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH],
                                CLB_outputs[CLB_NUM_BLE + (y_index * clb_output_interval_y) + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                                SWBX_outputs[(4 * SWBX_WIDTH ) + (y_index * swbx_interval_y) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                CLB_outputs[CLB_NUM_BLE + (y_index * clb_output_interval_y) + ((x_index - 1) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE]
                            }),

                    .data_out({ 
                                SWBX_inputs[(2 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH],
                                CLB_inputs[CLB_TRACK_INPUTS + (y_index * clb_input_interval_y) + (x_index * 4 * CLB_TRACK_INPUTS)- 1 -: CLB_TRACK_INPUTS],
                                SWBX_inputs[(4 * SWBX_WIDTH ) + (y_index * swbx_interval_y) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                CLB_inputs[(3 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + ((x_index - 1) * 4 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                            })
                ); 

                end

        end
        
        localparam swbx_row_cx_config_offset = MESH_SIZE_X + config_interval_y + 1;

        for (y_index=0; y_index < MESH_SIZE_Y - 1; y_index=y_index+1) begin : cx_switch_rows

            for (x_index=0; x_index < MESH_SIZE_X; x_index=x_index+1) begin : cx_switch_cols

                connector_box #(
                    .LOG_INPUTS(CX_LOG_INPUTS),
                    .INPUTS(CX_INPUTS),
                    .OUTPUTS(CX_OUTPUTS)    
                ) connector_box (
                    .config_in(config_bus[swbx_row_cx_config_offset + (x_index * 2) + (y_index * config_interval_y)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[swbx_row_cx_config_offset + (x_index * 2) + (y_index  * config_interval_y) + 1]),
                    .sys_reset(sys_reset),

                    .data_in({  
                                CLB_outputs[CLB_NUM_BLE + ((y_index + 1) * clb_output_interval_y) + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                                SWBX_outputs[(1 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + ((x_index + 1) * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                CLB_outputs[CLB_NUM_BLE + (y_index * clb_output_interval_y) + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                                SWBX_outputs[(3 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH]
                            }),

                    .data_out({ 
                                CLB_inputs[(2 * CLB_TRACK_INPUTS) + ((y_index+1) * clb_input_interval_y) + (x_index * 4 * CLB_TRACK_INPUTS)- 1 -: CLB_TRACK_INPUTS],
                                SWBX_inputs[(1 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + ((x_index + 1) * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                CLB_inputs[(4 * CLB_TRACK_INPUTS) + (y_index * clb_input_interval_y) + (x_index * 4 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                                SWBX_inputs[(3 * SWBX_WIDTH ) + ((y_index+1) * swbx_interval_y) + (x_index * SWBX_WIDTH * 4) - 1 -: SWBX_WIDTH]
                            })
                ); 

                end

        end

    endgenerate

endmodule