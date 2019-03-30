module control_pacman(shape, x_out, y_out, clock, reset_n, dir_in);

	input clock,reset_n;
	input [2:0] dir_in;
	output [24:0] shape;
	output [7:0] x_out;
	output [6:0] y_out;

	localparam  DEFAULT_X = 8'd13, DEFAULT_Y = 7'd18;

	//Assign to shape the correct shape for the pac-man
	pac_shaper p0(.shape(shape), 
	              .dir_in(dir_in), 
					  .clock(clock), 
					  .reset_n(reset_n));
					  
	//Assign the resulting x and y coordinates to the x and y outputs
	movement_handler pac_move(.clk(clock),
	                          .dir_in(dir_in), 
									  .reset_n(reset_n), 
									  .reset_x(DEFAULT_X), 
									  .reset_y(DEFAULT_Y), 
									  .x_out(x_out), 
									  .y_out(y_out));

endmodule