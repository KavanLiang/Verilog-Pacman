module pacShifter(clock, enable, resetn, rotation, out);
  input clock;
  input enable;
  input [1:0] rotation;

  wire [24:0] setA;
  wire [24:0] setB;

  output reg [24:0] out;

  localparam [24:0] rightA = 25'b0111011111110001111101110;
  localparam [24:0] rightB = 25'b0111011100110001110001110;
  localparam [24:0] upA = 25'b0101011011110111111101110;
  localparam [24:0] upB = 25'b0000010001110111111101110;
  localparam [24:0] leftA = 25'b0111011111000111111101110;
  localparam [24:0] leftB = 25'b0111000111000110011101110;
  localparam [24:0] downA = 25'b0111011111110111101101010;
  localparam [24:0] downB = 25'b0111011111110111000100000;

  always @(*) begin
    case(rotation)
      2'd0 :  begin
                setA[24:0] = rightA;
                setB[24:0] = rightB;
              end
      2'd1 :  begin
                setA[24:0] = upA;
                setB[24:0] = upB;
              end
      2'd2 :  begin
                setA[24:0] = leftA;
                setB[24:0] = leftB;
              end
      2'd3 :  begin
                setA[24:0] = downA;
                setB[24:0] = downB;
              end
      default:
    endcase
  end

  always @(posedge clock) begin
    if(!resetn) begin
      out[24:0] <= A[24:0];
    end
    else if(enable) begin
      out[24:0] <= out[24:0] == setA[24:0] ? setB[24:0] : setA[24:0];
    end
  end
endmodule
