module run_pacman(VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, 
						CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	
	input CLOCK_50;
	input [3:0] KEY;
	
	inout PS2_CLK, PS2_DAT;
	
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	output [9:0] VGA_R, VGA_G, VGA_B, LEDR;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	
	wire [7:0] x;
	wire [6:0] y;
						 
	wire reset_n, plot_en;
	wire [2:0] colour;
	
	wire w, a, s, d, up, left, down, right, space, enter;
	reg [3:0] dir;
	
	assign reset_n = KEY[0];
	
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

	control_master game(.clock(CLOCK_50), 
	                    .plot_en(plot_en), 
							  .x(x), 
							  .y(y), 
							  .colour(colour), 
							  .reset_n(reset_n), 
							  .dir_in(dir), 
							  .score(score));
	
	hex_decoder h5(.hex_digit(score[23:20]), .segments(HEX5));
	hex_decoder h4(.hex_digit(score[19:16]), .segments(HEX4));
	hex_decoder h3(.hex_digit(score[15:12]), .segments(HEX3));
	hex_decoder h2(.hex_digit(score[11:8]), .segments(HEX2));
	hex_decoder h1(.hex_digit(score[7:4]), .segments(HEX1));
	hex_decoder h0(.hex_digit(score[3:0]), .segments(HEX0));
					
	vga_adapter VGA(.resetn(reset_n), .clock(CLOCK_50), .colour(colour), .x(x), .y(y), .plot(plot_en),
						 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
						 .VGA_BLANK(VGA_BLANK_N), .VGA_SYNC(VGA_SYNC_N), .VGA_CLK(VGA_CLK));
						 
	keyboard_tracker #(.PULSE_OR_HOLD(0)) tester(.clock(CLOCK_50), .reset(reset_n), .PS2_CLK(PS2_CLK),
																.PS2_DAT(PS2_DAT), .w(w), .a(a), .s(s),
																.d(d), .left(left), .right(right), .up(up),
																.down(down), .space(space), .enter(enter));
	
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
	
	initial q <= 6'd0;
	
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
	
	//TODO: Make game faster as score increases
	localparam rate = 26'd200;
	
	always @(posedge clock) begin
		if(!reset_n) count <= rate;
		else if(count == rate) count <= 26'd0;
		else count <= count + 26'd1;
	end
	
	assign q = (count == rate) ? 1'b1 : 1'b0;
	
endmodule