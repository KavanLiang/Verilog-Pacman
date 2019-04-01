//module random_generator(clk, enable, reset_n, q);
//
//  input clk, enable, reset_n;
//  output [7:0] q;
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
//      outNext[7] <= out[3] ^ out[2];
//      outNext[6] <= out[2] ^ out[0];
//      outNext[5] <= out[7] ^ out[3];
//      outNext[4] <= out[4] ^ out[5];
//      outNext[3] <= out[3] ^ out[6];
//      outNext[2] <= out[4] ^ out[2];
//      outNext[1] <= out[1] ^ out[7];
//		outNext[0] <= out[5] ^ out[1];
//    end
//  end
//
//  always @(posedge clk) begin
//    if(!reset_n) begin
//        out <=  8'b10101010;
//    end
//    else begin
//		out <= outNext;
//    end
//  end
//endmodule

module random_generator(q, clock, reset_n);
	
	input clock, reset_n;
	
	reg [7:0] curr_rand, counter;
	
	output [7:0] q;
	
	initial begin
		curr_rand <= 8'b10101010;
		counter <= 8'b00000001;
	end
	
	assign q = curr_rand;
	
	always @(posedge clock) begin
	
		if(counter == 8'b11111111) counter <= 8'b00000001;
		else counter <= counter + 8'd1;
		
		if(!reset_n) curr_rand <= counter;
		else begin
			curr_rand[0] <= curr_rand[7];
			curr_rand[1] <= curr_rand[0];
			curr_rand[2] <= curr_rand[7] ^ curr_rand[1];
			curr_rand[3] <= curr_rand[7] ^ curr_rand[2];
			curr_rand[4] <= curr_rand[7] ^ curr_rand[3];
			curr_rand[5] <= curr_rand[4];
			curr_rand[6] <= curr_rand[5];
			curr_rand[7] <= curr_rand[6];
		end
	end
	
endmodule