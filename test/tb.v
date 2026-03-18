`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/


module tb ();

  // Dump the signals to a FST file for GTKWave
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Signals to drive the TT interface
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;    // Operand A
  reg [7:0] uio_in;   // bits [7:6] = sel, bits [5:0] = Operand B
  wire [7:0] uo_out;  // Result
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Instantiate the project with the standardized TT ports
  tt_um_sat_add_blanluc user_project(
      .ui_in  (ui_in),   
      .uo_out (uo_out),  
      .uio_in (uio_in),  
      .uio_out(uio_out), 
      .uio_oe (uio_oe),  
      .ena    (ena),     
      .clk    (clk),     
      .rst_n  (rst_n)    
  );

  // --- TEMPORARY VERILOG DEBUG TEST ---
initial begin
    $display("--- VERILOG TEST ---");
    #100; // Wait for initial Cocotb reset if running together
    
    // Test 1: Signed Add Saturation (127 + 1)
    ui_in = 8'd127; 
    uio_in = 8'b00_000001; // sel=00 b=1
    #10;
    $display("Signed Add: 127 + 1 = %d (127)", $signed(uo_out));

    // Test 2: Signed Sub Saturation (-128 - 1)
    ui_in = 8'h80; 
    uio_in = 8'b01_000001; // sel=01 b=1
    #10;
    $display("Signed Sub: -128 - 1 = %d (-128)", $signed(uo_out));

    // Test 3: Unsigned Add Saturation (250 + 10)
    ui_in = 8'd250; 
    uio_in = 8'b10_001010; // sel=10 b=10
    #10;
    $display("Unsigned Add: 250 + 10 = %d (255)", uo_out);

    // Test 4: Unsigned Sub Saturation (5 - 10)
    ui_in = 8'd5; 
    uio_in = 8'b11_001010; // sel=11 b=10
    #10;
    $display("Unsigned Sub: 5 - 10 = %d (0)", uo_out);

    $display("--- VERILOG TEST END ---");
end

/*
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


*/
endmodule
