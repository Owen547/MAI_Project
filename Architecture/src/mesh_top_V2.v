`timescale 1ns / 1ps

module mesh_top_V2 #(
    
   parameter MESH_SIZE_X = 7,  //declare number of CLB's in x axis. Also minimum is 2, anything less and the architecture isn't applicable/code doesnt work.
   parameter MESH_SIZE_Y = 4,  //declared in number of CLB's in y axis. Also minimum is 2, anything less and the architecture isn't applicable/code doesnt work.
    
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
   input [((((MESH_SIZE_X - 1) * 2) + ((MESH_SIZE_Y - 1) * 2)) * DATA_IN_WIDTH) - 1:0] data_in, //mesh size minus 1 is number of cx on each side. times 4 for 4 sides. times datain in widtrh for number of data in.
   output [((((MESH_SIZE_X - 1) * 2) + ((MESH_SIZE_Y - 1) * 2)) * DATA_OUT_WIDTH) - 1:0] data_out,
   output config_out
    
   );

   wire [(MESH_SIZE_X * 2 - 1) * (MESH_SIZE_Y * 2 - 1):0] config_bus;
 
   assign config_bus[0] = config_in;
   assign config_out = config_bus[(MESH_SIZE_X * 2 - 1) * (MESH_SIZE_Y * 2 - 1)];

   wire [(CLB_NUM_INPUTS*MESH_SIZE_X*MESH_SIZE_Y) - 1 : 0] CLB_inputs;
   wire [(CLB_NUM_BLE * (MESH_SIZE_X * MESH_SIZE_Y)) - 1 : 0] CLB_outputs;
   wire [(SWBX_WIDTH*4*(MESH_SIZE_X + 1)*(MESH_SIZE_Y + 1)) - 1:0] SWBX_inputs;
   wire [(SWBX_WIDTH*4*(MESH_SIZE_X + 1)*(MESH_SIZE_Y + 1)) - 1:0] SWBX_outputs;


   localparam config_interval =  (MESH_SIZE_X * 2) - 1; // vertical interval in config values
   localparam switch_box_interval = (MESH_SIZE_X + 1) * 4 * SWBX_WIDTH ; // vertical interval in switch box values
   localparam CLB_input_interval = MESH_SIZE_X * 4 * CLB_TRACK_INPUTS; // vertical interval between CLB input vlaues
   localparam CLB_output_interval = MESH_SIZE_X * CLB_NUM_BLE; // vertical interval between CLB output vlaues


   genvar y_index, x_index;

   // make some paramterised loop to assign the hanging swbx input/outputs wires that are connected to the cx i/o to data_in/data_out.
   // Might have to create an IO block that connects to the hanging swbx input/outputs for VTR...
   // 
   //
   //
   //

   
   



   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



 

   generate

      for (y_index=0; y_index <= ((MESH_SIZE_Y * 2) - 2); y_index=y_index+2) begin : row

         for (x_index=0; x_index <= ((MESH_SIZE_X * 2) - 2); x_index=x_index+2) begin : column

            if (y_index != (MESH_SIZE_Y*2-2)) begin : y_normal_case

               if (x_index != (MESH_SIZE_X*2-2)) begin : x_normal_case

                  // CLB ROW 

                  CLB #(
                     .NUM_BLE(CLB_NUM_BLE), 
                     .NUM_INPUTS(CLB_NUM_INPUTS)
                  ) CLB_X_Y_normal ( 
                     .config_in(config_bus[(y_index * config_interval) + x_index]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[(y_index * config_interval) + x_index + 1]),

                     .data_in({
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],  
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (3*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (4*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                     }),
                     .clk(clk),
                     .data_out(CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + (1*CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
                  );

                  connector_box #(
                     .LOG_INPUTS(CX_LOG_INPUTS),
                     .INPUTS(CX_INPUTS),
                     .OUTPUTS(CX_OUTPUTS)    
                  ) connection_box_CLB_row_X_Y_normal (
                     .config_in(config_bus[(y_index * config_interval) + x_index + 1]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[(y_index * config_interval) + x_index + 2]),

                     .data_in({  CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                                 SWBX_outputs[(y_index/2 * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2 + 1) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                                 SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                              }),

                     .data_out({ CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (3*CLB_TRACK_INPUTS) - 1  -: CLB_TRACK_INPUTS], 
                                 SWBX_inputs[(y_index/2 * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (4 * SWBX_WIDTH) - 1  -: SWBX_WIDTH],
                                 CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2 + 1) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                                 SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                              })
                  );

                  // SWITCH ROW

                  connector_box #(
                     .LOG_INPUTS(CX_LOG_INPUTS),
                     .INPUTS(CX_INPUTS),
                     .OUTPUTS(CX_OUTPUTS)    
                  ) connection_box_switch_row_X_Y_normal (
                     .config_in(config_bus[((y_index + 1) * config_interval) + x_index]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[((y_index + 1) * config_interval) + x_index + 1]),

                     .data_in({  
                                 SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2) * 4 * SWBX_WIDTH) + (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                                 SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_outputs[((y_index/2 + 1) * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE]
                              }),

                     .data_out({ 
                                 SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2) * 4 * SWBX_WIDTH) + (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (4*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                                 SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_inputs[((y_index/2 + 1) * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                              })
                  );

                  switch_box #(
                     .WIDTH(SWBX_WIDTH)
                  ) switch_box_X_Y_normal (
                     .config_in(config_bus[((y_index + 1) * config_interval) + x_index + 1]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[((y_index + 1) * config_interval) + x_index + 2]),

                     .l_in(SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                     .l_out(SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (1 * SWBX_WIDTH) - 1  -: SWBX_WIDTH]),

                     .t_in(SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1  -: SWBX_WIDTH]),
                     .t_out(SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                     .r_in(SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                     .r_out(SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),

                     .b_in(SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]),
                     .b_out(SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH])
                  );


               end

               else begin : x_edge_case
                  
                  // CLB ROW 

                  CLB #(
                     .NUM_BLE(CLB_NUM_BLE), 
                     .NUM_INPUTS(CLB_NUM_INPUTS)
                  ) CLB_X_Y_normal ( 
                     .config_in(config_bus[(y_index * config_interval) + x_index]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[(y_index * config_interval) + x_index + 1]),

                     .data_in({
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],  
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (3*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (4*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                     }),
                     .clk(clk),
                     .data_out(CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + (1*CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
                  );

                  // SWITCH ROW

                  connector_box #(
                     .LOG_INPUTS(CX_LOG_INPUTS),
                     .INPUTS(CX_INPUTS),
                     .OUTPUTS(CX_OUTPUTS)    
                  ) connection_box_switch_row_X_Y_normal (
                     .config_in(config_bus[((y_index + 1) * config_interval) + x_index]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[((y_index + 1) * config_interval) + x_index + 1]),

                     .data_in({  
                                 SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2) * 4 * SWBX_WIDTH) + (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                                 SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_outputs[((y_index/2 + 1) * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE]
                              }),

                     .data_out({ 
                                 SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2) * 4 * SWBX_WIDTH) + (3 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (4*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                                 SWBX_inputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (1 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_inputs[((y_index/2 + 1) * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                              })
                  );

               end

            end

            else begin : y_edge_case

               if (x_index != (MESH_SIZE_X*2-2)) begin : y_edge_x_normal_case

                  // CLB ROW 

                  CLB #(
                     .NUM_BLE(CLB_NUM_BLE), 
                     .NUM_INPUTS(CLB_NUM_INPUTS)
                  ) CLB_X_normal_Y_edge ( 
                     .config_in(config_bus[(y_index * config_interval) + x_index]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[(y_index * config_interval) + x_index + 1]),

                     .data_in({
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],  
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (3*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (4*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                     }),
                     .clk(clk),
                     .data_out(CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + (1*CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
                  );

                  connector_box #(
                     .LOG_INPUTS(CX_LOG_INPUTS),
                     .INPUTS(CX_INPUTS),
                     .OUTPUTS(CX_OUTPUTS)    
                  ) connection_box_CLB_row_X_normal_Y_edge (
                     .config_in(config_bus[(y_index * config_interval) + x_index + 1]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[(y_index * config_interval) + x_index + 2]),

                     .data_in({  CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                                 SWBX_outputs[(y_index/2 * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (4 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2 + 1) * CLB_NUM_BLE) + CLB_NUM_BLE - 1 -: CLB_NUM_BLE],
                                 SWBX_outputs[((y_index/2 + 1) * switch_box_interval) + ((x_index/2 + 1) * 4 * SWBX_WIDTH) + (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                              }),

                     .data_out({ CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (3*CLB_TRACK_INPUTS) - 1  -: CLB_TRACK_INPUTS], 
                                 SWBX_inputs[(8 * SWBX_WIDTH) + ((y_index/2 + 1) * switch_box_interval) + (x_index/2 * 4 * SWBX_WIDTH) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH],
                                 CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2 + 1) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                                 SWBX_inputs[(8 * SWBX_WIDTH) + ((y_index/2 + 1) * switch_box_interval) + (x_index/2 * 4 * SWBX_WIDTH) - (2 * SWBX_WIDTH) - 1 -: SWBX_WIDTH]
                              })
                  );
   
               end

               else begin : y_edge_x_edge_case

                  // CLB ROW 

                  CLB #(
                     .NUM_BLE(CLB_NUM_BLE), 
                     .NUM_INPUTS(CLB_NUM_INPUTS)
                  ) CLB_X_edge_Y_edge ( 
                     .config_in(config_bus[(y_index * config_interval) + x_index]),
                     .config_clk(config_clk),
                     .config_en(config_en),
                     .config_out(config_bus[(y_index * config_interval) + x_index + 1]),

                     .data_in({
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (1*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS],  
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (2*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (3*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS], 
                        CLB_inputs[(y_index/2 * CLB_input_interval) + ((x_index/2) * CLB_TRACK_INPUTS) + (4*CLB_TRACK_INPUTS) - 1 -: CLB_TRACK_INPUTS]
                     }),
                     .clk(clk),
                     .data_out(CLB_outputs[(y_index/2 * CLB_output_interval) + ((x_index/2) * CLB_NUM_BLE) + (1*CLB_NUM_BLE) - 1 -: CLB_NUM_BLE])
                  );

               end

            end

      end
         
      end

   endgenerate

endmodule