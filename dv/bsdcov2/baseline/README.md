# BSD-Cov2 CSR/PMP Baseline

This directory runs a riscv-dv CSR/PMP-biased baseline using the original Ibex
UVM testbench. It does not use the BSD-Cov instruction-generation imem model.

Default comparison target:

```text
../instr_gen3/runs/run.20260612T110926Z.seed1/images/accepted_0033.bin
```

The baseline script derives the target size from that binary's 32-bit word
count, generates a riscv-dv assembly program, runs xrun with coverage enabled,
and writes a summary under `runs/<tag>/`.

It also checks that the generated binary starts with
`../common_init/build/common_init.bin`, which is the public initialization
prefix used by `instr_gen3`. A plain riscv-dv binary normally does not have this
prefix; in that case `summary.json` reports `common_prefix_match: false`, and
the coverage should not be treated as a fair comparison.

Usage:

```bash
./scripts/run_baseline.sh
```

Useful options:

```bash
./scripts/run_baseline.sh --seed 1688 --fsdb --force-compile
./scripts/run_baseline.sh --reference-bin ../instr_gen3/runs/run.20260612T110926Z.seed1/images/accepted_0033.bin
./scripts/run_baseline.sh --target-words 107
./scripts/run_baseline.sh --reuse-tb-dir ../../bsdcov/sim/runs/<run>/ibex_dv_out/build/tb
./scripts/run_baseline.sh --allow-prefix-mismatch --no-bsdcov-io-dump --stop-on-assert
```

For a plain riscv-dv smoke/coverage run that intentionally ignores the
`common_init` prefix mismatch:

```bash
./scripts/run_baseline.sh \
  --run-tag run.riscvdv_baseline.seed1 \
  --reuse-tb-dir ../../bsdcov/sim/runs/<run>/ibex_dv_out/build/tb \
  --allow-prefix-mismatch \
  --no-bsdcov-io-dump \
  --stop-on-assert
```

The default riscv-dv generator simulator is `pyflow`, which is the path used by
the existing BSD-Cov scripts. This generates a CSR-biased baseline. The script
accepts `--generator-simulator xlm` and will pass PMP-specific options there,
but this vendored riscv-dv setup may not produce an assembly file in that mode.

Outputs:

```text
runs/
  latest -> run.<timestamp>.seed<seed>
  run.<timestamp>.seed<seed>/
    config.json
    summary.json
    riscvdv/
    sim/
    reports/
```
