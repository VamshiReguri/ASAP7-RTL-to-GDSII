# Day 3 Signoff Results

## Routing

Baseline routing:

- Minimum routing layer: M2
- Maximum routing layer: M7
- Detailed routing: completed

Controlled M3 experiment:

- M3–M7 routing: failed
- Error: `DRT-0255 Maze Route cannot find path of net _0003_`

## Setup STA

Worst reported setup path:

- Startpoint: `op_reg[0]`
- Endpoint: `Y[28]`
- Arrival: `546.21 ps`
- Required: `9831.28 ps`
- Slack: `+9285.07 ps`
- Result: MET

## Hold STA

Worst reported hold path:

- Startpoint: `A_reg[3]`
- Endpoint: `Y[3]`
- Arrival: `111.85 ps`
- Required: `56.51 ps`
- Slack: `+55.34 ps`
- Result: MET

## GDSII

- Final GDS: `6_final.gds`
- LEF/GDS matching: reported successful
- Orphan cells: reported none

## DRC

- Total reported markers: 39
- DRC execution: completed
- DRC clean: No

Validated DRC findings:

- 11 blank-category records were traced to top-level non-orthogonal geometry.
- Some `GATE.ACTIVE.S.4`, `LIG.S.4-5`, and `V1.S.4` markers were reproduced in isolated library-cell checks.
- Investigated `M4.S.5` cases showed 24 nm spacing against a 25 nm requirement.
- Investigated M4 violations were already present in the detailed-route database.
