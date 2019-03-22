module pac_shaper(shape, dir_in, clock, reset_n);

	input clock, reset_n;
	input [2:0] dir_in;
	
	output [24:0] shape;
	
	reg [24:0] next_ani;
    
	localparam rightA = 25'b0111011111110001111101110,
				  rightB = 25'b0111011100110001110001110,
				  upA = 25'b0101011011110111111101110,
				  upB = 25'b0000010001110111111101110,
				  leftA = 25'b0111011111000111111101110,
				  leftB = 25'b0111000111000110011101110,
				  downA = 25'b0111011111110111101101010,
				  downB = 25'b0111011111110111000100000,
				  WAIT = 3'b100, 
				  RIGHT = 3'b000, 
				  UP = 3'b001, 
				  LEFT = 3'b010, 
				  DOWN = 3'b011;
				  
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