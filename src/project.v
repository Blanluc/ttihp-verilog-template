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

module tt_um_sat_add (
    input  wire [7:0] a_ui_in,    // Dedicated inputs
    input  wire [7:0] b_ui_in,
    input wire [1:0] sel,
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = a_ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  logic [8:0]raw_sum;
  logic [8:0]raw_sub;
  logic [7:0]result;



  assign uo_out=result;
  

  always_comb begin
    result = 8'h00;
    // Function code goes here
    raw_sum=unsigned'({1'b0,a_ui_in}) + unsigned'({1'b0,b_ui_in});
    raw_sub=unsigned'({1'b0,a_ui_in}) + unsigned'({1'b1,~b_ui_in} + 1'b1);
    case(sel)
      2'b00: begin//SAT_ADD
        result = raw_sum[7:0];
        case(raw_sum[7])
          1'b1: begin
            if (a_ui_in[7]==0 & b_ui_in[7]==0) //sum of two pos becomes neg
              result=8'b0111_1111;
          end
          1'b0: begin
            if (a_ui_in[7]==1 & b_ui_in[7]==1) //sum of two pos becomes neg
              result=8'b1000_0000;
          end
          default : result=raw_sum[7:0];
        endcase
      end
      2'b01: begin//SAT_SUB
        result = raw_sub[7:0];
        case(raw_sub[7])
            1'b0: begin
              if (a_ui_in[7]==1 & b_ui_in[7]==0) //sub of neg and pos becomes pos
                result=8'b1000_0000;
            end
            1'b1: begin
              if (a_ui_in[7]==0 & b_ui_in[7]==1) //sub of pos and neg becomes neg
                result=8'b0111_1111;
            end
            default : result=raw_sub[7:0];
          endcase
      end
      2'b10: begin//SAT_ADD_U
      result = raw_sum[7:0];
        case(raw_sum[8])
            1'b1: begin //overflow
                result[7:0]='1;
            end
            default : result=raw_sum[7:0];
          endcase
      end
      2'b11: begin//SAT_SUB_U
      result = raw_sub[7:0];
      case(raw_sub[8])
            1'b1: begin //overflow
                result[7:0]='0;
            end
            default : result=raw_sub[7:0];
          endcase
        end
        default: result = 8'h00;
    endcase
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule