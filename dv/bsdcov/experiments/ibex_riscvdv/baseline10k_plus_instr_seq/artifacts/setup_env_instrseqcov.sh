#!/usr/bin/env bash
set -e
source /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/uvm/core_ibex/setup_env.sh
if [ -x /home/lvzhengyang/workspace/cadence/xrun ]; then
  export CADENCE_XRUN=/home/lvzhengyang/workspace/cadence/xrun
  export PATH="$(dirname "$CADENCE_XRUN"):$PATH"
fi
