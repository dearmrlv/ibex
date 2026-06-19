#!/usr/bin/env python3
from __future__ import annotations

import json
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

from _flow_args import FlowRuntime


class RuntimeTimer:
    def __init__(self, runtime: FlowRuntime):
        self.runtime = runtime
        self.event_path = runtime.paths.run_dir / "runtime/runtime_events.jsonl"
        self.event_path.parent.mkdir(parents=True, exist_ok=True)
        self.runtime.state.setdefault("runtime_events", [])

    @contextmanager
    def stage(self, stage: str, name: str, **metadata: object) -> Iterator[None]:
        start = time.monotonic()
        wall_start = time.time()
        ok = False
        try:
            yield
            ok = True
        finally:
            event = {
                "stage": stage,
                "name": name,
                "seconds": round(time.monotonic() - start, 6),
                "wall_start": wall_start,
                "wall_end": time.time(),
                "ok": ok,
                **metadata,
            }
            with self.event_path.open("a", encoding="utf-8") as stream:
                stream.write(json.dumps(event, sort_keys=True) + "\n")
            self.runtime.state.setdefault("runtime_events", []).append(event)

