module pacShifter(clock, enable, resetn, rotation, erase, out);
  input clock,enable,resetn,erase;
  input [1:0] rotation;

  reg [24:0] setA;
  reg [24:0] setB;

  output reg [24:0] out;

  localparam rightA = 25'b0111011111110001111101110,
             rightB = 25'b0111011100110001110001110,
			 upA = 25'b0101011011110111111101110,
			 upB = 25'b0000010001110111111101110,
			 leftA = 25'b0111011111000111111101110,
			 leftB = 25'b0111000111000110011101110,
			 downA = 25'b0111011111110111101101010,
			 downB = 25'b0111011111110111000100000,
             erase = 25'b0000000000000000000000000;

  always @(rotation) begin
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

  always @(posedge clock) begin
    if(!resetn) begin
      out[24:0] <= setA[24:0];
    end
    else if(erase) begin
      out[24:0] <= erase;
    end
    else if(enable) begin
      out[24:0] <= out[24:0] == setA[24:0] ? setB[24:0] : setA[24:0];
    end
  end
endmodule
