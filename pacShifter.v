module pacShifter(clock, enable, resetn, rotation, erase, out);
  input clock,enable,resetn,erase;
  input [1:0] rotation;

  reg [24:0] setA;
  reg [24:0] setB;
  
  reg [24:0] curr_ani;

  output reg [24:0] out;

  localparam rightA = 25'b0111011111110001111101110,
             rightB = 25'b0111011100110001110001110,
				 upA = 25'b0101011011110111111101110,
				 upB = 25'b0000010001110111111101110,
				 leftA = 25'b0111011111000111111101110,
				 leftB = 25'b0111000111000110011101110,
				 downA = 25'b0111011111110111101101010,
				 downB = 25'b0111011111110111000100000,
             ERASE = 25'b0000000000000000000000000;
				 
	

  always @(*) begin
    case(rotation)
      2'd0 :  begin
                setA = rightA;
                setB = rightB;
              end
      2'd1 :  begin
                setA = upA;
                setB = upB;
              end
      2'd2 :  begin
                setA = leftA;
                setB = leftB;
              end
      2'd3 :  begin
                setA = downA;
                setB = downB;
              end
    endcase
  end
  
	always @(*) begin
		case(erase)
			1'b0: out = curr_ani; 
			1'b1: out = ERASE;
		endcase
	end

  always @(posedge clock) begin
    if(!resetn) begin
      curr_ani <= setA[24:0];
    end
    else if(erase) begin
      curr_ani <= ERASE;
    end
    else if(enable) begin
      curr_ani <= curr_ani == setA[24:0] ? setB[24:0] : setA[24:0];
    end
  end
  
endmodule

