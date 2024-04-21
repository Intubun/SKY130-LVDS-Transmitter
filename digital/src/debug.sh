#!/bin/sh

echo "[Step 0] Creating analysis folder"

mkdir -p analysis

echo "[Step 1] Compiling Verilog"

iverilog -o ./analysis/dsn tb_wb_drv_config.v wb_drv_config.v

echo "[Step 2] Write VCD File"

vvp ./analysis/dsn

echo "--- Finished ---"