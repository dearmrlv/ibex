# BSD-Cov instruction generator

This directory contains the iterative JasperGold/Xcelium instruction generation
flow for the Ibex BSD-Cov experiment.  It treats the existing `common_init`,
`eval`, and `bsdcov_run` trees as read-only inputs; all generated state is kept
under `runs/<tag>`.

Typical invocation:

```bash
./scripts/gen_instr.sh \
  --init-bin ../common_init/build/common_init.bin \
  --target-sample-num -1 \
  --max-epochs 100 \
  --retry-limit 5 \
  --seed 1
```

Use `--dry-run` to validate inputs and materialize the run configuration without
starting licensed tools.  A stopped run can be continued without repeating its
other arguments:

```bash
./scripts/gen_instr.sh --resume --run-tag <tag>
```
