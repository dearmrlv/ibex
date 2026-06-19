# RTLReach no-merge ablation

This directory contains the no-merge ablation of the iterative
JasperGold/Xcelium instruction generation flow for the Ibex RTLReach
experiment. It is copied from `instr_gen3.2`, but emits one target assertion per
`fire_i` instead of one merged assertion per RTL instance. The existing
`common_init`, `eval`, and `bsdcov_run` trees are treated as read-only inputs;
all generated state is kept under `runs/<tag>`.

Typical invocation:

```bash
./scripts/gen_instr.sh \
  --init-bin ../common_init/build/common_init.bin \
  --target-sample-num -1 \
  --target-property-mode individual \
  --max-epochs 100 \
  --retry-limit 5 \
  --seed 1
```

Use `--target-property-mode merged` only for sanity checks against the original
merged-property behavior. The ablation result should use the default
`individual` mode.

Use `--dry-run` to validate inputs and materialize the run configuration without
starting licensed tools.  A stopped run can be continued without repeating its
other arguments:

```bash
./scripts/gen_instr.sh --resume --run-tag <tag>
```
