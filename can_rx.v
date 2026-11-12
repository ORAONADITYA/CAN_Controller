`timescale 1ns/1ps

module can_rx (
    input  wire         clk,
    input  wire         reset,
    input  wire         start_capture,
    input  wire         rx_bit,
    input  wire [7:0]   expected_length,
    output reg          active,
    output reg          done,
    output reg  [159:0] captured_bits,
    output reg  [7:0]   captured_length
);
    reg [7:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            active <= 1'b0;
            done <= 1'b0;
            captured_bits <= 160'b0;
            captured_length <= 8'b0;
            count <= 8'b0;
        end else begin
            done <= 1'b0;

            // Capture the first serial bit on the start edge itself.
            if (start_capture && !active) begin
                captured_bits <= 160'b0;
                captured_bits[159] <= rx_bit;
                count <= 8'd1;

                if (expected_length <= 1) begin
                    active <= 1'b0;
                    done <= 1'b1;
                    captured_length <= 8'd1;
                end else begin
                    active <= 1'b1;
                    captured_length <= 8'b0;
                end
            end else if (active) begin
                captured_bits[159-count] <= rx_bit;
                count <= count + 1'b1;

                if (count + 1'b1 >= expected_length) begin
                    active <= 1'b0;
                    done <= 1'b1;
                    captured_length <= count + 1'b1;
                end
            end
        end
    end
endmodule
