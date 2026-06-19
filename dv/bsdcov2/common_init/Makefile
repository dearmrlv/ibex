.PHONY: build run check clean

build:
	./scripts/build.sh

run: build
	./scripts/run_sim.sh

check:
	@test -L runs/latest || { echo "ERROR: runs/latest does not exist" >&2; exit 1; }
	./scripts/check_result.py "$$(readlink -f runs/latest)"

clean:
	rm -rf build runs
