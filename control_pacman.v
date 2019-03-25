module control_pacman(go, shape, x_out, y_out, clock, reset_n, dir_in);
	
	input clock,reset_n;
	input [2:0] dir_in;
	
	output go;
	output [24:0] shape;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	assign go = clock;
	
	reg [2:0] current_state,next_state;
	reg [7:0] x, x_next;
	reg [6:0] y, y_next;
	
	wire map_state;
	
	localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
	
	//Assign to shape the correct shape for the pac-man
	pac_shaper p0(.shape(shape), .dir_in(dir_in), .clock(clock), .reset_n(reset_n));
	
	always @(*) begin
		case(dir_in)
			WAIT: next_state = WAIT;
			RIGHT: next_state = RIGHT;
			UP: next_state = UP;
			LEFT: next_state = LEFT;
			DOWN: next_state = DOWN;
			default: next_state = WAIT;
		endcase
	end
	
	always @(*) begin
		x_next = x;
		y_next = y;
		case(dir_in)
			RIGHT: x_next = x+8'b1;
			UP: y_next = y+7'b1;
			LEFT: x_next = x-8'b1;
			DOWN: y_next = y-7'b1;
		endcase
	end
	
	map_lut map(.q(map_state), .x(x_next), .y(y_next));
	
	always @(*) begin
		y_out = y_next;
		x_out = x_next;
		case(dir_in)
			RIGHT: begin
				if(x == 8'd26) x_out = 8'd0;
				else if(map_state == 1'b1) x_out = x_next-8'b1;
			end
			UP: begin
				if(y == 7'd0) y_out = 7'd23;
				else if(map_state == 1'b1) y_out = y_next-8'b1;
			end
			LEFT: begin
				if(x == 8'd0) x_out = 8'd26;
				else if(map_state == 1'b1) x_out = x_next+8'b1;
			end
			DOWN: begin
				if(y == 7'd23) y_out = 7'd0;
				else if(map_state == 1'b1) y_out = y_next+8'b1;
			end
		endcase
	end
	
	always @(posedge clock) begin
		//Change reset value to starting point
		if(!reset_n) begin
			x <= 8'd2;
			y <= 7'd1;
		end
		else begin
			if(current_state == RIGHT) begin
				if(x == 8'd26) x <= 8'd0;
				else if(map_state == 1'b1) x <= x_next-8'd1;
				else x <= x_next;
			end
			else if(current_state == UP) begin
				if(y == 7'd0) y <= 7'd23;
				else if(map_state == 1'b1) y <= y_next-8'd1;
				else y <= y_next;
			end
			else if(current_state == LEFT) begin
				if(x == 8'd0) x <= 8'd26;
				else if(map_state == 1'b1) x <= x_next+8'd1;
				else x <= x_next;
			end
			else if(current_state == DOWN) begin
				if(y == 7'd23) y <= 7'd0;
				else if(map_state == 1'b1) y <= y_next+8'd1;
				else y <= y_next;
			end
		end
	end
	
	always @(posedge clock) begin
		if(!reset_n) current_state = WAIT;
		else current_state = next_state;
	end
	
endmodule