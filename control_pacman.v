module control_pacman(go, dir_out, x, y, clock, reset_n, dir_in);
	
	input clock,reset_n;
	input [2:0] dir_in;
	
	output go;
	
	assign go = clock;
	
	reg [2:0] direction;
	reg [2:0] current_state,next_state;
	
	reg [7:0] x;
	reg [6:0] y;
	
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	output [2:0] dir_out;
	
	localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
	
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
	
	//Need to set x cap and y cap
	always @(*) begin
		case(current_state)
			WAIT: begin
				x_out = x;
				y_out = y;
			end
			RIGHT: begin
				x_out = x+8'd1;
				y_out = y;
			end
			UP: begin
				x_out = x;
				y_out = y-7'd1;
			end
			LEFT: begin
				x_out = x-8'd1;
				y_out = y;
			end
			DOWN: begin
				x_out = x;
				y_out = y+7'd1;
			end
		endcase
	end
	
	assign dir_out = direction;
	
	always @(posedge clock) begin
		if(!reset_n) direction <= WAIT;
		else if(current_state == WAIT) direction = WAIT;
		else if(current_state == RIGHT) direction = RIGHT;
		else if(current_state == UP) direction = UP;
		else if(current_state == LEFT) direction = LEFT;
		else if(current_state == DOWN) direction = DOWN;
	end
	
	always @(posedge clock) begin
		//Change reset value to starting point?
		if(!reset_n) begin
			x <= 8'd0;
			y <= 7'd0;
		end
		//Might have to look at next state instead
		else begin
			if(current_state == RIGHT) x <= x + 8'd1;
			else if(current_state == UP) y <= y - 7'd1;
			else if(current_state == LEFT) x <= x - 8'd1;
			else if(current_state == DOWN) y <= y + 7'd1;
		end
	end
	
	always @(posedge clock) begin
		if(!reset_n) current_state = WAIT;
		else currect_state = next_state;
	end
	
endmodule