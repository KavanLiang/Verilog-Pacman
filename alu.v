module score_alu(score, alu_select, clk, reset_n, enable);
	
	input clk,reset_n,enable;
	input [1:0] alu_select;
	reg score;
	output reg [23:0] score;
	
	always @(posedge clk) begin
		if(reset_n) score <= 0;
		else if(enable) begin
			else if(alu_select == 2'b00) score <= score + 24'd1;
			else if(alu_select == 2'b01) score <= score + 24'd5;
			else if(alu_select == 2'b10) score <= score + 24'd10;
			else if(alu_select == 2'b11) score <= score <<< 24'd1;
		end
	end
	
endmodule


