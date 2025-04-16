`timescale 1ns / 1ps

module TOP_SCOREBOARD #(
    
    parameter DATA_IN_WIRE_WIDTH = 0,
    parameter DATA_OUT_WIRE_WIDTH = 0,
    parameter CONFIG_WIDTH = 0
    
    )
    
    (
        
    input sim_done,
    
    input [DATA_OUT_WIRE_WIDTH-1:0] expected_dataout, dataout,
    input config_out, expected_config_out, clk, config_clk, sys_reset,
    
    input [31:0] current_clock,
    input clock_finished,
    output reg clock_result
        
    );

    integer logfile_pointer, sim_errors, clock_errors, best_clock;
    
    wire integer current_clock_wire;
    
    assign current_clock_wire = current_clock;
    
    initial begin
    
        logfile_pointer = $fopen("/home/owen/College/MAI_Project/Vivado/seq_sim_runs/8_bit_adder/log.txt", "w");
        
        if (logfile_pointer) begin
            $display("Succeeded in opening log file!");
        end
        
        else begin
            $display("SIM_FAILED: Failed opening log file!");
            $finish;
        end
        
        sim_errors = 0;
        clock_errors = 0;
        clock_result = 0;
        best_clock = 9999999;

    end
    
    always @(posedge clock_finished, negedge clock_finished) begin
        
        if (clock_finished) begin 
        
            if (clock_errors > 0) begin
                clock_result <= 0;
                clock_errors = 0;
                $fwrite(logfile_pointer, "CLOCK FAILED @ sime_time %0d: Dataout errors were detected during clock testing.\n Clock Period %d\n", $time, current_clock_wire);
            end
            
            else begin
                clock_result <= 1;
                clock_errors = 0;
                $fwrite(logfile_pointer, "CLOCK PASSED @ sime_time %0d: No errors were detected during clock testing.\n Clock Period %d\n", $time, current_clock_wire);
                if (current_clock < best_clock) begin
                    best_clock = current_clock;
                end
                
            end  
            
        end
        
        else begin  
        
            clock_result <= 0; 
             
        end 
    end 
    
    
    
    always @(posedge clk, posedge config_clk, sim_done, posedge sys_reset) begin
        
        //check if simulation is finshed
        if (sim_done) begin
        
            if (sim_errors == 0) begin
            
                $fwrite(logfile_pointer, "SIM PASSED: No errors detected in simulation runtime!\n");
                $display("SIM PASSED: No errors in simulation runtime");
            end
            
            else begin
            
                $fwrite(logfile_pointer, "SIM FAILED: %d errors detected in simulation runtime!\n", sim_errors); 
                $display("SIM FAILED: Errors detected in simulation runtime");
            end
            $fwrite(logfile_pointer, "BEST CLOCK: %dns period!\n", best_clock); 
            $fclose(logfile_pointer);
            $finish;
            
            
        end
        
        
        else if (sys_reset) begin
        
                $fwrite(logfile_pointer, "Ignoring output values during system initialisation!\n");
                
        end
        
        else begin
           
            if (clk) begin
            
                @(negedge clk)
                
                //check data out matches
                if (expected_dataout !== dataout)  begin
                
                    $fwrite(logfile_pointer, "SIM_ERROR @ sime_time %0d: dataout does match expected dataout\ndataout:            %b\nexpected dataout:   %b\n", $time, dataout, expected_dataout);
                    clock_errors = clock_errors + 1;  
                    sim_errors = sim_errors + 1;
                    
                end
            
            end 

            if (config_clk) begin 
            
                @(negedge config_clk)
                
                //check config out matches
                if (expected_config_out !== config_out) begin
                
                    $fwrite(logfile_pointer, "SIM_ERROR @ sim_time %0d: config out does match expected config out\nconfig out:  %b\nexpected config out:    %b\n", $time, config_out, expected_config_out); 
                    sim_errors = sim_errors + 1;
                end
            
            end

            
        end
        
    end 
    
endmodule
