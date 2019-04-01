module control_pellet(done_out, clock, reset_n, go, x_out, y_out, enable);

	input reset_n, clock, go, enable;
	
	output [7:0] x_out;
	output [6:0] y_out;
	output reg done_out;
	
	reg done;
	reg [1:0] current_state, next_state;
	reg [7:0] x;
	reg [6:0] y;
	
	wire map_state;
	wire [7:0] num_rand;
	
	localparam WAIT = 2'b00, SET = 2'b01, SEARCH = 2'b10, DONE = 2'b11;
	
	initial begin
		x <= 8'd2;
		y <= 7'd1;
	end
	
	assign x_out = x;
	assign y_out = y;
	
	always @(*) begin
		case(current_state)
			WAIT: next_state = go ? (enable ? SET : DONE) : WAIT;
			SET: next_state = SEARCH;
			SEARCH: next_state = done ? DONE : SEARCH;
			DONE: next_state = WAIT;
		endcase
	end
	
	always @(*) begin
		done_out = 1'b0;
		case(current_state)
			WAIT: done <= 1'b0;
			SEARCH:;
			DONE: done_out = 1'b1;
		endcase
	end
	
	random_generator rng(.q(num_rand), .clock(clock), .reset_n(reset_n));
	
	map_lut map(.q(map_state), 
	            .x(x), 
					.y(y));
					
	always @(posedge clock) begin
		if(!reset_n) begin
			x <= num_rand % 27;
			y <= num_rand % 24;
		end
		else
		if(enable) begin
			if(current_state == SET) begin
				x <= num_rand % 27;
				y <= num_rand % 24;
			end
			else
			if(current_state == SEARCH) begin
				if(map_state == 1'b1) begin
					x <= num_rand % 27;
					y <= num_rand % 24;
				end
				else done <= 1'b1;
			end
		end
	end
					
	always @(posedge clock) begin
		if(!reset_n) current_state <= WAIT;
		else current_state <= next_state;
	end
	
endmodule