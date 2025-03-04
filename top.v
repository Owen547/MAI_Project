`timescale 1ns / 1ps

module top
    #(
    parameter NUM_BLE = 3,
    parameter NUM_INPUTS = 12,
    parameter LOG_INPUTS = 4, 
    parameter INPUTS = 16, 
    parameter OUTPUTS = 20,
    parameter WIDTH = 14

    )

    (
    input config_in,
    input config_clk,
    input config_en,
    input clk,
    input [15:0] data_in,
    output [23:0] data_out,
    output config_out
    );

    wire [8:0] config_bus;

    assign config_out = config_bus[8];

    //hard declaring for now

    wire [5:0] WNW_i, WSW_i, NNW_i, NNE_i, ENE_i, ESE_i, SSE_i, SSW_i;
    wire [2:0] WNW_o, WSW_o, NNW_o, NNE_o, ENE_o, ESE_o, SSE_o, SSW_o;

    wire [7:0] CE_i, CN_i, CW_i, CS_i;
    wire [5:0] CE_o, CN_o, CW_o, CS_o;

    wire [3:0] W_i, N_i, E_i, S_i;
    wire [5:0] W_o, N_o, E_o, S_o;

    wire [13:0] CN, CS, CE, CW;

    assign W_i = data_in [3:0];
    assign N_i = data_in [7:4];
    assign E_i = data_in [11:8];
    assign S_i = data_in [15:12];

    assign W_o = data_out [5:0];
    assign N_o = data_out [11:6];
    assign E_o = data_out [17:12];
    assign S_o = data_out [23:18];


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
        .data_out({WNW_o, NNW_o})
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

        .data_in({NNW_o, NNE_o, CN_i, N_i}),
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
        .data_out({NNE_o, ENE_o})
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

        .data_in({WSW_o, WNW_o, CW_i, W_i}),
        .data_out({WSW_i, WNW_i, CW_o, W_o})
    );
    
    switch_box #(
        .WIDTH(WIDTH)
    ) Centre_switch_box (       
        .config_in(config_bus[3]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[4]),

        .l({CW_i, CW_o}),
        .r({CE_i, CE_o}),
        .t({CN_i, CN_o}),
        .b({CS_i, CS_o})
    );

    connector_box #(
        .LOG_INPUTS(60),
        .INPUTS(200),
        .OUTPUTS(200)
    ) E_connection_box (
        .config_in(config_bus[4]),
        .config_clk(config_clk),
        .config_en(config_en),
        .config_out(config_bus[5]),

        .data_in({ENE_o, ESE_o, CE_i, E_i}),
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
        .data_out({SSW_o, WSW_o})
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

        .data_in({SSE_o, SSW_o, CS_i, S_i}),
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
        .data_out({ESE_o, SSE_o})
    );


endmodule
