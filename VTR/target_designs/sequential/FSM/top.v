module top(clk, in, reset, out);

input clk, in, reset;
output [2:0] out;

reg [2:0] out;
reg [1:0] state;

parameter S0=0, S1=1, S2=2, S3=3, S4=4;

always @(state) 
	begin
		case (state)
               		S0:
                 	   	out = 3'b000;
              	 	S1:
               		     	out = 3'b001;
               		S2:
				out = 3'b010;
               		S3:
                    		out = 3'b011;
			S4:
				out = 3'b100;
               		default:
                    		out = 3'b000;
		endcase
	end

always@(posedge clk or posedge reset)
	begin
		if (reset)
			state = S0;
		else
			case (state)
				S0:
					if (in)
						state = S1;
					else
						state = S0;
				S1:
					if (in)
						state = S1;
					else
						state = S2;
				S2:
					if (in)
						state = S3;
					else
						state = S0;
				S3:
					if (in)
						state = S4;
					else
						state = S2;
				S4:
					if (in)
						state = S1;
					else
						state = S2;
			endcase
	end

endmodule