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

- Some `GATE.ACTIVE.S.4`, `LIG.S.4-5`, and `V1.S.4` markers were reproduced during isolated library-cell checks.
- Investigated `M4.S.5` cases showed 24 nm edge-to-edge spacing against a 25 nm rule requirement.
- The investigated M4 violations were already present in the detailed-route database.
- Additional `M5.S.5`, `V1.S.4`, `V2.M3.AUX.2`, `V4.M5.AUX.2`, and `V5.M6.AUX.2` markers were identified and investigated using the DRC database and final layout geometry.
- 11 records were reported with a blank/uncategorized DRC category. Their geometry contains diagonal polygon edges, but the exact originating DRC rule was not established from the available DRC database and deck configuration. These records were therefore not assigned an unsupported rule name.

## Routing-Layer Adjustment Experiment

The ASAP7 flow was tested with different routing-layer capacity adjustments while preserving the known-good routed baseline.

| Routing Layer Adjustment | Result |
|---:|---|
| 0.10 | Detailed routing failed |
| 0.175 | Detailed routing failed |
| 0.25 | Known-good baseline |

At lower values, detailed routing reported `DRT-0255 Maze Route cannot find path` errors for specific nets.

The known-good baseline was preserved separately as:

`5_route_baseline.odb`

The project configuration was restored to `ROUTING_LAYER_ADJUSTMENT = 0.25`.
