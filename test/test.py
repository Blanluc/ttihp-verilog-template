# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_sat_add_logic(dut):
    dut._log.info("Starting Saturation Logic Tests")
    
    # Tiny Tapeout usually runs at 10MHz or 50MHz. 10us = 100kHz, 
    # but for comb logic, the exact speed doesn't matter much.
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Initialize / Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Helper function to drive the packed uio_in bus
    # sel is 2 bits, b is 6 bits (as per your hardware truncation)
    def drive_inputs(sel, a, b):
        dut.ui_in.value = a
        # Pack uio_in: [sel_bit1, sel_bit0, b5, b4, b3, b2, b1, b0]
        packed_uio = (sel << 6) | (b & 0x3F)
        dut.uio_in.value = packed_uio

    # --- TEST 1: Signed Saturation ADD (sel = 0) ---
    dut._log.info("Test 1: Signed Add Saturation")
    drive_inputs(sel=0, a=127, b=1) # 127 + 1 = 128 (overflow) -> 127
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 127, f"Signed Add Sat Failed: expected 127, got {int(dut.uo_out.value)}"

    # --- TEST 2: Signed Saturation SUB (sel = 1) ---
    dut._log.info("Test 2: Signed Sub Saturation")
    drive_inputs(sel=1, a=0x80, b=1) # -128 - 1 = -129 (underflow) -> -128
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0x80, f"Signed Sub Sat Failed: expected 128, got {int(dut.uo_out.value)}"

    # --- TEST 3: Unsigned Saturation ADD (sel = 2) ---
    dut._log.info("Test 3: Unsigned Add Saturation")
    # Using b=10 because your hardware truncates B to 6 bits (max 63)
    drive_inputs(sel=2, a=250, b=10) # 250 + 10 = 260 -> 255
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 255, f"Unsigned Add Failed: expected 255, got {int(dut.uo_out.value)}"

    # --- TEST 4: Unsigned Saturation SUB (sel = 3) ---
    dut._log.info("Test 4: Unsigned Sub Saturation")
    drive_inputs(sel=3, a=5, b=10) # 5 - 10 = -5 -> 0
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0, f"Unsigned Sub Failed: expected 0, got {int(dut.uo_out.value)}"

    # --- TEST 5: Normal Math (No Saturation) ---
    dut._log.info("Test 5: Normal Addition")
    drive_inputs(sel=0, a=10, b=5)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 15, f"Normal Add Failed: expected 15, got {int(dut.uo_out.value)}"

    dut._log.info("All tests passed!")