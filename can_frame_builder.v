`timescale 1ns/1ps

module can_frame_builder (
    input  wire [10:0] identifier,
    input  wire [3:0]  dlc,
    input  wire [63:0] data,
    output reg  [159:0] frame_bits,
    output reg  [7:0]   frame_length
);
    reg [127:0] raw_bits;
    reg [159:0] temp_bits;
    reg [14:0] crc_value;
    reg feedback;
    reg current_bit;
    reg previous_bit;
    integer raw_length;
    integer total_source_bits;
    integer out_length;
    integer run_length;
    integer i;
    integer j;
    integer k;
    integer byte_count;

    always @* begin
        raw_bits = 128'b0;
        temp_bits = 160'b0;
        frame_bits = 160'b0;
        crc_value = 15'h0000;
        feedback = 1'b0;
        current_bit = 1'b0;
        previous_bit = 1'b0;
        raw_length = 0;
        total_source_bits = 0;
        out_length = 0;
        run_length = 0;
        frame_length = 0;
        byte_count = (dlc > 8) ? 8 : dlc;

        // SOF: dominant bit.
        raw_bits[127-raw_length] = 1'b0;
        raw_length = raw_length + 1;

        // 11-bit standard identifier, most-significant bit first.
        for (i = 10; i >= 0; i = i - 1) begin
            raw_bits[127-raw_length] = identifier[i];
            raw_length = raw_length + 1;
        end

        // RTR=0 (data frame), IDE=0 (standard frame), r0=0.
        raw_bits[127-raw_length] = 1'b0; raw_length = raw_length + 1;
        raw_bits[127-raw_length] = 1'b0; raw_length = raw_length + 1;
        raw_bits[127-raw_length] = 1'b0; raw_length = raw_length + 1;

        // DLC.
        for (i = 3; i >= 0; i = i - 1) begin
            raw_bits[127-raw_length] = byte_count[i];
            raw_length = raw_length + 1;
        end

        // Data field, byte and bit order are most-significant first.
        for (j = 0; j < byte_count; j = j + 1) begin
            for (k = 7; k >= 0; k = k - 1) begin
                raw_bits[127-raw_length] = data[63-(j*8+(7-k))];
                raw_length = raw_length + 1;
            end
        end

        // CRC-15 over SOF through the final data bit.
        crc_value = 15'h0000;
        for (i = 0; i < raw_length; i = i + 1) begin
            feedback = crc_value[14] ^ raw_bits[127-i];
            crc_value = {crc_value[13:0], 1'b0};
            if (feedback)
                crc_value = crc_value ^ 15'h4599;
        end

        // Append CRC sequence to the stuffable portion.
        total_source_bits = raw_length + 15;
        for (i = 0; i < 15; i = i + 1) begin
            raw_bits[127-raw_length] = crc_value[14-i];
            raw_length = raw_length + 1;
        end

        // Bit stuffing from SOF through the CRC sequence.
        previous_bit = 1'b0;
        run_length = 0;
        out_length = 0;

        for (i = 0; i < total_source_bits; i = i + 1) begin
            current_bit = raw_bits[127-i];
            temp_bits[159-out_length] = current_bit;
            out_length = out_length + 1;

            if ((run_length == 0) || (current_bit != previous_bit)) begin
                previous_bit = current_bit;
                run_length = 1;
            end else begin
                run_length = run_length + 1;
            end

            if (run_length == 5) begin
                temp_bits[159-out_length] = ~current_bit;
                out_length = out_length + 1;
                previous_bit = ~current_bit;
                run_length = 1;
            end
        end

        // Fixed, non-stuffed trailer: CRC delimiter, ACK slot,
        // ACK delimiter, and seven EOF bits.
        temp_bits[159-out_length] = 1'b1; out_length = out_length + 1;
        temp_bits[159-out_length] = 1'b1; out_length = out_length + 1;
        temp_bits[159-out_length] = 1'b1; out_length = out_length + 1;
        for (i = 0; i < 7; i = i + 1) begin
            temp_bits[159-out_length] = 1'b1;
            out_length = out_length + 1;
        end

        frame_bits = temp_bits;
        frame_length = out_length;
    end
endmodule
