module pellet_shaper(clock, reset_n, shape);
    input clk, reset_n;
    output [24:0] shape;

    reg [24:0] next_ani;

    localparam  ANI_0 = 25'b0000000110011100110000000;
                ANI_1 = 25'b0000001100011100011000000;

    assign shape = next_ani;

    always @(posedge clk) begin
        if(!reset_n) begin
            next_ani <= ANI_0;
        end
        else begin
            next_ani <= next_ani == ANI_0 ? ANI_1 : ANI_0;
        end
    end
endmodule
