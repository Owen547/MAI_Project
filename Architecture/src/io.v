`timescale 1ns / 1ps

module io (

    input [1:0]config_bits,

    input data_in, cx_in,
    output data_out, cx_out

    );

    mux #(1, 2) mux_data_in (
    .data_in({data_in, 1'b0}),
    .sel(config_bits[0]),
    .data_out(cx_out)
    );

    mux #(1, 2) mux_data_out (
    .data_in({cx_in, 1'b0}),
    .sel(config_bits[1]),
    .data_out(data_out)
    );
    
endmodule