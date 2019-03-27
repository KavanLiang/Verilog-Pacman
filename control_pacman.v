module control_pacman(shape, x_out, y_out, clock, reset_n, dir_in);
	
	input clock,reset_n;
	input [2:0] dir_in;
	output [24:0] shape;
	output [7:0] x_out;
	output [6:0] y_out;
	
	reg [7:0] x, x_next;
	reg [6:0] y, y_next;
	
	wire map_state;
	
	localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
	
	//Assign to shape the correct shape for the pac-man
	pac_shaper p0(.shape(shape), .dir_in(dir_in), .clock(clock), .reset_n(reset_n));
	
	always @(*) begin
		x_next = x;
		y_next = y;
		case(dir_in)
			RIGHT: x_next = x+8'b1;
			UP: y_next = y-7'b1;
			LEFT: x_next = x-8'b1;
			DOWN: y_next = y+7'b1;
		endcase
	end
	
	map_lut map(.q(map_state), .x(x_next), .y(y_next));
	
	assign x_out = x;
	assign y_out = y;
	
	always @(posedge clock) begin
		//Change reset value to starting point
		if(!reset_n) begin
			x <= 8'd13;
			y <= 7'd18;
		end
		else begin
			if(dir_in == RIGHT) begin
				if(x == 8'd26) x <= 8'd0;
				else if(map_state == 1'b1) x <= x_next-8'd1;
				else x <= x_next;
			end
			else if(dir_in == UP) begin
				if(y == 7'd0) y <= 7'd23;
				else if(map_state == 1'b1) y <= y_next+8'd1;
				else y <= y_next;
			end
			else if(dir_in == LEFT) begin
				if(x == 8'd0) x <= 8'd26;
				else if(map_state == 1'b1) x <= x_next+8'd1;
				else x <= x_next;
			end
			else if(dir_in == DOWN) begin
				if(y == 7'd23) y <= 7'd0;
				else if(map_state == 1'b1) y <= y_next-8'd1;
				else y <= y_next;
			end
			else if(dir_in == WAIT) begin
				x <= x_next;
				y <= y_next;
			end
		end
	end
	
endmodule