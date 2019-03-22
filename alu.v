module score_alu(score, alu_select, clk, reset_n, enable);
	
	input clk,reset_n,enable;
	input [1:0] alu_select;
	reg score_reg;
	output [23:0] score;
	
	assign score = score_reg;
	
	always @(posedge clk) begin
		if(reset_n) score <= 0;
		else if(enable) begin
			else if(alu_select == 2'b00) score_reg <= score_reg + 24'd1;
			else if(alu_select == 2'b01) score_reg <= score_reg + 24'd5;
			else if(alu_select == 2'b10) score_reg <= score_reg + 24'd10;
			else if(alu_select == 2'b11) score_reg <= score_reg <<< 24'd1;
		end
	end
	
endmodule

reg [23:0] loc [13:0];

loc[0] = 24'b000000000101000000000000;
loc[1] = 24'b111111110101011111111111;
loc[2] = 24'b100000010101010000000001;
loc[3] = 24'b101101010101010101000101;
loc[4] = 24'b101101010101010101110101;
loc[5] = 24'b101101011101110101110101;
loc[6] = 24'b100000000000000000000101;
loc[7] = 24'b101101111101110101110101;
loc[8] = 24'b101100000000000100000101;
loc[9] = 24'b101101111101110101011101;
loc[10] = 24'b100000010000010001000101;
loc[11] = 24'b101101010111010101010101;
loc[12] = 24'b101101000101010100010001;
loc[13] = 24'b101101110001010111011101;
