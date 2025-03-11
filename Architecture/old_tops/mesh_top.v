`timescale 1ns / 1ps

module mesh_top #(
    
   parameter MESH_SIZE = 10,  //declared in number of CLB's in one axis. Also minimum is 2, anything less and the architecture isn't applicable/code doesnt work.
    
   parameter CLB_NUM_BLE = 3,
   parameter CLB_NUM_INPUTS = 12,
   parameter CLB_TRACK_INPUTS = CLB_NUM_INPUTS/4,
   parameter CX_LOG_INPUTS = 4, 
   parameter CX_INPUTS = 16, 
   parameter CX_OUTPUTS = 16,
   parameter SWBX_WIDTH = 5,
   parameter DATA_IN_WIDTH = 5,
   parameter DATA_OUT_WIDTH = 5

   )

   (
    
   input config_in,
   input config_clk,
   input config_en,
   input clk,
   input [(MESH_SIZE-1)*4*DATA_IN_WIDTH:0] data_in, //mesh size minus 1 is number of cx on each side. times 4 for 4 sides. times datain in widtrh for number of data in.
   output [(MESH_SIZE-1)*4*DATA_OUT_WIDTH:0] data_out,
   output config_out
    
   );
    
    wire [CLB_TRACK_INPUTS-1:0] single_track_zeros;
    assign single_track_zeros = 0;

    wire [((MESH_SIZE*2)-1)**2:0] config_bus;
    assign config_bus[0] = config_in;
    assign config_out = config_bus[((MESH_SIZE*2)-1)**2];

    wire [CLB_NUM_INPUTS*(MESH_SIZE**2)-1:0] CLB_inputs;
    wire [CLB_NUM_BLE*(MESH_SIZE**2)-1:0] CLB_outputs;
    wire [SWBX_WIDTH*4*((MESH_SIZE-1)**2)-1:0] SWBX_inputs;
    wire [SWBX_WIDTH*4*((MESH_SIZE-1)**2)-1:0] SWBX_outputs;

    genvar y_index, x_index;

    generate

        //top row
        
        //top row - left corner case
        CLB #(
            .NUM_BLE(CLB_NUM_BLE), 
            .NUM_INPUTS(CLB_NUM_INPUTS)
        ) CLB_top_left ( 
            .config_in(config_bus[0]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[1]),

            .data_in({
                single_track_zeros, 
                single_track_zeros, 
                CLB_inputs[CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS], 
                CLB_inputs[(2*(CLB_TRACK_INPUTS)) - 1 -: CLB_TRACK_INPUTS]
                }),
            .clk(clk),
            .data_out(CLB_outputs[CLB_NUM_BLE - 1 -: CLB_NUM_BLE])
        );

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connection_box_top_left (
            .config_in(config_bus[1]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[2]),

            .data_in(   {CLB_outputs[CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                        data_in[DATA_IN_WIDTH - 1 -: DATA_IN_WIDTH],
                        CLB_outputs[2*CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                        SWBX_outputs[2*SWBX_WIDTH - 1 -: SWBX_WIDTH]}),

            .data_out(  {CLB_inputs[CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS], 
                        data_out[DATA_OUT_WIDTH - 1 -: DATA_OUT_WIDTH],
                        CLB_inputs[(CLB_TRACK_INPUTS*3) - 1 -: CLB_TRACK_INPUTS], 
                        SWBX_inputs[(2*SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                        })
        );

        // top row - edge cases

        for (x_index=1; x_index < MESH_SIZE-1; x_index=x_index+1) begin

            CLB #(
                .NUM_BLE(CLB_NUM_BLE), 
                .NUM_INPUTS(CLB_NUM_INPUTS)
            ) CLB_top_row ( 
                .config_in(config_bus[2 * x_index]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[2 * x_index + 1]),

                .data_in({  CLB_inputs[(CLB_TRACK_INPUTS*3*x_index) - 1 -: CLB_TRACK_INPUTS],
                            single_track_zeros,
                            CLB_inputs[(CLB_TRACK_INPUTS*3*x_index) + CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS],
                            CLB_inputs[(CLB_TRACK_INPUTS*3*x_index) + (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                        }),
                .clk(clk),
                .data_out(CLB_outputs[(x_index*CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE])
            );

            connector_box #(
                .LOG_INPUTS(CX_LOG_INPUTS),
                .INPUTS(CX_INPUTS),
                .OUTPUTS(CX_OUTPUTS)    
            ) connection_box_top_row (
                .config_in(config_bus[2 * x_index + 1]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[2 * (x_index + 1)]),

                .data_in(   {CLB_outputs[(CLB_NUM_BLE * x_index) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE], 
                            data_in[(DATA_IN_WIDTH * x_index) +  DATA_IN_WIDTH - 1 -: DATA_IN_WIDTH],
                            CLB_outputs[(CLB_NUM_BLE * x_index) + (2 * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                            SWBX_outputs[(4 * x_index * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                            }),

                .data_out(  {CLB_inputs[CLB_TRACK_INPUTS + (3 * x_index * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            data_out[(DATA_OUT_WIDTH * x_index) +  DATA_OUT_WIDTH - 1 -: DATA_OUT_WIDTH], 
                            CLB_inputs[CLB_TRACK_INPUTS + (3 * x_index * CLB_TRACK_INPUTS) + (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            SWBX_inputs[(4 * x_index * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]})
            );
    
        end

        //top row - right corner case

        CLB #(
            .NUM_BLE(CLB_NUM_BLE), 
            .NUM_INPUTS(CLB_NUM_INPUTS)
        ) CLB_top_right ( 
            .config_in(config_bus[2*MESH_SIZE-2]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[2*MESH_SIZE-1]),

            .data_in({  CLB_inputs[(CLB_TRACK_INPUTS * 3 * (MESH_SIZE-1)) - 1 -: CLB_TRACK_INPUTS],
                        single_track_zeros,
                        single_track_zeros,
                        CLB_inputs[(CLB_TRACK_INPUTS * 3 * (MESH_SIZE-1)) + CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS]
                    }),
            .clk(clk),
            .data_out(CLB_outputs[(MESH_SIZE * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
        );

        //top second row - left edge

        //top second row offsets
        localparam TOP_SECOND_ROW_CLB_INPUT_TRACK_OFFSET = ((((MESH_SIZE - 2) * 3) + 5) * CLB_TRACK_INPUTS); // this is the index for the bottom output of the first connector in the second row ie left edge connector. This is the input of first CLB in third row.

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connection_box_top_second_row_left (
            .config_in(config_bus[2*MESH_SIZE-1]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[2*MESH_SIZE]),

            .data_in({  data_in[((MESH_SIZE-1) * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH],
                        CLB_outputs[CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                        SWBX_outputs[SWBX_WIDTH - 1 -: SWBX_WIDTH],
                        CLB_outputs[(MESH_SIZE * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE]}),

            .data_out({ data_out[((MESH_SIZE-1) * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH], 
                        CLB_inputs[(CLB_TRACK_INPUTS*2) - 1 -: CLB_TRACK_INPUTS], 
                        SWBX_inputs[SWBX_WIDTH - 1 -: SWBX_WIDTH],
                        CLB_inputs[((5 + ((MESH_SIZE - 2) * 3)) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                        })
        );

        switch_box #(
        .WIDTH(SWBX_WIDTH)
        ) switch_box_top_second_row_left (
            .config_in(config_bus[2*MESH_SIZE]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[2*MESH_SIZE+1]),

            .l_in(SWBX_inputs[SWBX_WIDTH - 1 -: SWBX_WIDTH]),
            .l_out(SWBX_outputs[SWBX_WIDTH - 1 -: SWBX_WIDTH]),

            .t_in(SWBX_inputs[SWBX_WIDTH*2 - 1 -: SWBX_WIDTH]),
            .t_out(SWBX_outputs[SWBX_WIDTH*2 - 1 -: SWBX_WIDTH]),

            .r_in(SWBX_inputs[SWBX_WIDTH*3 - 1 -: SWBX_WIDTH]),
            .r_out(SWBX_outputs[SWBX_WIDTH*3 - 1 -: SWBX_WIDTH]),

            .b_in(SWBX_inputs[SWBX_WIDTH*4 - 1 -: SWBX_WIDTH]),
            .b_out(SWBX_outputs[SWBX_WIDTH*4 - 1 -: SWBX_WIDTH])
        );

        //top second row - middle case

        for (x_index=1; x_index < MESH_SIZE-1; x_index=x_index+1) begin

            connector_box #(
                .LOG_INPUTS(CX_LOG_INPUTS),
                .INPUTS(CX_INPUTS),
                .OUTPUTS(CX_OUTPUTS)    
            ) connection_box_top_second_row_middle (
                .config_in(config_bus[2*MESH_SIZE+(x_index*2)-1]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[2*MESH_SIZE+(x_index*2)]),

                .data_in({  SWBX_outputs[((((x_index - 1) * 4) + 3) * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                            CLB_outputs[((x_index + 1) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                            SWBX_outputs[(((x_index * 4) * SWBX_WIDTH) + SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                            CLB_outputs[((MESH_SIZE + x_index + 1) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE]}),

                .data_out({ SWBX_inputs[((((x_index - 1) * 4) + 3) * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                            CLB_inputs[((2+(x_index*3)) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            SWBX_inputs[(((x_index * 4) * SWBX_WIDTH) + SWBX_WIDTH) - 1 -: SWBX_WIDTH], 
                            CLB_inputs[(TOP_SECOND_ROW_CLB_INPUT_TRACK_OFFSET) + (x_index * 4 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                            })
            );

            switch_box #(
            .WIDTH(SWBX_WIDTH)
            ) switch_box_top_second_row_middle (
                .config_in(config_bus[2*MESH_SIZE+(x_index*2)]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[2*MESH_SIZE+(x_index*2)+1]),

                .l_in(SWBX_inputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH - 1 -: SWBX_WIDTH]),
                .l_out(SWBX_outputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH - 1 -: SWBX_WIDTH]),

                .t_in(SWBX_inputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH*2 - 1 -: SWBX_WIDTH]),
                .t_out(SWBX_outputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH*2 - 1 -: SWBX_WIDTH]),

                .r_in(SWBX_inputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH*3 - 1 -: SWBX_WIDTH]),
                .r_out(SWBX_outputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH*3 - 1 -: SWBX_WIDTH]),

                .b_in(SWBX_inputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH*4 - 1 -: SWBX_WIDTH]),
                .b_out(SWBX_outputs[(4 * SWBX_WIDTH * x_index) + SWBX_WIDTH*4 - 1 -: SWBX_WIDTH])
            );

        end

        //second row  - right edge

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connection_box_top_second_row_right (
            .config_in(config_bus[5 + ((MESH_SIZE - 2) * 4)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[(5 + ((MESH_SIZE - 2) * 4)) + 1]),

            .data_in({  SWBX_outputs[((((MESH_SIZE - 1) * 4) - 1) * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                        CLB_outputs[((MESH_SIZE) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                        data_in[((MESH_SIZE + 1) * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH],
                        CLB_outputs[((2*MESH_SIZE) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE]}),

            .data_out({ SWBX_inputs[((((MESH_SIZE - 1) * 4) - 1) * SWBX_WIDTH) - 1-: SWBX_WIDTH],
                        CLB_inputs[(CLB_TRACK_INPUTS * 3 * (MESH_SIZE-1)) + CLB_TRACK_INPUTS - 1  -: CLB_TRACK_INPUTS], 
                        data_out[((MESH_SIZE + 1) * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH], 
                        CLB_inputs[TOP_SECOND_ROW_CLB_INPUT_TRACK_OFFSET + ((4 + (MESH_SIZE-2) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                        })
        );


        // //middle rows
        localparam MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET = TOP_SECOND_ROW_CLB_INPUT_TRACK_OFFSET; // this is the first input track of the first middle row left CLB
        localparam MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET = (MESH_SIZE + 1) * CLB_NUM_BLE; // this is the bottom left CLB output offset
        localparam MIDDLE_ROW_SWBX_TRACK_OFFSET = 4 * SWBX_WIDTH; // this is the middle output/input track of the first left edge middle row connector.. it wont be on the edge it will be one in
        localparam MIDDLE_CONFIG_BUS_OFFSET = 6 + ((MESH_SIZE - 2) * 4); // this is the config bus that goes into the first middle row left edge CLB
        localparam MIDDLE_DATA_IN_OFFSET = (((MESH_SIZE - 1)) + 2) *  DATA_IN_WIDTH;// this is the data in for the first middle left edge connector
        localparam MIDDLE_DATA_OUT_OFFSET = (((MESH_SIZE - 1)) + 2) *  DATA_OUT_WIDTH;// this is the data out for the first middle left edge connector

        localparam MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL = (6 + ((MESH_SIZE - 2) * 4)) * CLB_TRACK_INPUTS; // this is the vertical interval of CLB input tracks between middle rows
        localparam MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL = MESH_SIZE * CLB_NUM_BLE; // this is the vertical interval between middle rows CLB output values
        localparam MIDDLE_ROW_SWBX_TRACK_INTERVAL = ((MESH_SIZE - 1) * 4) * SWBX_WIDTH; // this is the vertical value interval of the output/input track of swbxs in the mniddle rows
        localparam MIDDLE_CONFIG_BUS_INTERVAL = (MESH_SIZE * 2) - 1; // this is the interval between config bus values that go into the middle row left edge block
        localparam MIDDLE_DATA_IN_INTERVAL = 2 *  DATA_IN_WIDTH;// this is the interval between data in values vertically in the middle section
        localparam MIDDLE_DATA_OUT_INTERVAL = 2 *  DATA_OUT_WIDTH;// this is the interval between data out values vertically in the middle section

        for (y_index=1; y_index < MESH_SIZE - 1; y_index=y_index+1) begin

            //middle row

            //middle row - left edge 
            CLB #(
                .NUM_BLE(CLB_NUM_BLE), 
                .NUM_INPUTS(CLB_NUM_INPUTS)
            ) CLB_middle_left ( 
                .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + (((y_index-1) * 2) * MIDDLE_CONFIG_BUS_INTERVAL)]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + (((y_index-1) * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + 1]),

                .data_in({
                    single_track_zeros, 
                    CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) - 1 -: CLB_TRACK_INPUTS],
                    CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (1 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                    CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (2 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                    }),
                .clk(clk),
                .data_out(CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) - 1 -: CLB_NUM_BLE])
            );

            connector_box #(
                .LOG_INPUTS(CX_LOG_INPUTS),
                .INPUTS(CX_INPUTS),
                .OUTPUTS(CX_OUTPUTS)    
            ) connection_box_middle_left (
                .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + (((y_index-1) * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + 1]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + (((y_index-1) * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + 2]),

                .data_in({  CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) - 1  -: CLB_NUM_BLE],
                            SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - 1 -: SWBX_WIDTH],
                            CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + (1*CLB_NUM_BLE) + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) - 1  -: CLB_NUM_BLE],
                            SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                }),

                .data_out({ CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (1 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - 1 -: SWBX_WIDTH],
                            CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + (2 * CLB_TRACK_INPUTS) + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) - 1  -: CLB_TRACK_INPUTS], 
                            SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                            })
            );

            //middle row - second row - left edge

            connector_box #(
                .LOG_INPUTS(CX_LOG_INPUTS),
                .INPUTS(CX_INPUTS),
                .OUTPUTS(CX_OUTPUTS)    
            ) connection_box_middle_second_row_left (
                .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((((y_index-1) * 2) + 1) * MIDDLE_CONFIG_BUS_INTERVAL)]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((((y_index-1) * 2) + 1) * MIDDLE_CONFIG_BUS_INTERVAL) + 1]),

                .data_in({  data_in[MIDDLE_DATA_IN_OFFSET + ((y_index-1) * MIDDLE_DATA_IN_INTERVAL) - 1 -: DATA_IN_WIDTH],  
                            CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) - 1  -: CLB_NUM_BLE],
                            SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                            CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) - 1  -: CLB_NUM_BLE]
                }),

                .data_out({ data_out[MIDDLE_DATA_OUT_OFFSET + ((y_index-1) * MIDDLE_DATA_OUT_INTERVAL) - 1 -: DATA_OUT_WIDTH], 
                            CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + (2 * CLB_TRACK_INPUTS) + ((y_index - 1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) - 1  -: CLB_TRACK_INPUTS], 
                            SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - 1 -: SWBX_WIDTH],
                            CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) - 1  -: CLB_TRACK_INPUTS] 
                            })
            );

            switch_box #(
            .WIDTH(SWBX_WIDTH)
            ) switch_box_middle_second_row_left (
                .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((((y_index-1) * 2) + 1) * MIDDLE_CONFIG_BUS_INTERVAL) + 1]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((((y_index-1) * 2) + 1) * MIDDLE_CONFIG_BUS_INTERVAL) + 2]),

                .l_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                .l_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                .t_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                .t_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                .r_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                .r_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                .b_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - 1 -: SWBX_WIDTH]),
                .b_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - 1 -: SWBX_WIDTH])
            );

            // //middle rows - central

            for (x_index=1; x_index < MESH_SIZE - 1; x_index=x_index+1) begin

                CLB #(
                    .NUM_BLE(CLB_NUM_BLE), 
                    .NUM_INPUTS(CLB_NUM_INPUTS)
                ) CLB_middle ( 
                    .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + (x_index * 2)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + (x_index * 2) + 1]),

                    .data_in({
                        CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET +  (3 * CLB_TRACK_INPUTS) + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (((x_index - 1) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET +  (3 * CLB_TRACK_INPUTS) + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + ((1 + (x_index - 1) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                        CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET +  (3 * CLB_TRACK_INPUTS) + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + ((2 + (x_index - 1) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                        CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET +  (3 * CLB_TRACK_INPUTS) + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + ((3 + (x_index - 1) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                        }),
                    .clk(clk),
                    .data_out(CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
                );

                connector_box #(
                    .LOG_INPUTS(CX_LOG_INPUTS),
                    .INPUTS(CX_INPUTS),
                    .OUTPUTS(CX_OUTPUTS)    
                ) connection_box_middle (
                    .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + (x_index * 2) + 1]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + (x_index * 2) + 2]),

                    .data_in({  CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) + (x_index * CLB_NUM_BLE) - 1  -: CLB_NUM_BLE],
                                SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) + ((x_index + 1) * CLB_NUM_BLE) - 1  -: CLB_NUM_BLE],
                                SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                    }),

                    .data_out({ CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + CLB_TRACK_INPUTS + (((x_index - 1) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                                SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (3 * CLB_TRACK_INPUTS) + (((x_index - 1) * 4) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                                SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                                })
                );

                // middle row - second row - central
                connector_box #(
                    .LOG_INPUTS(CX_LOG_INPUTS),
                    .INPUTS(CX_INPUTS),
                    .OUTPUTS(CX_OUTPUTS)    
                ) connection_box_middle_second_row (
                    .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL))  + MIDDLE_CONFIG_BUS_INTERVAL + (x_index * 2)]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + MIDDLE_CONFIG_BUS_INTERVAL + (x_index * 2) + 1]),

                    .data_in({  SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (4 * (x_index - 1) * SWBX_WIDTH) - SWBX_WIDTH - 1 -: SWBX_WIDTH],  
                                CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index - 1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) + (x_index * CLB_NUM_BLE) - 1  -: CLB_NUM_BLE],
                                SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (4 * (x_index - 1) * SWBX_WIDTH) + SWBX_WIDTH - 1 -: SWBX_WIDTH],  
                                CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) + (x_index * CLB_NUM_BLE) - 1  -: CLB_NUM_BLE]
                    }),
                    
                    .data_out({ SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (4 * (x_index - 1) * SWBX_WIDTH) - SWBX_WIDTH - 1 -: SWBX_WIDTH], 
                                CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + (2 * CLB_TRACK_INPUTS) + ((y_index - 1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (x_index * 4 * CLB_TRACK_INPUTS) - 1  -: CLB_TRACK_INPUTS], 
                                SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (4 * (x_index - 1) * SWBX_WIDTH) + SWBX_WIDTH - 1 -: SWBX_WIDTH],
                                CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) - 1  -: CLB_TRACK_INPUTS] 
                                })
                );

                switch_box #(
                .WIDTH(SWBX_WIDTH)
                ) switch_box_middle_second_row (
                    .config_in(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + MIDDLE_CONFIG_BUS_INTERVAL + (x_index * 2) + 1]),
                    .config_clk(config_clk),
                    .config_en(config_en),
                    .config_out(config_bus[MIDDLE_CONFIG_BUS_OFFSET + ((y_index-1) * (2 * MIDDLE_CONFIG_BUS_INTERVAL)) + MIDDLE_CONFIG_BUS_INTERVAL + (x_index * 2) + 2]),

                    .l_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (3 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                    .l_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (3 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                    .t_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                    .t_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                    .r_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (1 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                    .r_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (1 * SWBX_WIDTH) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                    .b_in(SWBX_inputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                    .b_out(SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + (y_index * MIDDLE_ROW_SWBX_TRACK_INTERVAL) + (x_index * 4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH])
                );


            end

            //middle rows - right edge
            // issues in both right edge cases!!
            CLB #(
                .NUM_BLE(CLB_NUM_BLE), 
                .NUM_INPUTS(CLB_NUM_INPUTS)
            ) CLB_middle_right ( 
                .config_in(config_bus[((y_index * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + MIDDLE_CONFIG_BUS_INTERVAL - 1]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[((y_index * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + MIDDLE_CONFIG_BUS_INTERVAL]),

                .data_in({
                    CLB_inputs[(((4 * 2) + (3 * (MESH_SIZE-2) * 3) + 4 * ((MESH_SIZE-2)**2)) * CLB_TRACK_INPUTS) - (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                    CLB_inputs[(((4 * 2) + (3 * (MESH_SIZE-2) * 3) + 4 * ((MESH_SIZE-2)**2)) * CLB_TRACK_INPUTS) - (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                    single_track_zeros,
                    CLB_inputs[(((4 * 2) + (3 * (MESH_SIZE-2) * 3) + (4 * ((MESH_SIZE-2)**2))) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                    }),
                .clk(clk),
                .data_out(CLB_outputs[((MESH_SIZE * (y_index + 1)) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
            );

            //middle rows - second row - right edge

            connector_box #(
                .LOG_INPUTS(CX_LOG_INPUTS),
                .INPUTS(CX_INPUTS),
                .OUTPUTS(CX_OUTPUTS)    
            ) connection_box_middle_middle (
                .config_in(config_bus[((y_index * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + (2 * MIDDLE_CONFIG_BUS_INTERVAL) - 1]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[((y_index * 2) * MIDDLE_CONFIG_BUS_INTERVAL) + (2 * MIDDLE_CONFIG_BUS_INTERVAL)]),

                .data_in({  CLB_outputs[((MESH_SIZE * (MESH_SIZE - 1)) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                            SWBX_outputs[((((MESH_SIZE - 1)**2)*4)-1)-: SWBX_WIDTH],
                            CLB_outputs[MIDDLE_ROW_CLB_OUTPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_OUTPUT_TRACK_INTERVAL) - 1  -: CLB_NUM_BLE],
                            SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                }),

                .data_out({ CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + CLB_TRACK_INPUTS + CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS], 
                            SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - 1 -: SWBX_WIDTH],
                            CLB_inputs[MIDDLE_ROW_CLB_INPUT_TRACK_OFFSET + ((y_index-1) * MIDDLE_ROW_CLB_INPUT_TRACK_INTERVAL) + (3 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            SWBX_outputs[MIDDLE_ROW_SWBX_TRACK_OFFSET + ((y_index) * MIDDLE_ROW_SWBX_TRACK_INTERVAL) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                            })
            );

        end

       // bottom row - left edge

        //bottom row offsets
        localparam BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET = (TOP_SECOND_ROW_CLB_INPUT_TRACK_OFFSET) + (((MESH_SIZE - 2) * (6 + ((MESH_SIZE - 2) * 4))) * CLB_TRACK_INPUTS) ; // this is the first input track of the botttom left CLB
        localparam BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET = (((MESH_SIZE - 1) * MESH_SIZE) + 1) * CLB_NUM_BLE; // this is the bottom left CLB output offset
        localparam BOTTOM_ROW_SWBX_TRACK_OFFSET = (((MESH_SIZE - 1) * (MESH_SIZE - 2) * 4) + 4) * SWBX_WIDTH; // this is the bottom output/input track of the bottom left switch box
        localparam BOTTOM_CONFIG_BUS_OFFSET = ((MESH_SIZE * 2) - 1) * ((MESH_SIZE * 2) - 2); // this is the config bus that goes into the bottom left CLB
        localparam BOTTOM_DATA_IN_OFFSET = (((MESH_SIZE - 1) * 3) + 1) *  DATA_IN_WIDTH;// this is the data in for the bottom left cx
        localparam BOTTOM_DATA_OUT_OFFSET = (((MESH_SIZE - 1) * 3) + 1) *  DATA_OUT_WIDTH;// this is the data out for the bottom left cx

        CLB #(
            .NUM_BLE(CLB_NUM_BLE), 
            .NUM_INPUTS(CLB_NUM_INPUTS)
        ) CLB_bottom_left ( 
            .config_in(config_bus[BOTTOM_CONFIG_BUS_OFFSET]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[BOTTOM_CONFIG_BUS_OFFSET+1]),

            .data_in({
                single_track_zeros, 
                CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET - 1 -: CLB_TRACK_INPUTS], 
                CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS],
                single_track_zeros
                }),
            .clk(clk),
            .data_out(CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET - 1 -: CLB_NUM_BLE])
        );

        connector_box #(
            .LOG_INPUTS(CX_LOG_INPUTS),
            .INPUTS(CX_INPUTS),
            .OUTPUTS(CX_OUTPUTS)    
        ) connection_box_bottom_left (
            .config_in(config_bus[BOTTOM_CONFIG_BUS_OFFSET+1]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[BOTTOM_CONFIG_BUS_OFFSET+2]),

            .data_in({  CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET - 1 -: CLB_NUM_BLE],
                        SWBX_outputs[BOTTOM_ROW_SWBX_TRACK_OFFSET - 1 -: SWBX_WIDTH],
                        CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                        data_in[BOTTOM_DATA_IN_OFFSET - 1 -: DATA_IN_WIDTH]
                        }),                      

            .data_out({ CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + CLB_TRACK_INPUTS - 1 -: CLB_TRACK_INPUTS], 
                        SWBX_inputs[BOTTOM_ROW_SWBX_TRACK_OFFSET - 1 -: SWBX_WIDTH],
                        CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + (2 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                        data_out[BOTTOM_DATA_OUT_OFFSET - 1 -: DATA_OUT_WIDTH]
                        })
        );

//        //bottom row - edge cases

        for (x_index=1; x_index < MESH_SIZE-1; x_index=x_index+1) begin

            CLB #(
                .NUM_BLE(CLB_NUM_BLE), 
                .NUM_INPUTS(CLB_NUM_INPUTS)
            ) CLB_bottom_row ( 
                .config_in(config_bus[BOTTOM_CONFIG_BUS_OFFSET + 2 + ((x_index - 1)*2)]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[BOTTOM_CONFIG_BUS_OFFSET + 3 + ((x_index - 1)*2)]),

                .data_in({  CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + (2*CLB_TRACK_INPUTS) + ((x_index - 1) * 3 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + (3*CLB_TRACK_INPUTS) + ((x_index - 1) * 3 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                            CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + (4*CLB_TRACK_INPUTS) + ((x_index - 1) * 3 * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                            single_track_zeros
                    }),
                .clk(clk),
                .data_out(CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
            );

            connector_box #(
                .LOG_INPUTS(CX_LOG_INPUTS),
                .INPUTS(CX_INPUTS),
                .OUTPUTS(CX_OUTPUTS)    
            ) connection_box_bottom_row (
                .config_in(config_bus[BOTTOM_CONFIG_BUS_OFFSET + 3 + ((x_index - 1)*2)]),
                .config_clk(config_clk),
                .config_en(config_en),
                .config_out(config_bus[BOTTOM_CONFIG_BUS_OFFSET + 4 + ((x_index - 1)*2)]),

                .data_in({  CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET + (x_index * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE], 
                            SWBX_outputs[BOTTOM_ROW_SWBX_TRACK_OFFSET + (SWBX_WIDTH * x_index * 4) - 1 -: SWBX_WIDTH],
                            CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET + ((x_index + 1) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE],
                            data_in[BOTTOM_DATA_IN_OFFSET + (x_index * DATA_IN_WIDTH) - 1 -: DATA_IN_WIDTH]
                            }),

                .data_out({ CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + ((1 + x_index * 3) * CLB_TRACK_INPUTS)  - 1 -: CLB_TRACK_INPUTS], 
                            SWBX_inputs[BOTTOM_ROW_SWBX_TRACK_OFFSET + (SWBX_WIDTH * x_index * 4) - 1 -: SWBX_WIDTH],
                            CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + ((2 + x_index * 3) * CLB_TRACK_INPUTS)  - 1 -: CLB_TRACK_INPUTS],
                            data_out[BOTTOM_DATA_OUT_OFFSET + (x_index * DATA_OUT_WIDTH) - 1 -: DATA_OUT_WIDTH]
                            })
            );
    
        end

       //bottom row - right edge

        CLB #(
            .NUM_BLE(CLB_NUM_BLE), 
            .NUM_INPUTS(CLB_NUM_INPUTS)
        ) CLB_bottom_right ( 
            .config_in(config_bus[BOTTOM_CONFIG_BUS_OFFSET + ((MESH_SIZE * 2) - 2)]),
            .config_clk(config_clk),
            .config_en(config_en),
            .config_out(config_bus[BOTTOM_CONFIG_BUS_OFFSET + ((MESH_SIZE * 2) - 1)]),

            .data_in({
                CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + ((2 + (3 * (MESH_SIZE - 2))) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                CLB_inputs[BOTTOM_ROW_CLB_INPUT_TRACK_OFFSET + ((3 + (3 * (MESH_SIZE - 2))) * CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],
                single_track_zeros,
                single_track_zeros
                }),
            .clk(clk),
            .data_out(CLB_outputs[BOTTOM_ROW_CLB_OUTPUT_TRACK_OFFSET + ((MESH_SIZE - 1) * CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
        );

    endgenerate

endmodule
