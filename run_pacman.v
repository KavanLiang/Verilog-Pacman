module run_pacman(VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, 
						CLOCK_50, SW, KEY, PS2_CLK, PS2_DAT, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	
	input CLOCK_50;
	input [9:0] SW;
	input [3:0] KEY;
	
	inout PS2_CLK, PS2_DAT;
	
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B, LEDR;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	
	wire [7:0] x;
	wire [6:0] y;
						 
	wire reset_n, go, load, writeEn, div_clk, erase;
	wire [5:0] loc;
	wire [2:0] colour;
	
	wire [7:0] x_bus;
	wire [6:0] y_bus;
	
	wire [24:0] shape;
	
	wire w,a,s,d,up,left,down,right,up_in,right_in,left_in,down_in, space, enter;
	reg [3:0] dir;
	
	assign reset_n = KEY[0];
	
	/*
	reg done;
	
	always @(posedge CLOCK_50) begin
		if(done) done = 1'b0;
	end
	
	always @(*) begin
		init_go = 0;
		pac_go = 0;
		done = 0;
		plot_en = 0;
		erase = 0;
		case(curr_state)
			INIT: begin
				init_go = 1;
				done = init_done;
				x_bus = init_x;
				y_bus = init_y;
				plot_en = init_plot;
				erase = 0;
			end
			PAC: begin
				x_bus = pac_x;
				y_bus = pac_y;
				pac_go = 1;
			end
		endcase
	end
	
	control_game game(.go(div_clk), .done(done));
	
	control_init init(.done(init_done), .go(init_go), .plot_en(init_plot), .x(init_x), .y(init_y), .reset_n(reset_n));
	
	pellet_map p0(.clock(CLOCK_50));
	*/
	
	//Use a MUX to choose which control module to use
	
	//for ghost-player collision detection, we can compare their x-,y-bus values.
	
	always @(*) begin
		case({s,w,a,d})
			4'b0001: dir = 3'b000;
			4'b0010: dir = 3'b010;
			4'b0100: dir = 3'b001;
			4'b1000: dir = 3'b011;
			default: dir = 3'b100;
		endcase
	end
	
	wire [23:0] score;

	score_alu alu(.score(score), .alu_select(2'b00), .clk(div_clk), .reset_n(reset_n), .enable(1'b0));
	
	hex_decoder h5(.hex_digit(score[23:20]), .segments(HEX5));
	hex_decoder h4(.hex_digit(score[19:16]), .segments(HEX4));
	hex_decoder h3(.hex_digit(score[15:12]), .segments(HEX3));
	hex_decoder h2(.hex_digit(score[11:8]), .segments(HEX2));
	hex_decoder h1(.hex_digit(score[7:4]), .segments(HEX1));
	hex_decoder h0(.hex_digit(score[3:0]), .segments(HEX0));
	
	rate_divider r0(.clock(CLOCK_50), .q(div_clk), .reset_n(reset_n));
	
	control_pacman control(.shape(shape), .x_out(x_bus), .y_out(y_bus), 
	                       .clock(div_clk), .reset_n(reset_n), .dir_in(dir));
	
	control5x5 c0(.plot_sig(writeEn), .go(div_clk), .erase(erase),
				  .reset_n(reset_n), .clock(CLOCK_50), .load(load), .loc(loc));
				  
	data5x5 d0(.col_out(colour), .x_out(x), .y_out(y), .erase(erase),
					.x_in(x_bus), .y_in(y_bus), .load(load), .colour(3'b110), 
					.clock(CLOCK_50), .reset_n(reset_n), .loc(loc), .shape(shape));
					
	vga_adapter VGA(.resetn(reset_n), .clock(CLOCK_50), .colour(colour), .x(x), .y(y), .plot(writeEn),
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
						 .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
						 
	keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(.clock(CLOCK_50), .reset(reset_n), .PS2_CLK(PS2_CLK),
																.PS2_DAT(PS2_DAT), .w(w), .a(a), .s(s),
																.d(d), .left(left), .right(right), .up(up),
																.down(down), .space(space), .enter(enter));
	
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

module rate_divider(q, clock, reset_n, rate_offset);
	
	input clock,reset_n;
	input [23:0] rate_offset;
	output q;
	
	reg [25:0] count;
	
	//TODO: Make game faster as score increases
	localparam rate = 26'd12500000;
	
	always @(posedge clock) begin
		if(!reset_n) count <= rate;
		else if(count == rate) count <= 26'd0;
		else count <= count + 26'd1;
	end
	
	assign q = (count == rate) ? 1'b1 : 1'b0;
	
endmodule