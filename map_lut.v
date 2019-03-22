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
			8'd0,8'd26: col = col0;
			8'd1,8'd25: col = col1;
			8'd2,8'd24: col = col2;
			8'd3,8'd23: col = col3;
			8'd4,8'd22: col = col4;
			8'd5,8'd21: col = col5;
			8'd6,8'd20: col = col6;
			8'd7,8'd19: col = col7;
			8'd8,8'd18: col = col8;
			8'd9,8'd17: col = col9;
			8'd10,8'd16: col = col10;
			8'd11,8'd15: col = col11;
			8'd12,8'd14: col = col12;
			8'd13: col = col13;
			default: col = 24'b000000000000000000000000;
		endcase
	end
	
	assign q = col[y];
	
endmodule