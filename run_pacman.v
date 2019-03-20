module run_pacman(VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, CLOCK_50, SW, KEY);
	
	input CLOCK_50;
	input [9:0] SW;
	input [3:0] KEY;
	
	output VGA_CLK,VGA_HS,VGA_VS,VGA_BLANK_N,VGA_SYNC_N;
	output [9:0] VGA_R,VGA_G,VGA_B;
	
	wire [7:0] x;
	wire [6:0] y;
						 
	wire reset_n, go, load, writeEn, div_clk, erase;
	wire [5:0] loc;
	wire [2:0] colour;
	
	wire [7:0] x_bus;
	wire [6:0] y_bus;
	
	wire [24:0] shape;
	
	assign reset_n = KEY[0];

	rate_divider r0(.clock(CLOCK_50), .q(div_clk), .reset_n(reset_n));
	
	control_pacman control(.go(go), .shape(shape), .x_out(x_bus), .y_out(y_bus), 
	                       .clock(div_clk), .reset_n(reset_n), .dir_in(SW[9:7]));
	
	control5x5 c0(.plot_sig(writeEn), .go(go), .erase(erase),
				  .reset_n(reset_n), .clock(CLOCK_50), .load(load), .loc(loc));
				  
	data5x5 d0(.col_out(colour), .x_out(x), .y_out(y), .erase(erase),
					.x_in(x_bus), .y_in(y_bus), .load(load), .colour(3'b110), 
					.clock(CLOCK_50), .reset_n(reset_n), .loc(loc), .shape(shape));
					
	vga_adapter VGA(.resetn(reset_n), .clock(CLOCK_50), .colour(colour), .x(x), .y(y), .plot(writeEn),
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
						 .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
						 
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	
endmodule

module test(x, y, KEY, SW, CLOCK_50);
	
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [7:0] x;
	output [6:0] y;
	
	wire reset_n, go, load, writeEn, div_clk, erase;
	wire [5:0] loc;
	wire [2:0] colour;
	
	wire [7:0] x_bus;
	wire [6:0] y_bus;
	
	wire [24:0] shape;
	
	assign reset_n = KEY[0];

	rate_divider r0(.clock(CLOCK_50), .q(div_clk), .reset_n(reset_n));
	
	control_pacman control(.go(go), .shape(shape), .x_out(x_bus), .y_out(y_bus), 
	                       .clock(div_clk), .reset_n(reset_n), .dir_in(SW[9:7]));
	
	control5x5 c0(.plot_sig(writeEn), .go(go), .erase(erase),
				  .reset_n(reset_n), .clock(CLOCK_50), .load(load), .loc(loc));
				  
	data5x5 d0(.col_out(colour), .x_out(x), .y_out(y), .erase(erase),
					.x_in(x_bus), .y_in(y_bus), .load(load), .colour(3'b110), 
					.clock(CLOCK_50), .reset_n(reset_n), .loc(loc), .shape(shape));
	
endmodule

//module control_pacman(go, shape, x_out, y_out, clock, reset_n, dir_in);
//	
//	input clock,reset_n;
//	input [2:0] dir_in;
//	
//	output go;
//	
//	assign go = clock;
//	
//	reg [2:0] current_state,next_state;
//	
//	reg [7:0] x;
//	reg [6:0] y;
//	
//	output reg [7:0] x_out;
//	output reg [6:0] y_out;
//	
//	output [24:0] shape;
//	
//	localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
//	
//	always @(*) begin
//		case(dir_in)
//			WAIT: next_state = WAIT;
//			RIGHT: next_state = RIGHT;
//			UP: next_state = UP;
//			LEFT: next_state = LEFT;
//			DOWN: next_state = DOWN;
//			default: next_state = WAIT;
//		endcase
//	end
//	
//	always @(*) begin
//		case(current_state)
//			WAIT: begin
//				x_out = x;
//				y_out = y;
//			end
//			RIGHT: begin
//				if(x == 8'd26) x_out = 8'd0;
//				else x_out = x+8'd1;
//				y_out = y;
//			end
//			UP: begin
//				x_out = x;
//				if(y == 7'd0) y_out = 7'd23;
//				else y_out = y-7'd1;
//			end
//			LEFT: begin
//				if(x == 8'd0) x_out = 8'd26;
//				else x_out = x-8'd1;
//				y_out = y;
//			end
//			DOWN: begin
//				x_out = x;
//				if(y == 7'd23) y_out = 7'd0;
//				else y_out = y+7'd1;
//			end
//		endcase
//	end
//	
//	always @(posedge clock) begin
//		//Change reset value to starting point?
//		if(!reset_n) begin
//			x <= 8'd0;
//			y <= 7'd0;
//		end
//		else begin
//			if(current_state == RIGHT) begin
//				if(x == 8'd26) x <= 8'd0;
//				else x <= x+8'd1;
//			end
//			else if(current_state == UP) begin
//				if(y == 7'd0) y <= 7'd23;
//				else y <= y-7'd1;
//			end
//			else if(current_state == LEFT) begin
//				if(x == 8'd0) x <= 8'd26;
//				else x <= x-8'd1;
//			end
//			else if(current_state == DOWN) begin
//				if(y == 7'd23) y <= 7'd0;
//				else y <= y+7'd1;
//			end
//		end
//	end
//	
//	always @(posedge clock) begin
//		if(!reset_n) current_state = WAIT;
//		else current_state = next_state;
//	end
//	
//	reg [24:0] next_ani;
//	
//	localparam rightA = 25'b0111011111110001111101110,
//              rightB = 25'b0111011100110001110001110,
//				  upA = 25'b0101011011110111111101110,
//				  upB = 25'b0000010001110111111101110,
//				  leftA = 25'b0111011111000111111101110,
//				  leftB = 25'b0111000111000110011101110,
//				  downA = 25'b0111011111110111101101010,
//				  downB = 25'b0111011111110111000100000;
//				  
//	reg [24:0] next_shape;
//  
//	assign shape = next_ani;
//
//  always @(posedge clock) begin
//    if(!reset_n) begin
//		next_ani <= rightA;
//    end
//    else begin
//		  case(dir_in)
//			RIGHT: begin
//				if(next_ani == upA || next_ani == leftA || next_ani == downA) next_ani <= rightB;
//				else if(next_ani == upB || next_ani == leftB || next_ani == downB) next_ani <= rightA;
//				else next_ani <= (next_ani == rightA) ? rightB : rightA;
//			end
//			UP: begin
//				if(next_ani == rightA || next_ani == leftA || next_ani == downA) next_ani <= upB;
//				else if(next_ani == rightB || next_ani == leftB || next_ani == downB) next_ani <= upA;
//				else next_ani <= (next_ani == upA) ? upB : upA;
//			end
//			LEFT: begin
//				if(next_ani == rightA || next_ani == upA || next_ani == downA) next_ani <= leftB;
//				else if(next_ani == rightB || next_ani == upB || next_ani == downB) next_ani <= leftA;
//				else next_ani <= (next_ani == leftA) ? leftB : leftA;
//			end
//			DOWN: begin
//				if(next_ani == rightA || next_ani == leftA || next_ani == upA) next_ani <= downB;
//				else if(next_ani == rightB || next_ani == leftB || next_ani == upB) next_ani <= downA;
//				else next_ani <= (next_ani == downA) ? downB : downA;
//			end
//			WAIT: begin
//				if(next_ani == rightA || next_ani == rightB) next_ani <= (next_ani == rightA) ? rightB : rightA;
//				else if(next_ani == upA || next_ani == upB) next_ani <= (next_ani == upA) ? upB : upA;
//				else if(next_ani == leftA || next_ani == leftB) next_ani <= (next_ani == leftA) ? leftB : leftA;
//				else next_ani <= (next_ani == downA) ? downB : downA;
//			end
//		 endcase
//    end
//  end
//	
//endmodule

module control5x5(plot_sig, go, reset_n, clock, load, loc, erase);
	 
	input reset_n,go,clock;
	output reg plot_sig,load,erase;
	output [5:0] loc;

	reg enable;

	counter5x5 c0(.q(loc), .clock(clock), .reset_n(reset_n), .enable(enable));

	reg [1:0] current_state, next_state;

	localparam WAIT = 2'b00, ERASE = 2'b01, LOAD = 2'b10, GO = 2'b11;

	always @(*) begin
		case(current_state)       
			WAIT: next_state = go ? ERASE : WAIT;
			ERASE: next_state = (loc == 6'b100100) ? LOAD : ERASE;
			LOAD: next_state = GO;
			GO: next_state = (loc == 6'b100100) ? WAIT : GO;
			default: next_state = WAIT;
		endcase
	end
	 
	always @(*) begin
		load = 1'b0;
		plot_sig = 1'b0;
		enable = 1'b0;
		erase = 1'b0;
		case(current_state)
			WAIT:;
			ERASE: begin
				enable = 1'b1;
				erase = 1'b1;
				plot_sig = 1'b1;
			end
			LOAD: load = 1'b1;
			GO: begin
				enable = 1'b1;
				plot_sig = 1'b1;
			end
		endcase
	end

	 
	always @(posedge clock) begin
		if(!reset_n) current_state <= WAIT;
		else current_state <= next_state;
	end

endmodule

module data5x5(col_out, x_out, y_out, x_in, y_in, load, colour, clock, reset_n, loc, shape, erase);
	
	input [7:0] x_in;
	input [6:0] y_in;
	input [2:0] colour;
	input clock, reset_n, load, erase;
	input [5:0] loc;
	input [24:0] shape;
	
	output reg [2:0] col_out;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	reg [7:0] x;
	reg [6:0] y;
	
	wire [4:0] shape_index;
	
	always @(posedge clock) begin
		if(load) begin
			x <= x_in*3'd5;
			y <= y_in*3'd5;
		end
	end
	
	always @(*) begin
		x_out = x+loc[2:0];
		y_out = y+loc[5:3];
	end
	
	assign shape_index = 3'd5*loc[5:3];
	
	always @(*) begin
		if(erase) col_out = 3'b000;
		else begin
			case(shape[5'd24-(shape_index+loc[2:0])])
				1'b0: col_out = 3'b000;
				1'b1: col_out = colour;
			endcase
		end
	end
	
endmodule

module counter5x5(q, clock, reset_n, enable);
	
	input clock,reset_n,enable;
	output reg [5:0] q;
	
	//The first three bits count to 3'b100.
	//The last three bits count to 3'b100, counting up every time 3'b100 is reached in the first three bits
	always @(posedge clock) begin
		if(!reset_n) q <= 0;
		else if(enable) begin
			if(q == 6'b100100) q <= 6'd0;
			else if(q[2:0] == 3'b100) q <= q + 3'b100;
			else q <= q + 1'b1;
		end
		else q <= q;
	end
	
endmodule

module rate_divider(q, clock, reset_n);
	
	input clock,reset_n;
	output q;
	
	reg [25:0] count;
	
	localparam rate = 26'd100;
	
	always @(posedge clock) begin
		if(!reset_n) count <= rate;
		else if(count == rate) count <= 26'd0;
		else count <= count + 26'd1;
	end
	
	assign q = (count == rate) ? 1'b1 : 1'b0;
	
endmodule
