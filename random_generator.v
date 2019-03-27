module random_generator(clk, enable, reset_n, q);
  input clk, enable;
  output q;
  input reset_n;

  reg [4:0] counter;
  reg [4:0] seed;
  reg [4:0] outNext;
  reg [4:0] out;

  assign q = out;


  always @(posedge clk) begin
    if(!reset_n) begin
      seed <= 5'b10101;
      counter <= 0;
    end
    else if(enable) begin
      seed <= counter;
    end
    else begin
      counter <= counter == 5'b11111 ? 5'b0 : counter + 1'b1;
    end
  end

  always @(*) begin
    if(!reset_n) begin
      outNext <= seed;
    end
    else begin
      outNext[4] <= out[4] ^ out[1];
      outNext[3] <= out[3] ^ out[0];
      outNext[2] <= out[2] ^ outNext[4];
      outNext[1] <= out[1] ^ outNext[3];
      outNext[0] <= out[0] ^ outNext[2];
    end
  end

  always @(posedge clk) begin
    if(!reset_n) begin
        out <=  5'b10101;
    end
    else begin
        out <= outNext;
    end
  end
endmodule
