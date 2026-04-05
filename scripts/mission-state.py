#!/usr/bin/env python3
"""Mutate mission state.json with small deterministic operations."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load_state(project: Path) -> Dict[str, Any]:
    path = project / ".claude" / "mission" / "state.json"
    if not path.exists():
        raise SystemExit(f"missing mission state: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def save_state(project: Path, state: Dict[str, Any]) -> None:
    path = project / ".claude" / "mission" / "state.json"
    path.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def parse_bool(value: str) -> bool:
    lowered = value.lower()
    if lowered in {"true", "1", "yes"}:
        return True
    if lowered in {"false", "0", "no"}:
        return False
    raise SystemExit(f"invalid boolean: {value}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", default=".")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("touch-progress")

    p = sub.add_parser("set-phase")
    p.add_argument("value")

    p = sub.add_parser("set-branch")
    p.add_argument("value")

    p = sub.add_parser("set-evidence")
    p.add_argument("gate_id")
    p.add_argument("status")

    p = sub.add_parser("set-blocked")
    p.add_argument("value")

    p = sub.add_parser("set-goal-aligned")
    p.add_argument("value")

    p = sub.add_parser("set-completion-claimed")
    p.add_argument("value")

    p = sub.add_parser("set-recent-failures")
    p.add_argument("value", type=int)

    p = sub.add_parser("set-require-evidence-now")
    p.add_argument("value")

    args = parser.parse_args()
    project = Path(args.project).expanduser().resolve()
    state = load_state(project)

    if args.cmd == "touch-progress":
        state["last_progress_at"] = now_iso()
        state["blocked"] = False
        state["recent_failures"] = 0
    elif args.cmd == "set-phase":
        state["phase"] = args.value
    elif args.cmd == "set-branch":
        state["current_branch"] = args.value
    elif args.cmd == "set-evidence":
        evidence = state.setdefault("evidence_status", {})
        if not isinstance(evidence, dict):
            evidence = {}
            state["evidence_status"] = evidence
        evidence[args.gate_id] = args.status
        if args.status == "passed":
            state["last_progress_at"] = now_iso()
    elif args.cmd == "set-blocked":
        state["blocked"] = parse_bool(args.value)
    elif args.cmd == "set-goal-aligned":
        state["goal_aligned"] = parse_bool(args.value)
    elif args.cmd == "set-completion-claimed":
        state["completion_claimed"] = parse_bool(args.value)
    elif args.cmd == "set-recent-failures":
        state["recent_failures"] = int(args.value)
    elif args.cmd == "set-require-evidence-now":
        state["require_evidence_now"] = parse_bool(args.value)

    save_state(project, state)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
