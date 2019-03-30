module control_master(clock, plot_en, x, y, colour, reset_n, dir_in, score, rng_en);
	
	input clock, reset_n, rng_en;
	input [2:0] dir_in;
	
	output plot_en;
	output reg [2:0] colour;
	output reg [7:0] x;
	output reg [6:0] y;
	
	localparam WAIT = 4'b000, LOAD = 4'b0001, COMP = 4'b0010, ERASE_PELLET = 4'b0011, ERASE_PAC = 4'b0100, 
				  ERASE_G1 = 4'b0101, PELLET = 4'b0110, PAC = 4'b0111, G1 = 4'b1000;
				  
	wire [3:0] curr_state;
	wire erase, load;
	wire [5:0] loc;
	
	wire clock_div;
	
	wire [7:0] num_rand;
	
	output [23:0] score;
	
	reg alu_en, dead;
	
	score_alu alu(.score(score),
	              .alu_select(2'b00), 
					  .clk(clock_div), 
					  .reset_n(reset_n), 
					  .enable(alu_en));
	
	random_generator rng(.clk(clock_div),
	                     .enable(rng_en),
								.reset_n(reset_n),
								.q(num_rand));
	
	rate_divider div(.q(clock_div),
	                 .clock(clock),
						  .reset_n(reset_n));
	
	control_game control(.curr_state(curr_state), 
	                      .plot_en(plot_en), 
								 .clock(clock), 
								 .reset_n(reset_n), 
								 .go(clock_div), 
								 .erase(erase), 
								 .loc(loc),
	                      .load(load),
								 .init_done(1'b1),
								 .dead(dead));
								
	wire [7:0] x_pac, x_pac_bus;
	wire [6:0] y_pac, y_pac_bus;
	wire [2:0] col_pac;
	wire [24:0] shape_pac_bus;
	
	data5x5 pac_data(.col_out(col_pac),
    	              .x_out(x_pac), 
						  .y_out(y_pac), 
						  .x_in(x_pac_bus), 
						  .y_in(y_pac_bus), 
						  .load(load), 
						  .colour(3'b110), 
						  .clock(clock), 
						  .reset_n(reset_n), 
						  .loc(loc), 
						  .shape(shape_pac_bus), 
						  .erase(erase));
						  
	control_pacman pac_control(.shape(shape_pac_bus),
	                           .x_out(x_pac_bus),
										.y_out(y_pac_bus),
										.clock(clock_div),
										.reset_n(reset_n),
										.dir_in(dir_in));
						  
	wire [7:0] x_pellet;
	wire [6:0] y_pellet;
	wire [2:0] col_pellet;
	wire [24:0] shape_pellet_bus;
	
	data5x5 pellet_data(.col_out(col_pellet),
    	                 .x_out(x_pellet), 
							  .y_out(y_pellet), 
						     .x_in(8'd4), 
						     .y_in(7'd1), 
						     .load(load), 
						     .colour(3'b110), 
						     .clock(clock), 
						     .reset_n(reset_n), 
						     .loc(loc), 
						     .shape(shape_pellet_bus), 
						     .erase(erase));
	
	pellet_shaper pellet_shape(.shape(shape_pellet_bus),
	                           .clock(clock_div),
										.reset_n(reset_n));  
							  
	wire [7:0] x_g1, x_g1_bus;
	wire [6:0] y_g1, y_g1_bus;
	wire [2:0] col_g1;
	wire [24:0] shape_g1_bus;
	
	data5x5 g1_data(.col_out(col_g1),
	                    .x_out(x_g1),
							  .y_out(y_g1),
							  .x_in(x_g1_bus),
							  .y_in(y_g1_bus),
							  .load(load),
							  .colour(3'b100),
							  .clock(clock),
							  .reset_n(reset_n),
							  .loc(loc),
							  .shape(shape_g1_bus),
							  .erase(erase));
	
	control_ghost g1_control(.clk(clock_div),
 	                         .random_in(num_rand), 
									 .reset_n(reset_n), 
									 .shape(shape_g1_bus), 
									 .x_out(x_g1_bus),
									 .y_out(y_g1_bus),
									 .x_pac(x_pac_bus),
									 .y_pac(y_pac_bus));
							  
	always @(posedge clock) begin
		if(curr_state == COMP) begin
			if(x_pac_bus == 8'd4 && y_pac_bus == 7'd1) begin
				alu_en <= 1'b1;
			end
			else alu_en <= 1'b0;
		end
	end
					
	always @(*) begin
		//Arbitrary default values (the VGA does not plot at these coordinates)
		if(!reset_n) dead <= 1'b0;
		case(curr_state)
			WAIT:;
			PELLET, ERASE_PELLET: begin
				x = x_pellet;
				y = y_pellet;
				colour = col_pellet;
			end
			PAC, ERASE_PAC: begin
				x = x_pac;
				y = y_pac;
				colour = col_pac;
			end
			G1, ERASE_G1: begin
				x = x_g1;
				y = y_g1;
				colour = col_g1;
			end
			COMP: begin
				if(x_pac_bus == x_g1_bus && y_pac_bus == y_g1_bus) dead <= 1'b1;
			end
		endcase
	end
	
endmodule

module control_game(curr_state, plot_en, clock, reset_n, go, erase, loc, load, init_done, dead);

	input clock, reset_n, go, init_done, dead;
	
	output reg plot_en, erase, load;
	output [3:0] curr_state;
	output [5:0] loc;
	
	localparam WAIT = 4'b000, LOAD = 4'b0001, COMP = 4'b0010, ERASE_PELLET = 4'b0011, ERASE_PAC = 4'b0100, 
				  ERASE_G1 = 4'b0101, PELLET = 4'b0110, PAC = 4'b0111, G1 = 4'b1000, INIT_RAND = 4'b1001, 
				  LOC_MAX = 6'b100100;
	
	reg [3:0] current_state, next_state;
	
	initial current_state = WAIT;
	
	reg count5x5_en;
	
	counter5x5 c0(.q(loc), .clock(clock), .reset_n(reset_n), .enable(count5x5_en));
	
	always @(*) begin
		case(current_state)
			WAIT: next_state = go ? INIT_RAND : WAIT;
			INIT_RAND: next_state = init_done ? ERASE_PELLET : INIT_RAND;
			ERASE_PELLET: next_state = (loc == LOC_MAX) ? ERASE_PAC : ERASE_PELLET;
			ERASE_PAC: next_state = (loc == LOC_MAX) ? ERASE_G1 : ERASE_PAC;
			ERASE_G1: next_state = dead ? ERASE_PELLET : ((loc == LOC_MAX) ? LOAD : ERASE_G1);
			LOAD: next_state = PELLET;
			PELLET: next_state = (loc == LOC_MAX) ? PAC : PELLET;
		   PAC: next_state = (loc == LOC_MAX) ? G1 : PAC;
			G1: next_state = (loc == LOC_MAX) ? COMP : G1;
			COMP: next_state = dead ? ERASE_PELLET : WAIT;
		endcase
	end
	
	always @(*) begin
		count5x5_en = 1'b0;
		erase = 1'b0;
		plot_en = 1'b0;
		load = 1'b0;
		case(current_state)
			WAIT:;
			ERASE_PAC, ERASE_PELLET, ERASE_G1: begin
				count5x5_en = 1'b1;
				plot_en = 1'b1;
				erase = 1'b1;
			end
			LOAD: load = 1'b1;
			PELLET, PAC, G1: begin
				count5x5_en = 1'b1;
				plot_en = 1'b1;
			end
			COMP:;
		endcase
	end
	
	always @(posedge clock) begin
		if(!reset_n) current_state <= WAIT;
		else current_state <= next_state;
	end
	
	assign curr_state = current_state;
	
endmodule

//module rate_divider(q, clock, reset_n);
//	
//	input clock,reset_n;
//	output q;
//	
//	reg [25:0] count;
//	
//	//TODO: Make game faster as score increases
//	localparam rate = 26'd170;
//	
//	always @(posedge clock) begin
//		if(!reset_n) count <= rate;
//		else if(count == rate) count <= 26'd0;
//		else count <= count + 26'd1;
//	end
//	
//	assign q = (count == rate) ? 1'b1 : 1'b0;
//	
//endmodule

//module counter5x5(q, clock, reset_n, enable);
//	
//	input clock,reset_n,enable;
//	output reg [5:0] q;
//	
//	initial q <= 6'd0;
//	
//	//The first three bits count to 3'b100.
//	//The last three bits count to 3'b100, counting up every time 3'b100 is reached in the first three bits
//	always @(posedge clock) begin
//		if(!reset_n) q <= 0;
//		else if(enable) begin
//			if(q == 6'b100100) q <= 6'd0;
//			else if(q[2:0] == 3'b100) q <= q + 3'b100;
//			else q <= q + 1'b1;
//		end
//		else q <= q;
//	end
//	
//endmodule

//module control_pacman(shape, x_out, y_out, clock, reset_n, dir_in);
//
//	input clock,reset_n;
//	input [2:0] dir_in;
//	output [24:0] shape;
//	output [7:0] x_out;
//	output [6:0] y_out;
//
//	localparam  DEFAULT_X = 8'd2, DEFAULT_Y = 7'd1;
//
//	//Assign to shape the correct shape for the pac-man
//	pac_shaper p0(.shape(shape), 
//	              .dir_in(dir_in), 
//					  .clock(clock), 
//					  .reset_n(reset_n));
//					  
//	//Assign the resulting x and y coordinates to the x and y outputs
//	movement_handler pac_move(.clk(clock),
//	                          .dir_in(dir_in), 
//									  .reset_n(reset_n), 
//									  .reset_x(DEFAULT_X), 
//									  .reset_y(DEFAULT_Y), 
//									  .x_out(x_out), 
//									  .y_out(y_out));
//
//endmodule

//module movement_handler(clk, dir_in, reset_n, reset_x, reset_y, x_out, y_out);
//
//   input clk,reset_n;
//	input [2:0] dir_in;
//	input [7:0] reset_x;
//   input [6:0] reset_y;
//   	
//	output [7:0] x_out;
//	output [6:0] y_out;
//
//	reg [7:0] x, x_next;
//	reg [6:0] y, y_next;
//
//	wire map_state;
//
//	localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
//
//	//Assign to shape the correct shape for the pac-man
//	 always @(*) begin
//		x_next = x;
//		y_next = y;
//		case(dir_in)
//			RIGHT: x_next = x+8'b1;
//			UP: y_next = y-7'b1;
//			LEFT: x_next = x-8'b1;
//			DOWN: y_next = y+7'b1;
//		endcase
//	 end
//
//	 map_lut map(.q(map_state), .x(x_next), .y(y_next));
//
//	 assign x_out = x;
//	 assign y_out = y;
//
//	 always @(posedge clk) begin
//		//Change reset value to starting point
//		if(!reset_n) begin
//			x <= reset_x;
//			y <= reset_y;
//		end
//		else begin
//			if(dir_in == RIGHT) begin
//				if(x == 8'd26) x <= 8'd0;
//				else if(map_state == 1'b1) x <= x_next-8'd1;
//				else x <= x_next;
//			end
//			else if(dir_in == UP) begin
//				if(y == 7'd0) y <= 7'd23;
//				else if(map_state == 1'b1) y <= y_next+8'd1;
//				else y <= y_next;
//			end
//			else if(dir_in == LEFT) begin
//				if(x == 8'd0) x <= 8'd26;
//				else if(map_state == 1'b1) x <= x_next+8'd1;
//				else x <= x_next;
//			end
//			else if(dir_in == DOWN) begin
//				if(y == 7'd23) y <= 7'd0;
//				else if(map_state == 1'b1) y <= y_next-8'd1;
//				else y <= y_next;
//			end
//			else if(dir_in == WAIT) begin
//				x <= x_next;
//				y <= y_next;
//			end
//		end
//	 end
//  
//endmodule

//module pac_shaper(shape, dir_in, clock, reset_n);
//
//	input clock, reset_n;
//	input [2:0] dir_in;
//	
//	output [24:0] shape;
//	
//	reg [24:0] next_ani;
//    
//	localparam rightA = 25'b0111011111110001111101110,
//				  rightB = 25'b0111011100110001110001110,
//				  upA = 25'b0101011011110111111101110,
//				  upB = 25'b0000010001110111111101110,
//				  leftA = 25'b0111011111000111111101110,
//				  leftB = 25'b0111000111000110011101110,
//				  downA = 25'b0111011111110111101101010,
//				  downB = 25'b0111011111110111000100000,
//				  WAIT = 3'b100, 
//				  RIGHT = 3'b000, 
//				  UP = 3'b001, 
//				  LEFT = 3'b010, 
//				  DOWN = 3'b011;
//				  
//	assign shape = next_ani;
//   
//	always @(posedge clock) begin
//		if(!reset_n) begin
//			next_ani <= rightA;
//		end
//		else begin
//			case(dir_in)
//				RIGHT: begin
//					if(next_ani == upA || next_ani == leftA || next_ani == downA) next_ani <= rightB;
//					else if(next_ani == upB || next_ani == leftB || next_ani == downB) next_ani <= rightA;
//					else next_ani <= (next_ani == rightA) ? rightB : rightA;
//				end
//				UP: begin
//					if(next_ani == rightA || next_ani == leftA || next_ani == downA) next_ani <= upB;
//					else if(next_ani == rightB || next_ani == leftB || next_ani == downB) next_ani <= upA;
//					else next_ani <= (next_ani == upA) ? upB : upA;
//				end
//				LEFT: begin
//					if(next_ani == rightA || next_ani == upA || next_ani == downA) next_ani <= leftB;
//					else if(next_ani == rightB || next_ani == upB || next_ani == downB) next_ani <= leftA;
//					else next_ani <= (next_ani == leftA) ? leftB : leftA;
//				end
//				DOWN: begin
//					if(next_ani == rightA || next_ani == leftA || next_ani == upA) next_ani <= downB;
//					else if(next_ani == rightB || next_ani == leftB || next_ani == upB) next_ani <= downA;
//					else next_ani <= (next_ani == downA) ? downB : downA;
//				end
//				WAIT: begin
//					if(next_ani == rightA || next_ani == rightB) next_ani <= (next_ani == rightA) ? rightB : rightA;
//					else if(next_ani == upA || next_ani == upB) next_ani <= (next_ani == upA) ? upB : upA;
//					else if(next_ani == leftA || next_ani == leftB) next_ani <= (next_ani == leftA) ? leftB : leftA;
//					else next_ani <= (next_ani == downA) ? downB : downA;
//				end
//			endcase
//		end
//	end
//	
//endmodule

//module control_ghost(clk, random_in, reset_n, shape, x_out, y_out);
//  input clk, reset_n;
//  input [7:0] random_in;
//  output [7:0] x_out;
//  output [6:0] y_out;
//  output [24:0] shape;
//
//  wire [2:0] dir = random_in % 5;
//
//  localparam  GHOST_SHAPE = 25'b1111110101101011111110101, DEFAULT_X = 8'd6, DEFAULT_Y = 7'd5;
//
//  assign shape = GHOST_SHAPE;
//
//  movement_handler ghost_move(.clk(clk), .dir_in(dir), .reset_n(reset_n), .reset_x(DEFAULT_X), .reset_y(DEFAULT_Y), .x_out(x_out), .y_out(y_out));
//
//endmodule

module control_pellet(done, clock, reset_n, go, x_out, y_out);

	input reset_n, clock, go;
	
	output [7:0] x_out;
	output [6:0] y_out;
	
	wire map_state;
	reg rng_en;
	
	reg [7:0] x;
	reg [6:0] y;
	
	initial begin
		x <= 8'd0;
		y <= 7'd0;
	end
	
	wire [7:0] num_rand;
	
	localparam WAIT = 1'b0, SEARCH = 1'b1;
	
	output reg done;
	
	reg current_state, next_state;
	
	assign x_out = x;
	assign y_out = y;
	
	always @(*) begin
		case(current_state)
			WAIT: next_state = go ? SEARCH : WAIT;
			SEARCH: next_state = done ? WAIT : SEARCH;
		endcase
	end
	
	always @(*) begin
		case(current_state)
			WAIT: begin
				rng_en = 1'b0;
				done <= 1'b0;
			end
			SEARCH: begin
				rng_en = 1'b1;
			end
		endcase
	end
	
	random_generator rng(.q(num_rand), .clk(clock), .reset_n(reset_n), .enable(rng_en));
	
	map_lut map(.q(map_state), 
	            .x(x), 
					.y(y));
					
	always @(posedge clock) begin
		if(current_state == SEARCH) begin
			if(map_state == 1'b1) begin
				x <= num_rand % 27;
				y <= num_rand % 24;
			end
			else done <= 1'b1;
		end
	end
					
	always @(posedge clock) begin
		if(!reset_n) current_state <= WAIT;
		else current_state <= next_state;
	end
	
endmodule

//module map_lut(q, x, y);
//
//	input [7:0] x;
//	input [6:0] y;
//	
//	output q;
//	
//	reg [0:23] col;
//	
//	localparam col0 = 24'b111111111101111111111111,
//	           col1 = 24'b111111111101111111111111,
//				  col2 = 24'b100000011101110000000001,
//				  col3 = 24'b101101011101110101000101,
//				  col4 = 24'b101101011101110101110101,
//				  col5 = 24'b101101011101110101110101,
//				  col6 = 24'b100000000000000000000101,
//				  col7 = 24'b101101111101110101110101,
//				  col8 = 24'b101100000000000100000101,
//				  col9 = 24'b101101111101110101011101,
//				  col10 = 24'b100000010000010001000101,
//				  col11 = 24'b101101010111010101010101,
//				  col12 = 24'b101101000101010100010001,
//				  col13 = 24'b101101110001010111011101;
//	
//	always @(*) begin
//		case(x)
//			8'd0,8'd26: col = col0;
//			8'd1,8'd25: col = col1;
//			8'd2,8'd24: col = col2;
//			8'd3,8'd23: col = col3;
//			8'd4,8'd22: col = col4;
//			8'd5,8'd21: col = col5;
//			8'd6,8'd20: col = col6;
//			8'd7,8'd19: col = col7;
//			8'd8,8'd18: col = col8;
//			8'd9,8'd17: col = col9;
//			8'd10,8'd16: col = col10;
//			8'd11,8'd15: col = col11;
//			8'd12,8'd14: col = col12;
//			8'd13: col = col13;
//			default: col = 24'b000000000000000000000000;
//		endcase
//	end
//	
//	assign q = col[y];
//	
//endmodule

//module random_generator(clk, enable, reset_n, q);
//  input clk, enable;
//  output [7:0] q;
//  input reset_n;
//
//  reg [7:0] counter;
//  reg [7:0] seed;
//  reg [7:0] outNext;
//  reg [7:0] out;
//
//  assign q = out;
//  
//  initial out <= 8'b10101010;
//
//  always @(posedge clk) begin
//    if(!reset_n) begin
//      seed <= 8'b10101010;
//      counter <= 0;
//    end
//    else if(enable) begin
//      seed <= counter;
//    end
//    else begin
//      counter <= counter == 8'b11111111 ? 8'b0 : counter + 1'b1;
//    end
//  end
//
//  always @(*) begin
//    if(!reset_n) begin
//      outNext <= seed;
//    end
//    else begin
//      outNext[7] <= out[7] ^ out[1];
//      outNext[6] <= out[6] ^ out[0];
//      outNext[5] <= out[5] ^ outNext[7];
//      outNext[4] <= out[4] ^ outNext[6];
//      outNext[3] <= out[3] ^ outNext[5];
//      outNext[2] <= out[2] ^ outNext[4];
//      outNext[1] <= out[1] ^ outNext[3];
//    end
//  end
//
//  always @(posedge clk) begin
//    if(!reset_n) begin
//        out <=  8'b10101010;
//    end
//    else begin
//        out <= outNext;
//    end
//  end
//endmodule

//module score_alu(score, alu_select, clk, reset_n, enable);
//	
//	input clk,reset_n,enable;
//	input [1:0] alu_select;
//	
//	reg [23:0] score_reg;
//	
//	output [23:0] score;
//	
//	initial score_reg = 24'd0;
//	
//	assign score = score_reg;
//	
//	always @(posedge clk) begin
//		if(!reset_n) score_reg <= 24'd0;
//		else begin
//		   score_reg <= score_reg + 24'd0;
//		   if(enable) begin
//				if(alu_select == 2'b00) score_reg <= score_reg + 24'd10;
//				else if(alu_select == 2'b01) score_reg <= score_reg + 24'd20;
//				else if(alu_select == 2'b10) score_reg <= score_reg + 24'd50;
//				else if(alu_select == 2'b11) score_reg <= score_reg <<< 24'd1;
//			end
//		end
//	end
//	
//endmodule