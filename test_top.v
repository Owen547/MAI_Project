`timescale 1ns / 1ps

module test_top
    #(

    parameter NUM_BLE = 3,
    parameter NUM_INPUTS = 12,
    parameter LOG_INPUTS = 4, 
    parameter INPUTS = 16, 
    parameter OUTPUTS = 20,
    parameter WIDTH = 14,
    parameter OUTPUT_PAD_WIDTH = 4,
    parameter INPUT_PAD_WIDTH = 4

    )

    (
    input config_in,
    input config_clk,
    input config_en,
    input clk,
    input [15:0] data_in,
    output [15:0] data_out,
    output config_out
    );

    wire [8:0] config_bus;

    assign config_out = config_bus[8];

    //hard declaring for now

    wire [5:0] WNW_i, WSW_i, NNW_i, NNE_i, ENE_i, ESE_i, SSE_i, SSW_i;
    wire [2:0] NW_o, NE_o, SE_o, SW_o;

    wire [5:0] CE_i, CN_i, CW_i, CS_i;
    wire [3:0] CE_o, CN_o, CW_o, CS_o;

    wire [3:0] W_i, N_i, E_i, S_i;
    wire [3:0] W_o, N_o, E_o, S_o;
    
    assign W_i = data_in [INPUT_PAD_WIDTH-1:0];
    assign N_i = data_in [(INPUT_PAD_WIDTH*2)-1:INPUT_PAD_WIDTH];
    assign E_i = data_in [(INPUT_PAD_WIDTH*3)-1:INPUT_PAD_WIDTH*2];
    assign S_i = data_in [(INPUT_PAD_WIDTH*4)-1:INPUT_PAD_WIDTH*3];

    assign data_out [OUTPUT_PAD_WIDTH-1:0] = W_o;
    assign data_out [(OUTPUT_PAD_WIDTH*2)-1:OUTPUT_PAD_WIDTH] = N_o;
    assign data_out [(OUTPUT_PAD_WIDTH*3)-1:OUTPUT_PAD_WIDTH*2] = E_o;
    assign data_out [(OUTPUT_PAD_WIDTH*4)-1:OUTPUT_PAD_WIDTH*3] = S_o;


    CLB #(
        .NUM_BLE(NUM_BLE), 
        .NUM_INPUTS(NUM_INPUTS)
    ) NW_CLB ( 
        .config_in(config_in),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[0]),

        .data_in({WNW_i, NNW_i}),
        .clk(clk),
        .data_out(NW_o)
    );

    connector_box #(
        .LOG_INPUTS(LOG_INPUTS),
        .INPUTS(INPUTS),
        .OUTPUTS(OUTPUTS)    
    ) N_connection_box (
        .config_in(config_bus[0]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[1]),

        .data_in({NW_o, NE_o, CN_i, N_i}),
        .data_out({NNW_i, NNE_i, CN_o, N_o})
    );

    CLB #(
        .NUM_BLE(NUM_BLE), 
        .NUM_INPUTS(NUM_INPUTS)
    ) NE_CLB(
        .config_in(config_bus[1]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[2]),

        .data_in({NNE_i, ENE_i}),
        .clk(clk),
        .data_out(NE_o)
    );

    connector_box #(
        .LOG_INPUTS(LOG_INPUTS),
        .INPUTS(INPUTS),
        .OUTPUTS(OUTPUTS)    
    ) W_connection_box (
        .config_in(config_bus[2]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[3]),

        .data_in({NW_o, SW_o, CW_i, W_i}),
        .data_out({WSW_i, WNW_i, CW_o, W_o})
    );

    switch_box #(
        .WIDTH(4)
    ) switch_box (
        .config_in(config_bus[3]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[4]),

        .l_in(CW_o), .t_in(CN_o), .r_in(CE_o), .b_in(CS_o),
        .l_out(CW_i), .t_out(CN_i), .r_out(CE_i), .b_out(CS_i)
    );

    connector_box #(
        .LOG_INPUTS(LOG_INPUTS),
        .INPUTS(INPUTS),
        .OUTPUTS(OUTPUTS)
    ) E_connection_box (
        .config_in(config_bus[4]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[5]),

        .data_in({SE_o, NE_o, CE_i, E_i}),
        .data_out({ENE_i, ESE_i, CE_o, E_o})
    );

    CLB #(
        .NUM_BLE(NUM_BLE), 
        .NUM_INPUTS(NUM_INPUTS)
    ) SW_CLB (
        .config_in(config_bus[5]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[6]),

        .data_in({SSW_i, WSW_i}),
        .clk(clk),
        .data_out(SW_o)
    );

    connector_box #(
        .LOG_INPUTS(LOG_INPUTS),
        .INPUTS(INPUTS),
        .OUTPUTS(OUTPUTS)
    ) S_connector_box (
        .config_in(config_bus[6]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[7]),

        .data_in({SE_o, SW_o, CS_i, S_i}),
        .data_out({SSE_i, SSW_i, CS_o, S_o})
    );

    CLB #(
        .NUM_BLE(NUM_BLE), 
        .NUM_INPUTS(NUM_INPUTS)
    ) SE_CLB (
        .config_in(config_bus[7]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[8]),

        .data_in({ESE_i, SSE_i}),
        .clk(clk),
        .data_out(SE_o)
    );


endmodule