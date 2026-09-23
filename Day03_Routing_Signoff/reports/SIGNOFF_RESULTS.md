# Day 03 — Routing, Signoff, DRC Analysis & Timing Repair

## Project

- Technology: ASAP7 7nm predictive PDK platform
- Design: 32-bit pipelined arithmetic ALU
- Flow: OpenROAD-flow-scripts / OpenROAD / KLayout
- Objective: Complete detailed routing, post-route STA, GDSII generation, DRC analysis, routing experiments, and timing-repair experiments.

---

# 1. Detailed Routing

The design was routed using the ASAP7 routing configuration:

```text
MIN_ROUTING_LAYER        = M2
MIN_CLK_ROUTING_LAYER    = M4
MAX_ROUTING_LAYER        = M7
ROUTING_LAYER_ADJUSTMENT = 0.25
```

The routing flow was run with:

```bash
make route DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

Important routing outputs included:

```text
5_1_grt.odb
5_2_route.odb
5_3_fillcell.odb
5_route.sdc
route.guide
```

The final routed/fill-cell database was:

```text
5_3_fillcell.odb
```

Routing completed successfully on the known-good baseline.

The detailed routing stage also reported:

```text
[INFO DPL-0001] Placed 1005 filler instances.
[INFO ANT-0001] Found 0 pin violations.
```

The final routed design was approximately:

```text
Design area: 111 µm²
Utilization: 57%
```

---

# 2. Global Routing vs Detailed Routing

## Global Routing

Global routing determines routing regions and approximate paths for nets.

It does not select every final wire segment and via.

The output includes routing guides such as:

```text
route.guide
```

A guide specifies regions in which a net can be routed on particular layers.

## Detailed Routing

Detailed routing converts the global routing plan into actual legal geometries:

- exact routing tracks
- exact wire segments
- vias
- layer transitions
- pin connections

Therefore:

```text
Global routing
      ↓
Routing guides
      ↓
Detailed routing
      ↓
Exact wires + vias
      ↓
Final routed database
```

This distinction became important during the DRC investigation because some DRC violations were visible in the final detailed-route geometry.

---

# 3. Post-Route STA

The final routed database was loaded into OpenROAD and analyzed using the ASAP7 FF NLDM libraries.

The post-route SDC used:

```tcl
create_clock -name clk -period 10000.0 [get_ports clk]

set_input_delay 2000.0 -clock clk [get_ports {A B op}]
set_output_delay 2000.0 -clock clk [get_ports Y]

set_clock_uncertainty -setup 200.0 [get_clocks clk]
set_clock_uncertainty -hold 0.0 [get_clocks clk]

set_clock_transition 100.0 [get_clocks clk]
```

ASAP7 Liberty files used by this analysis specify:

```text
time_unit : "1ps";
```

Therefore timing values in the SDC and STA reports are interpreted in picoseconds.

## Post-Route Setup

Worst reported setup slack:

```text
+9285.07 ps
```

or:

```text
+9.285 ns
```

Example worst setup path:

```text
Startpoint: op_reg[0]
Endpoint:   Y[28]

Data arrival time  = 546.21 ps
Data required time = 9831.28 ps
Setup slack        = +9285.07 ps
```

Another reported path:

```text
op_reg[2] → Y[17]

Setup slack = +9287.81 ps
```

No setup violations were reported.

## Post-Route Hold

Worst reported hold slack:

```text
+55.34 ps
```

or approximately:

```text
+0.055 ns
```

Example:

```text
A_reg[3] → Y[3]

Data arrival time  = 111.85 ps
Data required time = 56.51 ps
Hold slack         = +55.34 ps
```

Another example:

```text
A_reg[21] → Y[21]

Hold slack = +57.44 ps
```

No hold violations were reported in the known-good baseline.

---

# 4. Final GDSII Generation

The GDSII generation flow was run using:

```bash
make gds DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

The final GDS was generated as:

```text
6_final.gds
```

The final database and DEF were also generated:

```text
6_final.odb
6_final.def
6_final.sdc
6_final.spef
6_final.v
```

KLayout reported:

```text
All LEF cells have matching GDS/OAS cells
No orphan cells in the final layout
```

A KLayout warning was observed:

```text
WARN DEF UNITS does not match reader DBU
```

The final DEF uses:

```text
UNITS DISTANCE MICRONS 1000 ;
```

while the ASAP7 KLayout technology uses:

```text
dbu = 0.00025 µm
```

The physical dimensions remained consistent with the expected design dimensions.

The final die was approximately:

```text
18.175 µm × 18.175 µm
```

---

# 5. DRC Signoff

DRC was run using:

