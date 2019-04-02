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