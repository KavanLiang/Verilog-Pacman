module score_alu(score, alu_select, clk, reset_n, enable);
	
	input clk,reset_n,enable;
	input [1:0] alu_select;
	
	reg [23:0] score_reg;
	
	output [23:0] score;
	
	initial score_reg = 24'd0;
	
	assign score = score_reg;
	
	always @(posedge clk) begin
		if(!reset_n) score_reg <= 24'd0;
		else begin
		   score_reg <= score_reg + 24'd0;
		   if(enable) begin
				if(alu_select == 2'b00) score_reg <= score_reg + 24'd10;
				else if(alu_select == 2'b01) score_reg <= score_reg + 24'd20;
				else if(alu_select == 2'b10) score_reg <= score_reg + 24'd50;
				else if(alu_select == 2'b11) score_reg <= score_reg <<< 24'd1;
			end
		end
	end
	
endmodule


