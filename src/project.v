/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tobisma_random_snake (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  // -----------------------------
  // Pseudo-randomized value
  // -----------------------------
  wire [7:0] shifted;
  wire [7:0] randomized;

  assign shifted    = (ui_in << 1) + 8'd1;
  assign randomized = shifted ^ 8'b01010110;

  // -----------------------------
  // Clock divider: 0.05s tick
  // -----------------------------
  reg [21:0] counter;
  reg        tick;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 22'd0;
      tick    <= 1'b0;
    end else begin
      if (counter == 22'd2_499_999) begin
        counter <= 22'd0;
        tick    <= 1'b1;  // pulse every 0.05s
      end else begin
        counter <= counter + 1;
        tick    <= 1'b0;
      end
    end
  end

  // -----------------------------
  // Walking 7-segment segment (current + previous)
  // -----------------------------
  reg [6:0] current_seg;  // current active segment
  reg [6:0] prev_seg;     // previous segment

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_seg <= 7'b0000001;  // start at segment a
      prev_seg    <= 7'b0000000;
    end else if (tick) begin
      // save current as previous
      prev_seg <= current_seg;

      // move current to next neighbor
      case (current_seg)
        7'b0000001: current_seg <= (randomized[0]) ? 7'b0000010 : 7'b0100000; // a -> b or f
        7'b0000010: current_seg <= (randomized[0]) ? 7'b0000100 : 7'b0000001; // b -> c or a
        7'b0000100: current_seg <= (randomized[0]) ? 7'b0001000 : 7'b0000010; // c -> d or b
        7'b0001000: current_seg <= (randomized[0]) ? 7'b0010000 : 7'b0000100; // d -> e or c
        7'b0010000: current_seg <= (randomized[0]) ? 7'b0100000 : 7'b0001000; // e -> f or d
        7'b0100000: current_seg <= (randomized[0]) ? 7'b0000001 : 7'b0010000; // f -> a or e
        default:    current_seg <= 7'b0000001;
      endcase
    end
  end

  // -----------------------------
  // Outputs: show current + previous
  // -----------------------------
  assign uo_out[6:0] = current_seg | prev_seg;  // OR to show both
  assign uo_out[7]   = 1'b0;

  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  // prevent warnings
  wire _unused = &{ena, rst_n, clk, uio_in};

endmodule
