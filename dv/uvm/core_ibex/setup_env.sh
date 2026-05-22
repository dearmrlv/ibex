#!/usr/bin/env bash

# ============================================================
# Ibex repo
# ============================================================
export IBEX_ROOT="$(realpath ../../../../ibex)"
export IBEX_TOOLS="$(realpath ../../../../../thirdparty/tools/lowrisc)"
export IBEX_PYTHON_VENV="$IBEX_ROOT/.venv"

# ============================================================
# RISC-V GNU toolchain
# ============================================================
export RISCV_TOOLCHAIN="$(realpath "$IBEX_TOOLS/lowrisc-toolchain-gcc-rv32imcb-20220210-1")"
export RISCV="$RISCV_TOOLCHAIN"

export RISCV_GCC="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-gcc"
export RISCV_OBJCOPY="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-objcopy"
export RISCV_OBJDUMP="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-objdump"
export RISCV_READELF="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-readelf"

# ============================================================
# Spike / riscv-isa-sim
# ============================================================
export RISCV_ISA_SIM="$(realpath "$IBEX_TOOLS/riscv-isa-sim")"
export SPIKE_PATH="$RISCV_ISA_SIM/bin"

export PKG_CONFIG_PATH="$RISCV_ISA_SIM/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="$RISCV_ISA_SIM/lib:$RISCV_TOOLCHAIN/lib:$RISCV_TOOLCHAIN/lib64:${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="$RISCV_ISA_SIM/lib:${LIBRARY_PATH:-}"

# ============================================================
# Xcelium / xrun / imc
# ============================================================
# export CDS_LIC_FILE="/home/lvzhengyang/workspace/cadence/license/license.2023.dat.xc"
# export CDS_LIC_ONLY=1
# export CDS_AUTO_64BIT="ALL"
# export verdi_pli="/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06/share/PLI/IUS/linux64/boot"
# export CADENCE_XRUN="/home/lvzhengyang/workspace/cadence/XCELIUM2509/tools.lnx86/bin/xrun"

export CADENCE_XRUN="/home/lvzhengyang/workspace/cadence/xrun"
export PATH="$(dirname "$CADENCE_XRUN"):$IBEX_TOOLS/bin:$IBEX_PYTHON_VENV/bin:$RISCV_TOOLCHAIN/bin:$SPIKE_PATH:$PATH"

# ============================================================
# Default Ibex regression settings
# ============================================================
export IBEX_SIMULATOR=xlm
export IBEX_ISS=spike
