module control_pacman(go, x, y, clock, reset_n, dir_in);
	
	input clock,reset_n;
	input [2:0] dir_in;
	
	output go;
	
	reg [2:0] direction;
	reg [2:0] current_state,next_state;
	
	reg [7:0] x;
	reg [6:0] y;
	
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
	
	always @(*) begin
		case(current_state)
			WAIT: begin
				
			end
			RIGHT: 
			UP: 
			LEFT: 
			DOWN: 
		endcase
	end
	
	always @(posedge clock) begin
		if(!reset_n) current_state = WAIT;
		else currect_state = next_state;
	end
	
endmodule