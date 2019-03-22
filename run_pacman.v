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
