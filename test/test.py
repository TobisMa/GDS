# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_first_segment(dut):
    dut._log.info("Start test for first segment")

    # Start clock: 10 us period = 100 KHz (for simulation)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # -----------------------------
    # Reset the DUT
    # -----------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)  # wait one more cycle

    # -----------------------------
    # Check the first segment
    # -----------------------------
    expected = 0b0000001  # first segment 'a' should be lit
    observed = int(dut.uo_out.value) & 0x7F  # mask lower 7 bits

    dut._log.info(f"Observed=0b{observed:07b}, Expected=0b{expected:07b}")
    assert observed == expected, f"First segment test failed: got 0b{observed:07b}, expected 0b{expected:07b}"

    dut._log.info("First segment test passed")
