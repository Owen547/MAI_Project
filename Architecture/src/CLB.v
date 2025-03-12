`timescale 1ns / 1ps

module CLB
#(
    parameter NUM_BLE = 3, 
    parameter NUM_INPUTS = 12
)// these should add to a power of two so that indexing is an integer number of bits... one less for ground bus for unnattached outputs of connector
( 
    input config_in,
    input config_clk,
    input config_en,
    output config_out,

    input [NUM_INPUTS - 1:0] data_in,
    input clk,
    output [NUM_BLE - 1:0] data_out
    
);
    
    wire [NUM_BLE * 6 - 1:0] ble_inputs;
    wire [NUM_BLE - 1:0] ble_outputs;
    
    wire [NUM_BLE + 1:0] config_bus;
    
    assign config_bus[0] = config_in;
    assign config_out = config_bus[NUM_BLE + 1];
    
    assign data_out = ble_outputs;
    
    connector_box #(
            .LOG_INPUTS($clog2(NUM_INPUTS + NUM_BLE + 1)),
            .INPUTS(NUM_INPUTS + NUM_BLE + 1),
            .OUTPUTS(NUM_BLE * 6)  
        ) CLB_connector (
            .config_in(config_in),
            .config_clk(config_clk),
            .config_en(config_en),
            .data_in({ble_outputs, data_in, 1'b0}),
            .config_out(config_bus[1]),
            .data_out(ble_inputs)
        );  
    
    genvar index;
    generate
    for (index=0; index < NUM_BLE; index=index+1) begin
        BLE ble_i (
            .config_in(config_bus[index + 1]),
            .config_clk(config_clk),
            .config_en(config_en),
            .clk(clk),
            .data_in(ble_inputs[index * 6 + 5 -: 6]),
            .config_out(config_bus[index + 2]),
            .data_out(ble_outputs[index])
        );
    end
    endgenerate

endmodule