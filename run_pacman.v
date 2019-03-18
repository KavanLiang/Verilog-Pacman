module run_pacman(VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, CLOCK_50, SW, KEY);
	
	input [9:0] SW;
	input [3:0] KEY;
	
	output VGA_CLK,VGA_HS,VGA_VS,VGA_BLANK_N,VGA_SYNC_N,CLOCK_50;
	output [9:0] VGA_R,VGA_G,vGA_B;
	
	vga_adapter VGA(.resetn(resetn), .clock(CLOCK_50), .colour(colour), .x(x), .y(y), .plot(writeEn),
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
						 .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
						 
	wire resetn,go,load,writeEn;
	wire [5:0] loc;
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	reg [24:0] shape;
	
	always @(*) begin
		case(SW[9:7])
			3'b000: shape = 25'b0111011111110001111101110;
			3'b001: shape = 25'b0111011100110001110001110;
			3'b010: shape = 25'b0101011011110111111101110;
			3'b011: shape = 25'b0000010001110111111101110;
			3'b100: shape = 25'b0111011111000111111101110;
			3'b101: shape = 25'b0111000111000110011101110;
			3'b110: shape = 25'b0111011111110111101101010;
			3'b111: shape = 25'b0111011111110111000100000;
		endcase
	end
	
	assign resetn = KEY[0];
	assign go = ~KEY[1];
	
	control5x5 c0(.plot_sig(writeEn), .go(go),
				  .reset_n(resetn), .clock(CLOCK_50), .load(load), .loc(loc));
	data5x5 d0(.col_out(colour), .x_out(x), .y_out(y), 
					.x_in({5'b00000,SW[2:0]}), .y_in({4'b0000,SW[5:3]}), .load(load), .colour(3'b110), 
					.clock(CLOCK_50), .reset_n(resetn), .loc(loc), .shape(shape));
	
endmodule

module test(x, y, KEY, SW, CLOCK_50);
	
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [7:0] x;
	output [6:0] y;
	
	wire resetn,go,load,writeEn;
	wire [5:0] loc;
	wire [2:0] colour;
	
	reg [24:0] shape;
	
	always @(*) begin
		case(SW[9:7])
			3'b000: shape = 25'b0111011111110001111101110;
			3'b001: shape = 25'b0111011100110001110001110;
			3'b010: shape = 25'b0101011011110111111101110;
			3'b011: shape = 25'b0000010001110111111101110;
			3'b100: shape = 25'b0111011111000111111101110;
			3'b101: shape = 25'b0111000111000110011101110;
			3'b110: shape = 25'b0111011111110111101101010;
			3'b111: shape = 25'b0111011111110111000100000;
		endcase
	end
	
	assign resetn = KEY[0];
	assign go = ~KEY[1];
	
	control5x5 c0(.plot_sig(writeEn), .go(go),
				  .reset_n(resetn), .clock(CLOCK_50), .load(load), .loc(loc));
	data5x5 d0(.col_out(colour), .x_out(x), .y_out(y), 
					.x_in({5'b00000,SW[2:0]}), .y_in({4'b0000,SW[5:3]}), .load(load), .colour(3'b110), 
					.clock(CLOCK_50), .reset_n(resetn), .loc(loc), .shape(shape));
	
endmodule

module control5x5(plot_sig, go, reset_n, clock, load, loc);
	
	input reset_n,go,clock;
	output reg plot_sig,load;
	output [5:0] loc;
	
	reg enable;
	
	counter5x5 c0(.q(loc), .clock(clock), .reset_n(reset_n), .enable(enable));
	
	reg [3:0] current_state, next_state;
	
	localparam WAIT = 1'b0, GO = 1'b1;
	
	always @(*) begin
		case(current_state)       
			WAIT: next_state = go ? GO : WAIT;
			GO: next_state = (loc == 6'b100100) ? WAIT : GO;
			default: next_state = WAIT;
		endcase
   end
	 
	always @(*) begin
		load = 1'b0;
		plot_sig = 1'b0;
		enable = 1'b0;
		case(current_state)
			WAIT: load = 1'b1;
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

module data5x5(col_out, x_out, y_out, x_in, y_in, load, colour, clock, reset_n, loc, shape);
	
	input [7:0] x_in;
	input [6:0] y_in;
	input [2:0] colour;
	input clock,reset_n,load;
	input [5:0] loc;
	input [24:0] shape;
	
	output reg [2:0] col_out;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	
	reg [7:0] x;
	reg [6:0] y;
	
	wire [4:0] shape_index;
	
	always @(posedge clock) begin
		if(!reset_n) begin
			x <= 8'b00000000;
			y <= 7'b0000000;
		end
		else begin
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
		case(shape[5'd24-(shape_index+loc[2:0])])
			1'b0: col_out = 3'b000;
			1'b1: col_out = colour;
		endcase
	end
	
endmodule

module counter5x5(q, clock, reset_n, enable);
	input clock,reset_n,enable;
	output reg [5:0] q;
	
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

module rate_divider();
	
	
	
endmodule