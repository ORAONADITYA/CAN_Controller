`timescale 1ns/1ps

module can_arbitration (
    input  wire [10:0] id_a,
    input  wire [10:0] id_b,
    output reg         winner_valid,
    output reg         winner,       // 0 = A wins, 1 = B wins
    output reg         tie
);
    always @* begin
        winner_valid = 1'b1;
        tie = 1'b0;

        if (id_a < id_b)
            winner = 1'b0;
        else if (id_b < id_a)
            winner = 1'b1;
        else begin
            winner = 1'b0;
            tie = 1'b1;
        end
    end
endmodule