```bash
make drc DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

The generated DRC files were:

```text
6_drc.lyrdb
6_drc_count.rpt
```

The total DRC count was:

```text
39
```

The named rule counts were:

| DRC Rule | Count |
|---|---:|
| GATE.ACTIVE.S.4 | 1 |
| LIG.S.4-5 | 2 |
| M1.S.6 | 2 |
| M4.S.5 | 10 |
| M5.S.5 | 2 |
| V1.S.4 | 5 |
| V2.M3.AUX.2 | 1 |
| V4.M5.AUX.2 | 2 |
| V5.M6.AUX.2 | 3 |
| Blank/uncategorized | 11 |
| **Total** | **39** |

The 11 blank/uncategorized records were not assigned an unsupported rule name. Their exact originating DRC rule was not established from the available DRC database and deck configuration.

---

# 6. DRC Classification

The DRC findings were investigated using the DRC database, isolated library-cell checks, and final GDS geometry.

## Library-side findings

Some violations were reproduced in isolated library cells:

```text
GATE.ACTIVE.S.4
LIG.S.4-5
V1.S.4
```

For example:

- `GATE.ACTIVE.S.4` was reproduced in `AO211x2_ASAP7_75t_R`.
- `LIG.S.4-5` was reproduced in `DFFHQNx1_ASAP7_75t_R`.
- Two of the `V1.S.4` findings were reproduced inside DFF library geometry.

These findings were therefore not treated as top-level routing-only findings.

## Top-level routed geometry

Other findings were located in the top-level:

```text
alu32_pipeline
```

including:

```text
M1.S.6
M4.S.5
M5.S.5
V1.S.4
```

## Generated via geometry

The following findings involved generated via-cell geometry:

```text
V2.M3.AUX.2
V4.M5.AUX.2
V5.M6.AUX.2
```

The via cells investigated included:

```text
VIA_VIA23_1_3_36_36
VIA_VIA45_1_2_58_58
VIA_VIA56
VIA_via5_6_120_288_1_2_58_322
```

---

# 7. M4.S.5 Investigation

The ASAP7 DRC rule investigated was:

```text
M4.S.5
```

The rule checks M4 spacing with a 25 nm projection requirement.

Several M4 locations were investigated in the final GDS.

The measured edge-to-edge spacing at the investigated locations was:

```text
24 nm
```

against a:

```text
25 nm
```

rule requirement.

Therefore the investigated locations were confirmed as genuine 1 nm shortfalls relative to the rule requirement.

## Example 1

The first investigated geometry had:

```text
M4 path:
BBOX = 10.185–10.425 µm × 6.816–6.840 µm
Width = 24 nm
```

The nearby geometry had:

```text
BBOX = 10.145–10.178 µm × 6.768–6.792 µm
```

The relevant edge separation was:

```text
6.816 - 6.792 = 0.024 µm
                         = 24 nm
