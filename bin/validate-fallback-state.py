#!/usr/bin/env python3
"""
Validate state.json for proper fallback recording after agent auth failure.
Usage: python3 bin/validate-fallback-state.py .pge/tasks-<slug>/runs/<run_id>/state.json
"""

import json
import sys
from pathlib import Path

def validate_fallback_state(state_path):
    """Validate state.json has proper fallback recording."""

    if not Path(state_path).exists():
        return {
            "valid": False,
            "errors": [f"State file not found: {state_path}"]
        }

    try:
        with open(state_path) as f:
            state = json.load(f)
    except json.JSONDecodeError as e:
        return {
            "valid": False,
            "errors": [f"Invalid JSON: {e}"]
        }

    errors = []
    warnings = []

    # Check lane_health structure
    lane_health = state.get("lane_health", {})
    if not lane_health:
        warnings.append("No lane_health recorded")

    # Check for fallback lanes
    fallback_lanes = []
    for lane_name, health in lane_health.items():
        execution_mode = health.get("execution_mode")
        startup_status = health.get("startup_status")
        failure_surface = health.get("startup_failure_surface")

        if execution_mode == "main_thread_fallback":
            fallback_lanes.append(lane_name)

            # Validate fallback recording
            if startup_status != "FAILED":
                errors.append(
                    f"Lane {lane_name}: execution_mode=main_thread_fallback "
                    f"but startup_status={startup_status} (expected FAILED)"
                )

            if not failure_surface:
                errors.append(
                    f"Lane {lane_name}: execution_mode=main_thread_fallback "
                    f"but startup_failure_surface is missing"
                )

            valid_surfaces = [
                "team_auth_failure",
                "lane_ready_timeout",
                "invalid_lane_registration",
                "spawn_failure",
                "channel_unavailable"
            ]

            if failure_surface and failure_surface not in valid_surfaces:
                warnings.append(
                    f"Lane {lane_name}: unexpected startup_failure_surface={failure_surface} "
                    f"(valid: {', '.join(valid_surfaces)})"
                )

            # Check agent_type recorded
            if not health.get("agent_type"):
                warnings.append(
                    f"Lane {lane_name}: agent_type not recorded for fallback lane"
                )

    # Check issues using fallback
    issues = state.get("issues", {})
    fallback_issues = []
    for issue_id, issue_state in issues.items():
        if issue_state.get("execution_mode") == "main_thread_fallback":
            fallback_issues.append(issue_id)

    # Summary
    result = {
        "valid": len(errors) == 0,
        "errors": errors,
        "warnings": warnings,
        "fallback_lanes": fallback_lanes,
        "fallback_issues": fallback_issues,
        "total_lanes": len(lane_health),
        "total_issues": len(issues)
    }

    return result

def main():
    if len(sys.argv) < 2:
        print("Usage: validate-fallback-state.py <state.json>", file=sys.stderr)
        sys.exit(1)

    state_path = sys.argv[1]
    result = validate_fallback_state(state_path)

    # Print JSON result
    print(json.dumps(result, indent=2))

    # Exit code
    sys.exit(0 if result["valid"] else 1)

if __name__ == "__main__":
    main()
