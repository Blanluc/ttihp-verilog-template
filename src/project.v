/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

/*
module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
*/
module tt_um_sat_add_blanluc (
    input  wire [7:0] ui_in,    // Operand A
    output wire [7:0] uo_out,   // Result
    input  wire [7:0] uio_in,   // Operand B
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe, 
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);


  //wire _unused = &{ena, clk, rst_n, uio_out, uio_oe, 1'b0};

  
  wire [7:0] a = ui_in;
  wire [7:0] b = {2'b00, uio_in[5:0]}; 
  wire [1:0] sel = uio_in[7:6]; // Use 2 bits for sel

  assign uio_oe  = 8'b00000000;
  assign uio_out = 8'b00000000;

  logic [8:0] sum_unsigned;
  logic [7:0] res;

  assign sum_unsigned = a + b;
  assign uo_out = res;

  always_comb begin
    case(sel)
      2'b10: begin // SAT_ADD_U
        res = (sum_unsigned[8]) ? 8'hFF : sum_unsigned[7:0];
      end
      2'b11: begin // SAT_SUB_U
        res = (a < b) ? 8'h00 : (a - b);
      end
      2'b00: begin // SAT_ADD
        res = a + b;
        // Overflow: pos + pos = neg OR neg + neg = pos
        if (a[7] == b[7] && res[7] != a[7]) begin
            res = a[7] ? 8'b1000_0000 : 8'b0111_1111;
        end
      end
      2'b01: begin // SAT_SUB
        res = a - b;
        // Overflow: pos - neg = neg OR neg - pos = pos
        if (a[7] != b[7] && res[7] != a[7]) begin
            res = a[7] ? 8'b1000_0000 : 8'b0111_1111;
        end
      end
      default: res = 8'h00;
    endcase
  end

  wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule