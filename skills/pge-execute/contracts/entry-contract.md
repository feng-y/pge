# Entry Contract

No entry-time field contract is enforced in the current stage.

`main` must not reject upstream input for missing `goal`, `boundary`, `deliverable`, `verification_path`, or `run_stop_condition`.

Planner owns cutting or normalizing whatever upstream input is provided into one bounded round contract.

If the provided upstream input is unusable, Planner should surface that through its own artifact and escalation output rather than `main` blocking intake.
