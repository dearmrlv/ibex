# BSD-Cov Ibex DV Notes

This note records the known-good way to launch Ibex RTL simulation from this
directory for BSD-Cov experiments, plus the failure modes already debugged.

## Preferred Entry Point

For normal BSD-Cov experiments, use the repository-level runner instead of
calling Ibex DV scripts by hand:

```bash
python3 main.py run \
  --design ibex \
  --method riscvdv \
  --config <config.yaml> \
  --run-tag <run_tag> \
  --jobs <N> \
  --force-sim
```

The runner generates the testlist, compiles/runs RTL, samples coverage, and
writes:

- `exp/ibex_riscvdv/<run_tag>/sim/runs.csv`
- `exp/ibex_riscvdv/<run_tag>/coverage/samples.csv`
- `exp/ibex_riscvdv/<run_tag>/coverage/coverage_summary.csv`

Use `--force-sim` for formal/generated directed tests so stale binaries,
testlists, or coverage samples are not reused accidentally.

## Direct Ibex DV Commands

If running from this directory manually, source the environment first:

```bash
source setup_env.sh
```

Typical lower-level actions are:

- `make ... GOAL=rtl_tb_compile` for RTL testbench compilation.
- `scripts/run_rtl.py` for a single RTL simulation.
- IMC scripts/wrappers for coverage merge and reporting.

Prefer the top-level BSD-Cov runner unless debugging a specific Ibex DV step.

## Xcelium Wrapper

Use this Xcelium launcher:

```bash
/home/lvzhengyang/workspace/cadence/xrun
```

It is a wrapper that already handles license setup. Do not rely on a plain
`xrun` from `PATH`.

The BSD-Cov runner supports this through:

- `CADENCE_XRUN=/home/lvzhengyang/workspace/cadence/xrun`
- config `make.xrun: /home/lvzhengyang/workspace/cadence/xrun`

`scripts/compile_tb.py` and `scripts/run_rtl.py` replace a command beginning
with `xrun` with `CADENCE_XRUN` when that variable is set.

## Extra Bind/Filelist Injection

Do not edit `dut.f` for BSD-Cov generated bind files. Use a separate filelist
and pass it into the RTL compile:

```bash
export BSD_COV_EXTRA_XRUN_FILELISTS=/abs/path/to/extra_bind.f
```

The compile flow appends each filelist from `BSD_COV_EXTRA_XRUN_FILELISTS` as:

```text
-f <filelist>
```

This is the intended mechanism for BSD-Cov observer/assertion binds.

## Known Xcelium Compile Pitfall

Xcelium 20.09 can fail on generated SystemVerilog/bind code without an explicit
timescale. The compile flow should include:

```text
-timescale 1ns/1ps
```

This fixed the previously observed `CUMSTS`-style fatal during RTL testbench
compile.

## Simulation vs Formal Hierarchy

Do not reuse the same instance path blindly between simulation and formal.

Simulation/testbench hierarchy:

```text
core_ibex_tb_top.dut.u_ibex_top.u_ibex_core...
```

Formal hierarchy:

```text
ibex_top.u_ibex_core...
```

For formal binds, strip the testbench prefix:

```text
core_ibex_tb_top.dut.u_ibex_top -> ibex_top
```

Using simulation hierarchy in formal causes Jasper elaborate errors such as
`target <instance> could not be found; bind is not performed`.

## Coverage Checks

An RTL pass is not enough. Always confirm coverage artifacts:

```bash
cat exp/ibex_riscvdv/<run_tag>/sim/runs.csv
cat exp/ibex_riscvdv/<run_tag>/coverage/samples.csv
cat exp/ibex_riscvdv/<run_tag>/coverage/coverage_summary.csv
```

Expected examples:

- Baseline 10k: samples at `1000, 2000, ..., 10000`.
- Short directed extra: sample may be the actual extracted instruction count,
  such as `bsd_cov_sample_000003`.

Important log locations:

- RTL simulation log:
  `exp/ibex_riscvdv/<run_tag>/raw/<method>/seed_888/out/run/tests/<test>.<seed>/rtl_sim.log`
- RTL compile log:
  `exp/ibex_riscvdv/<run_tag>/raw/<method>/seed_888/out/build/tb/compile_tb.log`

## IMC Warnings

These IMC messages are commonly non-fatal if `cov_report.txt` and
`coverage/samples.csv` are produced:

- `vRefine checksum` warnings
- `NOMATCH`
- `REPDEP`
- some `EREXCE` waiver/exclude messages

Treat missing `samples.csv`, missing `cov_report.txt`, or failed `runs.csv`
status as real failures.

