# Ibex common initialization image

This image executes only the architectural initialization prefix shared with
`cpu_init`, from `0x80000080` through `0x8000011c`. A simulation-only RVFI
monitor ends the run after the instruction at `0x8000011c` retires.

The local instruction-memory interface grants requests only in
`0x80000080..0x8000011c`. Later speculative fetch requests remain ungranted.
The run ends only after the final instruction retires and every accepted
instruction request has received its response.

The image intentionally contains no test-result write, idle loop, or trap
handler. The linker still defines `trap_handler` as `0x80000138`, so the prefix
bytes and final `mtvec` value remain identical to `cpu_init`.

```bash
cd designs/ibex/dv/bsdcov1/bsdcov_run/common_init
make run
```

Each run writes:

- `runs/<tag>/fsdb/common_init.fsdb` for JasperGold state restoration.
- `runs/<tag>/coverage/` with the DUT coverage database and report.
- `runs/<tag>/result.json` with retirement and artifact checks.

`runs/latest` points to the newest run.
