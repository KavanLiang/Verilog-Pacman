module controlable_ghost(clk, reset_n, shape, x_out, y_out, dir);

  input clk, reset_n;
  input [2:0] dir;
  
  output [7:0] x_out;
  output [6:0] y_out;
  output [24:0] shape;
  
  localparam  GHOST_SHAPE = 25'b1111110101101011111110101, DEFAULT_X = 8'd2, DEFAULT_Y = 7'd1;

  assign shape = GHOST_SHAPE;
  
  movement_handler control_ghost(.clk(clk), .dir_in(dir), .reset_n(reset_n), .reset_x(DEFAULT_X), .reset_y(DEFAULT_Y), .x_out(x_out), .y_out(y_out));

endmodule