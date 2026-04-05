#!/usr/bin/env python3
"""Synchronize mission artifacts from an approved Product Intent plan."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Dict, List, Optional


SECTION_RE = re.compile(r"^## (?P<title>.+?)\s*$", re.MULTILINE)
FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)
REQ_ROW_RE = re.compile(
    r"^\|\s*(REQ-\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|(?:\s*)$"
)
BUILD_ENV_RE = re.compile(r"^- \*\*([^*]+)\*\*:\s*(.+?)\s*$")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def parse_frontmatter(text: str) -> Dict[str, str]:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}
    frontmatter: Dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip()
    return frontmatter


def parse_sections(text: str) -> Dict[str, str]:
    matches = list(SECTION_RE.finditer(text))
    sections: Dict[str, str] = {}
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        sections[match.group("title")] = text[start:end].strip()
    return sections


def strip_brackets(value: str) -> str:
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        return value[1:-1].strip()
    return value


def parse_bullets(section_text: str) -> List[str]:
    items: List[str] = []
    for line in section_text.splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            items.append(strip_brackets(stripped[2:]))
    return [item for item in items if item]


def parse_boundaries(section_text: str) -> Dict[str, str]:
    result: Dict[str, str] = {}
    for line in section_text.splitlines():
        match = re.match(r"^- \*\*([^*]+)\*\*:\s*(.+)$", line.strip())
        if not match:
            continue
        result[match.group(1).strip().lower()] = strip_brackets(match.group(2))
    return result


def parse_requirements(section_text: str) -> List[Dict[str, str]]:
    requirements: List[Dict[str, str]] = []
    for line in section_text.splitlines():
        if line.strip().startswith("|----"):
            continue
        match = REQ_ROW_RE.match(line.strip())
        if not match:
            continue
        req_id, name, acceptance, priority = match.groups()
        requirements.append(
            {
                "id": req_id.strip(),
                "name": name.strip(),
                "acceptance": acceptance.strip(),
                "priority": priority.strip().lower(),
            }
        )
    return requirements


def parse_build_environment(section_text: str) -> Dict[str, str]:
    env: Dict[str, str] = {}
    for line in section_text.splitlines():
        match = BUILD_ENV_RE.match(line.strip())
        if not match:
            continue
        label = match.group(1).strip().lower().replace(" ", "_")
        env[label] = strip_brackets(match.group(2))
    return env


def derive_gate_commands(build_env: Dict[str, str]) -> List[Dict[str, object]]:
    candidates = [
        ("tests-pass", "Test command", "command", build_env.get("test_command")),
        ("lint-pass", "Lint command", "command", build_env.get("lint_command")),
        ("typecheck-pass", "Type check command", "command", build_env.get("type_check_command")),
        ("build-pass", "Build command", "command", build_env.get("build_command")),
        ("integration-pass", "Integration test", "command", build_env.get("integration_test")),
    ]
    gates: List[Dict[str, object]] = []
    for gate_id, name, gate_type, command in candidates:
        if not command:
            continue
        gates.append(
            {
                "id": gate_id,
                "name": name,
                "type": gate_type,
                "required": True,
                "command": command,
            }
        )
    gates.append(
        {
            "id": "plan-synced",
            "name": "Mission plan synchronized from approved Product Intent document",
            "type": "artifact",
            "required": True,
            "artifact": ".claude/mission/plan.md",
        }
    )
    gates.append(
        {
            "id": "walkthrough-written",
            "name": "Completion walkthrough written before final handoff",
            "type": "artifact",
            "required": True,
            "artifact": "TODO.md#Walkthrough",
        }
    )
    return gates


def default_branch(requirements: List[Dict[str, str]]) -> str:
    if not requirements:
        return ""
    return requirements[0]["id"]


def build_intent(
    frontmatter: Dict[str, str],
    sections: Dict[str, str],
    requirements: List[Dict[str, str]],
    phase: str,
) -> Dict[str, object]:
    boundaries = parse_boundaries(sections.get("Boundaries", ""))
    plan_id = frontmatter.get("plan_id", "")
    return {
        "mission_id": plan_id or "mission",
        "plan_id": frontmatter.get("plan_id", ""),
        "status": frontmatter.get("status", ""),
        "name": strip_brackets(sections.get("The Job", "").splitlines()[0]) if sections.get("The Job") else "",
        "objective": strip_brackets(sections.get("The Job", "")),
        "objective_slice": default_branch(requirements),
        "announcement": strip_brackets(sections.get("The Announcement", "")),
        "appetite": strip_brackets(sections.get("The Appetite", "")),
        "non_goals": parse_bullets(sections.get("Out of Scope", "")),
        "principles": parse_bullets(sections.get("Principles", "")),
        "constraints": [
            value
            for key, value in boundaries.items()
            if key in {"guardrails", "invariants", "stop rules"}
        ],
        "success_criteria": boundaries.get("success", ""),
        "current_phase": phase,
        "owner": "mayor",
        "requirements": requirements,
    }


def build_evidence(build_env: Dict[str, str], requirements: List[Dict[str, str]]) -> Dict[str, object]:
    required_gates = derive_gate_commands(build_env)
    return {
        "required_gates": required_gates,
        "optional_gates": [],
        "verification_commands": [gate["command"] for gate in required_gates if gate.get("type") == "command"],
        "completion_requirements": [gate["id"] for gate in required_gates if gate.get("required", True)],
        "escalation_conditions": ["blocked", "missing_dependency", "validator_runtime_error"],
        "requirements": [
            {
                "id": requirement["id"],
                "name": requirement["name"],
                "acceptance": requirement["acceptance"],
            }
            for requirement in requirements
        ],
    }


def build_plan_markdown(frontmatter: Dict[str, str], sections: Dict[str, str], requirements: List[Dict[str, str]]) -> str:
    boundaries = parse_boundaries(sections.get("Boundaries", ""))
    out_of_scope = parse_bullets(sections.get("Out of Scope", ""))
    requirement_lines = [
        f"- [ ] {item['id']} ({item['priority']}): {item['name']} -- {item['acceptance']}"
        for item in requirements
    ]
    if not requirement_lines:
        requirement_lines = ["- [ ] No explicit requirements parsed from plan"]
    lines = [
        f"# Mission Plan: {strip_brackets(sections.get('The Job', '').splitlines()[0]) or frontmatter.get('plan_id', 'unnamed-plan')}",
        "",
        "## Objective",
        strip_brackets(sections.get("The Job", "")) or "_Missing objective_",
        "",
        "## Active Branch",
        f"- [ ] Active branch: {default_branch(requirements) or 'unassigned'}",
        f"- [ ] Plan ID: {frontmatter.get('plan_id', '') or 'unknown'}",
        "",
        "## Next Milestone",
        f"- [ ] Clear {default_branch(requirements) or 'the current branch'} and satisfy required evidence gates",
        "",
        "## Known Risks",
        *([f"- {item}" for item in out_of_scope] or ["- No explicit risks captured yet"]),
        "",
        "## Branch Summaries",
        "- No branch summaries recorded yet",
        "",
        "## Requirements",
        *requirement_lines,
        "",
        "## Evidence",
        "- [ ] tests-pass",
        "- [ ] lint-pass",
        "- [ ] typecheck-pass",
        "- [ ] build-pass",
        "- [ ] integration-pass",
        "- [ ] plan-synced",
        "- [ ] walkthrough-written",
        "",
        "## Boundaries",
        f"- Success: {boundaries.get('success', 'unspecified')}",
        f"- Guardrails: {boundaries.get('guardrails', 'unspecified')}",
        f"- Stop rules: {boundaries.get('stop rules', 'unspecified')}",
    ]
    return "\n".join(lines).rstrip() + "\n"


def merge_state(existing: Optional[Dict[str, object]], intent: Dict[str, object], evidence: Dict[str, object], phase: str) -> Dict[str, object]:
    existing = existing or {}
    evidence_status = existing.get("evidence_status", {})
    if not isinstance(evidence_status, dict):
        evidence_status = {}
    for gate in evidence.get("required_gates", []):
        gate_id = gate.get("id")
        if gate_id and gate_id not in evidence_status:
            evidence_status[gate_id] = "missing"
    evidence_status["plan-synced"] = "passed"
    return {
        "tool_count": int(existing.get("tool_count", 0) or 0),
        "last_progress_at": existing.get("last_progress_at", ""),
        "last_event_at": existing.get("last_event_at", ""),
        "last_event_type": existing.get("last_event_type", ""),
        "current_branch": existing.get("current_branch") or intent.get("objective_slice", ""),
        "last_witness_action": existing.get("last_witness_action", "none"),
        "blocked": bool(existing.get("blocked", False)),
        "recent_failures": int(existing.get("recent_failures", 0) or 0),
        "goal_aligned": bool(existing.get("goal_aligned", True)),
        "completion_claimed": bool(existing.get("completion_claimed", False)),
        "require_evidence_now": bool(existing.get("require_evidence_now", False)),
        "sandbox_mode": existing.get("sandbox_mode", True),
        "phase": phase,
        "plan_id": intent.get("plan_id", ""),
        "evidence_status": evidence_status,
    }


def write_json(path: Path, data: Dict[str, object]) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", required=True)
    parser.add_argument("--phase", default="execute", choices=["interview", "execute"])
    args = parser.parse_args()

    plan_path = Path(args.plan).expanduser().resolve()
    if not plan_path.exists():
        raise SystemExit(f"plan not found: {plan_path}")

    project_root = plan_path.parent.parent.parent
    mission_dir = project_root / ".claude" / "mission"
    ensure_dir(mission_dir)

    text = read_text(plan_path)
    frontmatter = parse_frontmatter(text)
    sections = parse_sections(text)
    requirements = parse_requirements(sections.get("Requirements (ordered by priority)", sections.get("Requirements", "")))
    build_env = parse_build_environment(sections.get("Build Environment", ""))

    intent = build_intent(frontmatter, sections, requirements, args.phase)
    evidence = build_evidence(build_env, requirements)
    plan_markdown = build_plan_markdown(frontmatter, sections, requirements)

    state_path = mission_dir / "state.json"
    existing_state = None
    if state_path.exists():
        try:
            existing_state = json.loads(read_text(state_path))
        except json.JSONDecodeError:
            existing_state = None

    state = merge_state(existing_state, intent, evidence, args.phase)

    write_json(mission_dir / "intent.json", intent)
    write_json(mission_dir / "evidence.json", evidence)
    write_json(state_path, state)
    (mission_dir / "plan.md").write_text(plan_markdown, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
