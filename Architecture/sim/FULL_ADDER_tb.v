`timescale 1ns / 1ps

module FULL_ADDER_tb();

    reg [7:0] a, b;
    wire [7:0] s;
    reg cin;
    wire cout;

    adder_top DUT (.a(a), .b(b), .s(s), .cin(cin), .cout(cout));

    task cycle_data_in_a(); begin
        while (a != 8'b11111111) begin
            a = a + 1;
            #5;
        end
    end
    endtask

    task cycle_data_in_b(); begin
        while (b != 8'b11111111) begin
            b = b + 1;
            #5;
        end
    end
    endtask
    
    initial begin
        a = 0;
        b = 0;
        cin = 1;
        #5;
        cycle_data_in_a();
        a = 0;
        #5;
        cycle_data_in_b();

        $finish();   
    end
        
        
endmodule