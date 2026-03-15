`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] a_ui_in;  // Dedicated inputs
  reg [7:0] b_ui_in;
  reg [1:0] sel;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Replace tt_um_example with your module name:
  tt_um_sat_add user_project(
      .a_ui_in  (a_ui_in),    // Dedicated inputs
      .b_ui_in  (b_ui_in),
      .sel  (sel),
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  initial begin

    rst_n = 0;
    sel = 2'b00;
    a_ui_in = 8'b0111_1111;
    b_ui_in = 8'b0000_0001;

    $display("TEST 1.1: SAT ADD (SAT CASE)");

    #1; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b0111_1111) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #10;
    $display("TEST 1.2: SAT ADD (NO SAT CASE)");
    
    rst_n = 0;
    sel = 2'b00;
    a_ui_in = 8'b0000_0000;
    b_ui_in = 8'b0000_0001;

    #11; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b0000_0001) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #20;
    $display("TEST 2.1: SAT SUB (SAT CASE)");

    rst_n = 0;
    sel = 2'b01;
    a_ui_in = 8'b1000_0000;
    b_ui_in = 8'b0000_0001;

    #21; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b1000_0000) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #30;
    $display("TEST 2.2: SAT SUB (NOT SAT CASE)");

    rst_n = 0;
    sel = 2'b01;
    a_ui_in = 8'b0000_0011;
    b_ui_in = 8'b0000_0001;

    #31; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b0000_0010) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #40;
    $display("TEST 3.1: SAT ADD U (SAT CASE)");

    rst_n = 0;
    sel = 2'b10;
    a_ui_in = 8'b1111_1111;
    b_ui_in = 8'b0000_0001;

    #41; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b1111_1111) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #50;
    $display("TEST 3.2: SAT ADD U (NO SAT CASE)");
    
    rst_n = 0;
    sel = 2'b10;
    a_ui_in = 8'b0000_0000;
    b_ui_in = 8'b0000_0001;

    #51; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b0000_0001) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #60;
    $display("TEST 4.1: SAT SUB U (SAT CASE)");

    rst_n = 0;
    sel = 2'b11;
    a_ui_in = 8'b0000_0000;
    b_ui_in = 8'b0000_0001;

    #61; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b0000_0000) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #70;
    $display("TEST 4.2: SAT SUB U (NOT SAT CASE)");

    rst_n = 0;
    sel = 2'b11;
    a_ui_in = 8'b0000_0011;
    b_ui_in = 8'b0000_0001;

    #71; 

    $display("At time %t, Output is: %b (hex: %h)", $time, uo_out, uo_out);

    if (uo_out == 8'b0000_0010) begin
      $display("Result: GOOD RESULT !");
    end else begin
      $display("Result: BAD RESULT !");
    end
    
    #80;
    $finish;
  end



endmodule
