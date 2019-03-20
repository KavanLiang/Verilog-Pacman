module control_pacman(go, shape, x_out, y_out, clock, reset_n, dir_in);
	
	input clock,reset_n;
	input [2:0] dir_in;
	
	output go;
	
	assign go = clock;
	
	reg [2:0] current_state,next_state;
	
	reg [7:0] x;
	reg [6:0] y;
	
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	output [24:0] shape;
	
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
				x_out = x;
				y_out = y;
			end
			RIGHT: begin
				if(x == 8'd26) x_out = 8'd0;
				else x_out = x+8'd1;
				y_out = y;
			end
			UP: begin
				x_out = x;
				if(y == 7'd0) y_out = 7'd23;
				else y_out = y-7'd1;
			end
			LEFT: begin
				if(x == 8'd0) x_out = 8'd26;
				else x_out = x-8'd1;
				y_out = y;
			end
			DOWN: begin
				x_out = x;
				if(y == 7'd23) y_out = 7'd0;
				else y_out = y+7'd1;
			end
		endcase
	end
	
	always @(posedge clock) begin
		//Change reset value to starting point?
		if(!reset_n) begin
			x <= 8'd0;
			y <= 7'd0;
		end
		else begin
			if(current_state == RIGHT) begin
				if(x == 8'd26) x <= 8'd0;
				else x <= x+8'd1;
			end
			else if(current_state == UP) begin
				if(y == 7'd0) y <= 7'd23;
				else y <= y-7'd1;
			end
			else if(current_state == LEFT) begin
				if(x == 8'd0) x <= 8'd26;
				else x <= x-8'd1;
			end
			else if(current_state == DOWN) begin
				if(y == 7'd23) y <= 7'd0;
				else y <= y+7'd1;
			end
		end
	end
	
	always @(posedge clock) begin
		if(!reset_n) current_state = WAIT;
		else current_state = next_state;
	end
	
	reg [24:0] next_ani;
	
	localparam rightA = 25'b0111011111110001111101110,
              rightB = 25'b0111011100110001110001110,
				  upA = 25'b0101011011110111111101110,
				  upB = 25'b0000010001110111111101110,
				  leftA = 25'b0111011111000111111101110,
				  leftB = 25'b0111000111000110011101110,
				  downA = 25'b0111011111110111101101010,
				  downB = 25'b0111011111110111000100000;
				  
	reg [24:0] next_shape;
  
	assign shape = next_ani;

  always @(posedge clock) begin
    if(!reset_n) begin
		next_ani <= rightA;
    end
    else begin
		  case(dir_in)
			RIGHT: begin
				if(next_ani == upA || next_ani == leftA || next_ani == downA) next_ani <= rightB;
				else if(next_ani == upB || next_ani == leftB || next_ani == downB) next_ani <= rightA;
				else next_ani <= (next_ani == rightA) ? rightB : rightA;
			end
			UP: begin
				if(next_ani == rightA || next_ani == leftA || next_ani == downA) next_ani <= upB;
				else if(next_ani == rightB || next_ani == leftB || next_ani == downB) next_ani <= upA;
				else next_ani <= (next_ani == upA) ? upB : upA;
			end
			LEFT: begin
				if(next_ani == rightA || next_ani == upA || next_ani == downA) next_ani <= leftB;
				else if(next_ani == rightB || next_ani == upB || next_ani == downB) next_ani <= leftA;
				else next_ani <= (next_ani == leftA) ? leftB : leftA;
			end
			DOWN: begin
				if(next_ani == rightA || next_ani == leftA || next_ani == upA) next_ani <= downB;
				else if(next_ani == rightB || next_ani == leftB || next_ani == upB) next_ani <= downA;
				else next_ani <= (next_ani == downA) ? downB : downA;
			end
			WAIT: begin
				if(next_ani == rightA || next_ani == rightB) next_ani <= (next_ani == rightA) ? rightB : rightA;
				else if(next_ani == upA || next_ani == upB) next_ani <= (next_ani == upA) ? upB : upA;
				else if(next_ani == leftA || next_ani == leftB) next_ani <= (next_ani == leftA) ? leftB : leftA;
				else next_ani <= (next_ani == downA) ? downB : downA;
			end
		 endcase
    end
  end
	
endmodule