`timescale 1ns/1ps

module can_tx (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [159:0] frame_bits,
    input  wire [7:0]  frame_length,
    output reg         tx_bit,
    output reg         busy,
    output reg         done,
    output reg  [7:0]  bit_index
);
    reg [159:0] frame_reg;
    reg [7:0] length_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            frame_reg <= 160'b0;
            length_reg <= 8'b0;
            bit_index <= 8'b0;
            tx_bit <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                frame_reg <= frame_bits;
                length_reg <= frame_length;
                bit_index <= 8'd0;
                tx_bit <= frame_bits[159];
                busy <= 1'b1;
            end else if (busy) begin
                if (bit_index + 1 >= length_reg) begin
                    busy <= 1'b0;
                    tx_bit <= 1'b1;
                    done <= 1'b1;
                end else begin
                    bit_index <= bit_index + 1'b1;
                    tx_bit <= frame_reg[159-(bit_index+1)];
                end
            end
        end
    end
endmodule