```

The corresponding detailed-route DEF contained M4 geometry from signal nets.

The investigated geometry was already present in the detailed-route database.

## Example 2

Another investigated location contained:

```text
Y[0]
```

and:

```text
net68
```

Both were signal nets.

The measured M4 edge spacing was:

```text
24 nm
```

## Example 3

Another M4 location involved:

```text
B[22]
```

and:

```text
Y[26]
```

The measured edge spacing was:

```text
24 nm
```

## Example 4

Another location involved:

```text
B[20]
```

and:

```text
A[21]
```

The measured edge spacing was:

```text
24 nm
```

## Example 5

Another location involved:

```text
B[23]
```

and:

```text
Y[25]
```

The measured edge spacing was:

```text
24 nm
```

The investigated M4 violations were therefore traced to exact detailed-route geometries rather than merely global-route guides.

---

# 8. M5.S.5 Investigation

The investigated M5 rule was:

```text
M5.S.5
```

The DRC marker occurred around:

```text
7.584 µm
```

The relevant M5 geometry showed an exact edge-to-edge spacing of:

```text
24 nm
```

The DRC rule requirement was:

```text
25 nm
```

The investigated geometry was part of clock-routing geometry in the examined route database.

The analysis was based on exact GDS edges rather than centerline spacing.

---

# 9. Via DRC Investigation

## V2.M3.AUX.2

The investigated via cell was:

```text
VIA_VIA23_1_3_36_36
```

The via geometry was:

```text
18 nm × 18 nm
```

The DRC rule checks the relationship between V2 and M3 enclosure.

## V4.M5.AUX.2

The investigated via cell was:

```text
VIA_VIA45_1_2_58_58
```

The cell was found in the final GDS.

The relevant geometry included:

```text
M5
M4
V4
```

The DRC rule describes the requirement that V4 match the M5 width along the direction perpendicular to the M5 length.

This was treated as a generated via-cell geometry finding.

## V5.M6.AUX.2

The investigated via geometry included:

```text
VIA_VIA56
VIA_via5_6_120_288_1_2_58_322
```

`VIA_VIA56` was found at approximately:

```text
11.916 µm, 14.288 µm
```

Its geometry was measured using the KLayout DBU of:

```text
0.00025 µm
```

The examined shapes corresponded approximately to:

```text
M6 = 46 nm × 32 nm
M5 = 24 nm × 54 nm
V5 = 24 nm × 32 nm
```

The DRC rule checks whether V5 exactly matches the M6 width along the direction perpendicular to the M6 length.

---

# 10. V1.S.4 Investigation

There were five `V1.S.4` findings.

Three were found at top-level locations in:

```text
alu32_pipeline
```

and two were found inside:

```text
DFFHQNx1_ASAP7_75t_R
```

The two DFF findings were reproduced in isolated library-cell geometry.

Therefore the five V1 findings were not all attributed to the top-level route.

---

# 11. Blank / Uncategorized DRC Records

There were:

```text
11
```

blank/uncategorized DRC records.

The corresponding polygons contained diagonal closing edges.

However, the exact originating DRC rule was not established from the available DRC database and deck configuration.

The ASAP7 DRC deck contains a non-orthogonal geometry check inside:

```text
if OFFGRID
```

but the deck configuration used:

```text
OFFGRID = false
```

Therefore these 11 records were deliberately not labeled as:

```text
GEOMETRY.NONORTHOGONAL
```

without direct evidence.

This is an important signoff-analysis limitation.

---

# 12. Routing-Layer Adjustment Experiment

A controlled routing experiment was performed by changing:

```text
ROUTING_LAYER_ADJUSTMENT
```

while preserving the known-good routed baseline.

The results were:

| Routing Layer Adjustment | Result |
|---:|---|
| 0.10 | Detailed routing failed |
| 0.175 | Detailed routing failed |
| 0.25 | Known-good baseline |

At lower values, detailed routing reported:

```text
DRT-0255 Maze Route cannot find path
```

for specific nets.

For example, at different settings the failed nets included:

```text
_0549_
_0225_
_0444_
_0003_
```

At:

```text
0.175
```

the detailed router still failed for:

```text
_0444_
_0003_
```

The known-good routed database was preserved separately as:

```text
5_route_baseline.odb
```

The project configuration was restored to:

```text
ROUTING_LAYER_ADJUSTMENT = 0.25
```

This experiment demonstrated that routing-layer capacity adjustment can materially affect detailed-route completion.

---

# 13. Intentional Hold Violation Experiment

A controlled timing experiment was performed on the known-good routed baseline to demonstrate hold-violation analysis and physical hold repair.

The golden routed database was preserved as:

```text
5_route_baseline.odb
```

A temporary SDC was created.

The baseline hold uncertainty was:

```text
0 ps
```

For the experiment it was intentionally increased to:

```text
60 ps
```

The temporary constraint was:

```tcl
set_clock_uncertainty -setup 200.0 [get_clocks clk]
set_clock_uncertainty -hold 60.0 [get_clocks clk]
```

The purpose was to intentionally consume the existing hold margin without changing the routed physical baseline.

---

# 14. Intentional Hold Violation Results

With 60 ps hold uncertainty, the hold analysis reported:

```text
Hold WNS = -4.657 ps
Hold TNS = -62.326 ps
Violating endpoints = 26
```

Example:

```text
A_reg[3] → Y[3]

Data arrival time  = 111.85 ps
Data required time = 116.51 ps
Hold slack         = -4.66 ps
```

Another example:

```text
A_reg[21] → Y[21]

Data arrival time  = 113.56 ps
Capture clock delay = 43.78 ps
Hold uncertainty   = 60.00 ps
Library hold       = 13.34 ps
Data required time = 116.12 ps
Hold slack         = -2.56 ps
```

The negative slack was intentionally created for the experiment.

The known-good physical baseline itself was not considered broken.

---

# 15. OpenROAD Hold Repair

The available OpenROAD command was inspected with:

```tcl
help repair_timing
```

The relevant repair option was:

```tcl
repair_timing -hold
```

The command was then executed:

```tcl
repair_timing -hold
```

OpenROAD reported:

```text
Found 26 endpoints with hold violations.

Iteration | Resized | Buffers | Cloned Gates |   Area   |   WNS   |   TNS
--------------------------------------------------------------------------------
        0 |       0 |       0 |            0 |    +0.0% |  -4.657 | -62.326
    final |       0 |      26 |            0 |    +2.4% |   0.001 |   0.000

