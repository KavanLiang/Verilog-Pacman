module control_init(done, plot_en, x, y, go, clock, reset_n);
	
	input clock, reset_n, go;
	
	output done, plot_en;
	output [7:0] x;
	output [6:0] y;
	
	wire count_en;
	
	count27x24 c0(.q(count), .clock(clock), .reset_n(reset_n));
	
	reg [1:0] current_state, next_state;
	
	localparam WAIT = 2'b00, GO = 2'b01, DONE = 2'b11;
	
	always @(*) begin
		case(current_state) begin
			WAIT: next_state = go ? GO : WAIT;
			GO: (count == 10'b1100011011) next_state = ? DONE : GO;
			DONE: next_state = WAIT;
		end
	end
	
	always @(*) begin
		done = 1'b0;
		count_en = 1'b0;
		plot_en = 1'b0;
		case(current_state) begin
			GO: begin
				count_en = 1'b1;
				plot_en = 1'b1;
				x = count[4:0];
				y = count[9:5]
			end
			DONE: done = 1'b1;
		end
	end
	
	always @(posedge clock) begin
		if(!reset_n) current_state = WAIT;
		else current_state = next_state;
	end
	
endmodule

module control_game(curr_state, write_en, clock, reset_n, done, go);

	input clock, reset_n;
	
	output write_en;
	output [7:0] x;
	output [6:0] y;
	
	localparam INIT = 3'b100, PAC = 3'b000, G1 = 3'b001, G2 = 3'b010, G3 = 3'b011, WAIT = 3'b101, COMP = 3'b110, ERASE = 3'b111;
	
	wire p_count;
	
	reg [2:0] current_state, next_state;
	
	always @(*) begin
		case(current_state)
			INIT: next_state = done ? PAC : INIT;
			WAIT: next_state = go ? ERASE : WAIT;
			ERASE: next_state = done ? PAC : ERASE
		   PAC: next_state = done ? G1 : PAC;
			G1: next_state = done ? G2 : G1;
			G2: next_state = done ? G3 : G2;
			G3: next_state = done ? COMP : G3;
			COMP: next_state = WAIT;
		endcase
	end
	
	always @(*) begin
		case(current_state)
			INIT: begin
				x = {3'b000, p_count[4:0]};
				y = {2'b00, p_count[9:0]};
			end
			PAC: 
		endcase
	endcase
	
	always @(posedge clock) begin
		if(!reset_n) current_state <= INIT;
		else currenct_state <= next_state;
	end
	
endmodule