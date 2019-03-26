module random_generator(clk, enable, reset_n, out);
  input clk, enable;
  output reg [4:0] out;

  reg [4:0] counter;
  reg [4:0] seed;
  reg [4:0] nextOut;

  always @(posedge clk) begin
    if(!reset_n) begin
      seed <= 5'b10101;
      counter <= 0;
    end
    else if(enable) begin
      seed <= counter;
    end
    else
      counter <= counter + 1'b1;
    end
  end

  always @(*) begin
    if(!reset_n) begin
      outNext <= seed;
    end
    else begin
      outNext[4] <= outNext[4] ^ out[1];
      outNext[3] <= outNext[3] ^ out[0];
      outNext[2] <= outNext[2] ^ outNext[4];
      outNext[1] <= outNext[1] ^ outNext[3];
      outNext[0] <= outNext[0] ^ outNext[2];
      out <= outNext;
  end
endmodule
