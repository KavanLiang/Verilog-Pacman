//module movement_handler(clk, dir_in, reset_n, reset_x, reset_y, x_out, y_out);
//
//  input [2:0] dir_in;
//
//  input [7:0] reset_x;
//  input [6:0] reset_y;
//
//  reg [7:0] x, x_next;
//  reg [6:0] y, y_next;
//
//  output [7:0] x_out;
//  output [6:0] y_out;
//
//  wire map_state;
//
//  localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
//
//  always @(*) begin
//    x_next = x;
//    y_next = y;
//    case(dir_in)
//      RIGHT: x_next = x+8'b1;
//      UP: y_next = y-7'b1;
//      LEFT: x_next = x-8'b1;
//      DOWN: y_next = y+7'b1;
//    endcase
//  end
//
//  map_lut map(.q(map_state), .x(x_next), .y(y_next));
//
//  always @(posedge clk) begin
//    if(!reset_n) begin
//      x <= reset_x;
//      y <= reset_y;
//    end
//    else begin
//      x <= map_state ? x : x_next;
//      y <= map_state ? y : y_next;
//      case(dir_in)
//        RIGHT: begin
//                if(x == 8'd26) x <= 8'd0;
//               end
//        UP: begin
//              if(y == 7'd0) y <= 7'd23;
//            end
//        LEFT: begin
//              if(x == 8'd0) x <= 8'd26;
//              end
//        DOWN: begin
//              if(y == 7'd23) y <= 7'd0;
//              end
//        default: begin
//                 end
//      endcase
//    end
//  end
//
//  assign x_out = x;
//  assign y_out = y;
//  
//endmodule

module movement_handler(clk, dir_in, reset_n, reset_x, reset_y, x_out, y_out);

   input clk,reset_n;
	input [2:0] dir_in;
	input [7:0] reset_x;
   input [6:0] reset_y;
   	
	output [7:0] x_out;
	output [6:0] y_out;

	reg [7:0] x, x_next;
	reg [6:0] y, y_next;

	wire map_state;

	localparam WAIT = 3'b100, RIGHT = 3'b000, UP = 3'b001, LEFT = 3'b010, DOWN = 3'b011;
	
	initial begin
		x <= reset_x;
		y <= reset_y;
	end

	 always @(*) begin
		x_next = x;
		y_next = y;
		case(dir_in)
			RIGHT: x_next = x+8'b1;
			UP: y_next = y-7'b1;
			LEFT: x_next = x-8'b1;
			DOWN: y_next = y+7'b1;
		endcase
	 end

	 map_lut map(.q(map_state), .x(x_next), .y(y_next));

	 assign x_out = x;
	 assign y_out = y;

	 always @(posedge clk) begin
		//Change reset value to starting point
		if(!reset_n) begin
			x <= reset_x;
			y <= reset_y;
		end
		else begin
			if(dir_in == RIGHT) begin
				if(x == 8'd26) x <= 8'd0;
				else if(map_state == 1'b1) x <= x_next-8'd1;
				else x <= x_next;
			end
			else if(dir_in == UP) begin
				if(y == 7'd0) y <= 7'd23;
				else if(map_state == 1'b1) y <= y_next+8'd1;
				else y <= y_next;
			end
			else if(dir_in == LEFT) begin
				if(x == 8'd0) x <= 8'd26;
				else if(map_state == 1'b1) x <= x_next+8'd1;
				else x <= x_next;
			end
			else if(dir_in == DOWN) begin
				if(y == 7'd23) y <= 7'd0;
				else if(map_state == 1'b1) y <= y_next-8'd1;
				else y <= y_next;
			end
			else if(dir_in == WAIT) begin
				x <= x_next;
				y <= y_next;
			end
		end
	 end
  
endmodule