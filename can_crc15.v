`timescale 1ns/1ps

module can_crc15 (
    input  wire [127:0] data_bits,
    input  wire [7:0]   bit_count,
    output reg  [14:0]  crc
);
    integer i;
    reg feedback;

    always @* begin
        crc = 15'h0000;
        feedback = 1'b0;

        for (i = 0; i < 128; i = i + 1) begin
            if (i < bit_count) begin
                feedback = crc[14] ^ data_bits[127-i];
                crc = {crc[13:0], 1'b0};
                if (feedback)
                    crc = crc ^ 15'h4599;
            end
        end
    end
endmodule
