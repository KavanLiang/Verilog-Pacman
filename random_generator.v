module random_generator(clk, enable, reset_n, q);
  input clk, enable;
  output [7:0] q;
  input reset_n;

  reg [7:0] counter;
  reg [7:0] seed;
  reg [7:0] outNext;
  reg [7:0] out;

  assign q = out;


  always @(posedge clk) begin
    if(!reset_n) begin
      seed <= 8'b10101010;
      counter <= 0;
    end
    else if(enable) begin
      seed <= counter;
    end
    else begin
      counter <= counter == 8'b11111111 ? 8'b0 : counter + 1'b1;
    end
  end

  always @(*) begin
    if(!reset_n) begin
      outNext <= seed;
    end
    else begin
      outNext[7] <= out[7] ^ out[1];
      outNext[6] <= out[6] ^ out[0];
      outNext[5] <= out[5] ^ outNext[7];
      outNext[4] <= out[4] ^ outNext[6];
      outNext[3] <= out[3] ^ outNext[5];
      outNext[2] <= out[2] ^ outNext[4];
      outNext[1] <= out[1] ^ outNext[3];
    end
  end

  always @(posedge clk) begin
    if(!reset_n) begin
        out <=  8'b10101010;
    end
    else begin
        out <= outNext;
    end
  end
endmodule