Inserted 26 hold buffers.
```

The tool repaired the intentional hold violations by inserting:

```text
26 hold buffers
```

No resizing or gate cloning was reported.

---

# 16. How Hold Repair Works

A typical hold violation is caused by a data path that is too fast.

Conceptually:

```text
Before repair:

Launch FF
   |
   | Fast data path
   |
Capture FF

Hold violation
```

After hold repair:

```text
Launch FF
   |
   | Fast data path
   |
Hold buffer
   |
Capture FF

Hold timing repaired
```

The inserted buffer increases the minimum data-path delay.

Therefore:

```text
Fast data path
      ↓
Add delay
      ↓
Increase data arrival time
      ↓
Satisfy hold requirement
```

---

# 17. Post-Repair Hold Verification

After repair, the worst reported hold path was approximately at the timing boundary:

```text
A_reg[0] → Y[0]

Data arrival time  = 114.01 ps
Data required time = 114.01 ps
Hold slack         = 0.00 ps MET
```

The repair summary reported:

```text
Hold WNS = +0.001 ps
Hold TNS = 0.000 ps
```

The previously negative hold violations were therefore removed.

Other reported paths had positive hold slack.

---

# 18. Setup Timing After Hold Repair

Hold repair adds delay to data paths, so setup timing must also be checked.

After the hold repair, the worst reported setup path remained:

```text
op_reg[0] → Y[28]

Data arrival time  = 546.21 ps
Data required time = 9831.28 ps
Setup slack        = +9285.07 ps
```

Another reported setup path was:

```text
op_reg[2] → Y[17]

Setup slack = +9287.81 ps
```

No setup violation was introduced in this experiment.

---

# 19. Area Impact of Hold Repair

Before repair:

```text
Design area = 111 µm²
Utilization = 57%
```

The repair operation reported:

```text
Area increase = +2.4%
```

The increase resulted from insertion of:

```text
26 hold buffers
```

This demonstrates the physical-design trade-off between timing closure and area.

---

# 20. Hold Repair Summary

| Metric | Before Repair | After Hold Repair |
|---|---:|---:|
| Hold WNS | -4.657 ps | +0.001 ps |
| Hold TNS | -62.326 ps | 0.000 ps |
| Violating endpoints | 26 | 0 |
| Hold buffers inserted | 0 | 26 |
| Area change | — | +2.4% |
| Worst setup slack | — | +9285.07 ps |

---

# 21. Key Learning — Hold Timing Closure

The complete hold-repair process demonstrated in this experiment was:

```text
Hold violation
      ↓
Identify fast data paths
      ↓
Analyze hold slack
      ↓
Insert delay into data path
      ↓
Hold buffers
      ↓
Re-run hold STA
      ↓
Verify setup timing
      ↓
Check area impact
```

The fundamental trade-off is:

```text
Hold repair
    ↓
Additional data-path delay
    ↓
Improved hold timing
    ↓
Additional cell area
    ↓
Potential setup impact
```

In this design, the intentional hold violations were removed by inserting 26 hold buffers while the reported setup slack remained strongly positive.

---

# 22. Signoff Summary

The Day 3 work covered:

```text
Detailed Routing
      ↓
Post-Route STA
      ↓
GDSII Generation
      ↓
DRC Analysis
      ↓
DRC Geometry Investigation
      ↓
Routing-Layer Experiment
      ↓
Intentional Hold Violation
      ↓
Physical Hold Repair
      ↓
Post-Repair STA
```

Key final baseline results:

```text
Technology:
ASAP7 7nm

Design:
32-bit pipelined arithmetic ALU

Routing:
Successful at ROUTING_LAYER_ADJUSTMENT = 0.25

Post-route setup slack:
+9285.07 ps

Post-route hold slack:
+55.34 ps

Final design area:
~111 µm²

Final utilization:
~57%

GDS:
6_final.gds

DRC count:
39

Known-good routed baseline:
5_route_baseline.odb
```

The DRC investigation documented both library-side and top-level findings without assigning unsupported rule names to the 11 blank/uncategorized records.

The routing-layer experiment demonstrated the sensitivity of detailed routing to routing-capacity adjustment.

The hold experiment demonstrated an end-to-end timing-closure workflow in which intentional hold violations were created, repaired using physical buffer insertion, and rechecked for both hold and setup timing.

---

# 23. Important Baseline Note

The intentional hold experiment used a temporary constraint and an in-memory repaired database.

The known-good routed baseline:

```text
5_route_baseline.odb
```

was preserved separately.

The hold experiment should therefore be treated as a controlled timing-repair study and not as a replacement of the known-good routed baseline.
