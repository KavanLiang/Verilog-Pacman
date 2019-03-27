module control_ghost(clk, random_in, reset_n, shape, x_out, y_out);
  input clk, reset_n;
  input [7:0] random_in;
  output [7:0] x_out, y_out;
  output [25:0] shape;

  wire [2:0] dir = random_in % 5;

  localparam  GHOST_SHAPE = 25'b1111110101101011111110101, DEFAULT_X = 8'd27, DEFAULT_Y = 7'd24;

  assign shape = GHOST_SHAPE;

  movement_handler ghost_move(.clk(clk), dir_in(dir), reset_n(reset_n), reset_x(DEFAULT_X), reset_y(DEFAULT_Y), x_out(x_out), y_out(y_out));

endmodule
