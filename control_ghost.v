module control_ghost(clk, random_in, reset_n, shape, x_out, y_out, x_dest, y_dest, x_reset, y_reset);

  input clk, reset_n;
  input [7:0] random_in;
  input [7:0] x_dest, x_reset;
  input [6:0] y_dest, y_reset;
  
  output [7:0] x_out;
  output [6:0] y_out;
  output [24:0] shape;
  
  localparam  GHOST_SHAPE = 25'b1111110101101011111110101;
  
   reg [2:0] dir;
	
	wire rand2, map_right, map_left, map_down, map_up;
	
	assign rand2 = random_in % 2;

  assign shape = GHOST_SHAPE;
  
  wire x_diff, y_diff;
  
  assign x_diff = x_dest > x_out;
  assign y_diff = y_dest > y_out;
  
  always @(*) begin
	case({y_diff, x_diff})
		2'b00: dir = rand2 ? 3'b010 : 3'b001;
		2'b01: dir = rand2 ? 3'b000 : 3'b001;
		2'b10: dir = rand2 ? 3'b010 : 3'b011;
		2'b11: dir = rand2 ? 3'b000 : 3'b011;
	endcase
  end
  
  movement_handler ghost_move(.clk(clk), 
										.dir_in(dir), 
										.reset_n(reset_n), 
										.reset_x(x_reset), 
										.reset_y(y_reset), 
										.x_out(x_out), 
										.y_out(y_out));

endmodule