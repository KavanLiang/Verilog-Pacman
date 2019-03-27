//new x, y if new_coord is high; x_out, y_out can be invalid
module pellet_datapath(clock, new_coord, rand_x, rand_y, valid_coord, reset_n, x_out, y_out);
  input clock, div_clock, new_coord, reset_n;
  input [7:0] random_in;

  input [7:0] rand_x;
  input [6:0] rand_y;

  output [7:0] x_out;
  output [6:0] y_out;
  output [24:0] shape;
  output valid_coord;

  reg [7:0] x;
  reg [6:0] y;
  reg valid;

  wire map_state;

  assign x_out = x;
  assign y_out = y;
  assign valid_coord = valid;

  map_lut map(.q(map_state), .x(rand_x), .y(rand_y));

  always @(posedge clock) begin
    if(!reset_n) begin
      x <= 8'b11111111;// some dummy value for now
      y <= 7'b1111111;
      valid <= 0'b0;
    end
    if(new_coord) begin
      x <= rand_x;
      y <= rand_y;
      valid <= map_state;
    end
  end

endmodule
