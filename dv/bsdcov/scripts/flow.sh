./scripts/prep.sh
./scripts/extract.sh
./scripts/rand_instr.sh --seed 1 --num 300 --chunk-size 100 --force
./scripts/launch_sim.sh   --instr-seq riscvdv/assembly/seq.1.300.chunks.f   --bind-flist bsdcovproj/sim_bind.f   --cov-update 100   --jobs 3