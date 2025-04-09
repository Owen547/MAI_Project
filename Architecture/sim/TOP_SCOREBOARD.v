`timescale 1ns / 1ps

module TOP_SCOREBOARD #(
    
    parameter DATA_IN_WIRE_WIDTH = 0,
    parameter DATA_OUT_WIRE_WIDTH = 0,
    parameter CONFIG_WIDTH = 0
    
    )
    
    (
        
    input sim_done,
    
    input [DATA_OUT_WIRE_WIDTH-1:0] expected_dataout, dataout,
    input config_out, expected_config_out
        
    );

    integer logfile_pointer, sim_errors;
    
    initial begin
    
        logfile_pointer = $fopen("/home/owen/College/MAI_Project/Vivado/comb_sim_runs/8_bit_adder/log.txt", "w");
        
        if (logfile_pointer) begin
            $display("Succeeded in opening log file!");
        end
        
        else begin
            $display("SIM_FAILED: Failed opening log file!");
            $finish;
        end
        
        sim_errors = 0;
        
    end
    
    
    always @(dataout, expected_dataout, config_out, expected_config_out, sim_done) begin
        
        #1;
        
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
            
            $fclose(logfile_pointer);
            $finish;
            
            
        end
        
        else begin
        
            //check data out matches
            if (expected_dataout !== dataout)  begin
            
                $fwrite(logfile_pointer, "SIM_ERROR @ sime_time %0d: dataout does match expected dataout\ndataout:            %b\nexpected dataout:   %b\n", $time, dataout, expected_dataout);     
                sim_errors = sim_errors + 1;
                
            end
            
//            //check config out matches
            if (expected_config_out !== config_out) begin
            
                $fwrite(logfile_pointer, "SIM_ERROR @ sim_time %0d: config out does match expected config out\nconfig out:  %b\nexpected config out:    %b\n", $time, config_out, expected_config_out); 
                sim_errors = sim_errors + 1;
            end
            
        end

//        else begin
        
//            $fwrite(logfile_pointer, "SIM_PASS: outputs match");
        
//        end
        
    end 
    
endmodule
