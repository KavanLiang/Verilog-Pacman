module map_lut(q, x, y);

	input [7:0] x;
	input [6:0] y;
	
	output q;
	
	reg [0:23] col;
	
	localparam col0 = 24'b000000000101000000000000,
	           col1 = 24'b111111110101011111111111,
				  col2 = 24'b100000010101010000000001,
				  col3 = 24'b101101010101010101000101,
				  col4 = 24'b101101010101010101110101,
				  col5 = 24'b101101011101110101110101,
				  col6 = 24'b100000000000000000000101,
				  col7 = 24'b101101111101110101110101,
				  col8 = 24'b101100000000000100000101,
				  col9 = 24'b101101111101110101011101,
				  col10 = 24'b100000010000010001000101,
				  col11 = 24'b101101010111010101010101,
				  col12 = 24'b101101000101010100010001,
				  col13 = 24'b101101110001010111011101;
	
	always @(*) begin
		case(x)
			8'b0,8'b26: col = col0;
			8'b1,8'b25: col = col1;
			8'b2,8'b24: col = col2;
			8'b3,8'b23: col = col3;
			8'b4,8'b22: col = col4;
			8'b5,8'b21: col = col5;
			8'b6,8'b20: col = col6;
			8'b7,8'b19: col = col7;
			8'b8,8'b18: col = col8;
			8'b9,8'b17: col = col9;
			8'b10,8'b16: col = col10;
			8'b11,8'b15: col = col11;
			8'b12,8'b14: col = col12;
			8'b13: col = col13;
		endcase
	end
	
	assign q = col[y];
	
endmodule