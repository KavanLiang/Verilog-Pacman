//`include "map_lut.v"
//`include "random_generator.v"
//`include "control_pellet.v"
//`include "control_ghost.v"
//`include "control_pacman.v"
//`include "alu.v"
//`include "run_pacman.v"
//`include "pac_shaper.v"
//`include "pellet_shaper.v"
//`include "movement_handler.v"

module control_master(clock, plot_en, x, y, colour, reset_n, dir_in, score);
	
	input clock, reset_n;
	input [2:0] dir_in;
	
	output plot_en;
	output [23:0] score;
	output reg [2:0] colour;
	output reg [7:0] x;
	output reg [6:0] y;
		
	reg alu_en, dead;	
		
	wire erase, load, clock_div;		
	wire [3:0] curr_state;
	wire [5:0] loc;
	wire [7:0] num_rand;
	
	localparam WAIT = 4'b000, LOAD = 4'b0001, COMP = 4'b0010, ERASE_PELLET = 4'b0011, ERASE_PAC = 4'b0100, 
				  ERASE_G1 = 4'b0101, PELLET = 4'b0110, PAC = 4'b0111, G1 = 4'b1000, INIT_RAND = 4'b1001;
	
	score_alu alu(.score(score),
	              .alu_select(2'b00), 
					  .clk(clock_div), 
					  .reset_n(reset_n), 
					  .enable(alu_en));
	
	random_generator rng(.clock(clock_div),
								.reset_n(reset_n),
								.q(num_rand));
	
	rate_divider div(.q(clock_div),
	                 .clock(clock),
						  .reset_n(reset_n));
	
	reg go_init;
	
	wire done_init;
	
	always @(*) begin
		case(curr_state)
			INIT_RAND: go_init = 1'b1;
			default: go_init = 1'b0;
		endcase
	end
	
	control_game control(.curr_state(curr_state), 
	                     .plot_en(plot_en), 
								.clock(clock), 
								.reset_n(reset_n), 
								.go(clock_div), 
								.erase(erase), 
								.loc(loc),
	                     .load(load),
								.init_done(done_init),
								.dead(dead));
	reg [7:0] x_pac_prev;
   reg [6:0] y_pac_prev;
	
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
	
	wire [7:0] x_pellet, x_pellet_bus;
	wire [6:0] y_pellet, y_pellet_bus;
	wire [2:0] col_pellet;
	wire [24:0] shape_pellet_bus;
	
	reg pellet_new;
	
	initial pellet_new <= 1'b1;
	
	data5x5 pellet_data(.col_out(col_pellet),
    	                 .x_out(x_pellet), 
							  .y_out(y_pellet), 
						     .x_in(x_pellet_bus), 
						     .y_in(y_pellet_bus), 
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
										
	control_pellet pellet_control(.done_out(done_init), 
											.clock(clock), 
											.reset_n(reset_n), 
											.go(go_init), 
											.x_out(x_pellet_bus), 
											.y_out(y_pellet_bus), 
											.enable(pellet_new));
	reg [7:0] x_g1_prev;
	reg [6:0] y_g1_prev;
	
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
			if(x_pac_bus == x_pellet_bus && y_pac_bus == y_pellet_bus) begin
				alu_en <= 1'b1;
				pellet_new <= 1'b1;
			end
			else alu_en <= 1'b0;
		end
	end
					
	always @(*) begin
		if(!reset_n) dead <= 1'b0;
		case(curr_state)
			WAIT:;
			INIT_RAND:;
			PELLET, ERASE_PELLET: begin
			   pellet_new <= 1'b0;
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
				else if(x_pac_prev == x_g1_bus && y_pac_prev == y_g1_bus && x_pac_bus == x_g1_prev && y_pac_bus == y_g1_prev) dead <= 1'b1;
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