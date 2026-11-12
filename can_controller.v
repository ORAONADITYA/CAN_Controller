`timescale 1ns/1ps

module can_controller (
    input  wire         clk,
    input  wire         reset,
    input  wire         tx_start,
    input  wire [10:0]  identifier,
    input  wire [3:0]   dlc,
    input  wire [63:0]  data,
    output wire         tx_bit,
    output wire         tx_busy,
    output wire         tx_done,
    output wire         rx_done,
    output wire [159:0] rx_frame,
    output wire [7:0]   rx_length,
    output wire [7:0]   frame_length,
    output wire         rx_active
);
    wire [159:0] generated_frame;

    can_frame_builder builder (
        .identifier(identifier),
        .dlc(dlc),
        .data(data),
        .frame_bits(generated_frame),
        .frame_length(frame_length)
    );

    can_tx transmitter (
        .clk(clk),
        .reset(reset),
        .start(tx_start),
        .frame_bits(generated_frame),
        .frame_length(frame_length),
        .tx_bit(tx_bit),
        .busy(tx_busy),
        .done(tx_done),
        .bit_index()
    );

    can_rx receiver (
        .clk(clk),
        .reset(reset),
        .start_capture(tx_busy && !rx_active),
        .rx_bit(tx_bit),
        .expected_length(frame_length),
        .active(rx_active),
        .done(rx_done),
        .captured_bits(rx_frame),
        .captured_length(rx_length)
    );
endmodule
