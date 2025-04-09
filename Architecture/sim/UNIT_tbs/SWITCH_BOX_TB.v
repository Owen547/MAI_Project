`timescale 1ns / 1ps

module SWITCH_BOX_tb #(

    parameter WIDTH = 5,
    parameter CONFIG_WIDTH = 40

    )

    (

    output config_out,
    output [WIDTH - 1:0] l_out,
    output [WIDTH - 1:0] r_out,
    output [WIDTH - 1:0] t_out,
    output [WIDTH - 1:0] b_out

    );


    reg config_in;
    reg config_clk;
    reg config_en;
    reg [WIDTH - 1:0] l_in;
    reg [WIDTH - 1:0] r_in;
    reg [WIDTH - 1:0] t_in;
    reg [WIDTH - 1:0] b_in;
    
    reg [39: 0] config_bits;
    
    task initialise_config_signals ();
    begin
        config_en = 0;
        config_in = 0;
        config_clk = 0;
    end
    endtask

    task configure_switch_box (input [CONFIG_WIDTH-1:0] config_bits); 
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

    task cycle_data_in ();
    begin
        l_in = 2'b00;
        t_in = 2'b00;
        b_in = 2'b00;
        r_in = 2'b00;
        #10;
        l_in = 2'b11;
        #10;
        l_in = 2'b00;
        t_in = 2'b11;
        #10;
        t_in = 2'b00;
        r_in = 2'b11;
        #10;
        r_in = 2'b00;
        b_in = 2'b11;
        #10;
        l_in = 2'b00;
        t_in = 2'b00;
        b_in = 2'b00;
        r_in = 2'b00;
        #10;
    end
    endtask

    switch_box #(
    .WIDTH(WIDTH)   
    ) UUT (
    .config_in(config_in),
    .config_clk(config_clk),
    .config_en(config_en),
    .config_out(config_out),

    .l_in(l_in),
    .l_out(l_out),

    .r_in(r_in),
    .r_out(r_out),

    .t_in(t_in),
    .t_out(t_out),

    .b_in(b_in),
    .b_out(b_out)

    );


    initial begin
        config_bits = 40'b0001000010000000000100000001000000010000;
        l_in = 2'b01;
        t_in = 2'b10;
        r_in = 2'b11;
        b_in = 2'b01;
        initialise_config_signals();
        configure_switch_box(config_bits); // should connect each port to its direct opposite e.g. l_in[0] with r_out[0], b_in[1] with t_out[1]
        cycle_data_in();
//        configure_switch_box(32'b11111111111111111111111111111111); //now try config for l_in[0] to t_out[0] and b_in[0] to l_out[0]
//        cycle_data_in();
        $finish;
    end
    
endmodule
