# Day 1 — ASAP7 Physical Design Learning Notes

## 1. Project and Technology

The project uses the **ASAP7 7nm predictive technology platform** with **OpenROAD / OpenROAD-flow-scripts**.

ASAP7 is a predictive research technology platform, not a production foundry PDK.

---

# 2. Important Library Views

A standard cell is represented through multiple views. Each view serves a different purpose.

| View | Main Purpose |
|---|---|
| `.lib` | Timing, power, logical and electrical characteristics |
| `.lef` | Physical abstract used by placement and routing |
| `.v` | Logical Verilog behavior |
| `.gds` | Actual physical layout geometry |

### Easy memory

```text
.lib  → Timing / Power / Electrical
.lef  → Physical Abstract
.v    → Logical Function
.gds  → Physical Geometry
```

### Example: BUFx2_ASAP7_75t_R

The same cell can have:

- Liberty → delay, slew, capacitance, timing arcs
- LEF → dimensions, pins, site, obstructions
- Verilog → logical function
- GDS → actual physical geometry

---

# 3. Liberty (`.lib`)

The Liberty file describes how a standard cell behaves electrically and in timing.

Important information studied:

- Cell area
- Input capacitance
- Output capacitance
- Maximum capacitance
- Timing arcs
- Cell rise/fall delay
- Rise/fall transition
- Setup constraints
- Hold constraints
- Power information
- PVT information
- Lookup tables

## Delay lookup table

For a combinational cell, delay is commonly characterized using:

```text
Input slew + Output load
        ↓
     Cell delay
```

Example:

```text
delay_template_7x7

Variable 1 → input_net_transition
Variable 2 → total_output_net_capacitance
```

So:

```text
Input slew = 20 ps
Output load = 11.52 fF
        ↓
Look up corresponding delay
```

## Transition

`rise_transition` / `fall_transition` describe the output slew.

They are **not setup/hold values**.

## Setup and Hold

For a sequential cell, setup and hold are represented using sequential timing constraint arcs.

Example:

```text
D pin
  ↓
related_pin = CLK
  ↓
setup_rising / hold_rising
```

The constraint table axes can represent:

```text
Constrained pin transition
+
Related clock pin transition
```

## Clock-to-Q

For a flip-flop:

```text
CLK → Q
```

is represented by a timing arc such as:

```text
timing_type : rising_edge
```

with `cell_rise` / `cell_fall` tables and transition tables.

---

# 4. Liberty Units

The ASAP7 Liberty header we inspected contained units such as:

```text
time_unit       → ps
capacitive_load → fF
voltage         → V
current         → mA
leakage power   → pW
```

Always check the library header before interpreting numerical values.

---

# 5. Technology LEF vs Standard-Cell LEF

## Technology LEF

Technology LEF describes technology-level physical rules.

Examples:

- Metal layers
- Routing direction
- Width
- Spacing
- Pitch
- Via definitions
- Routing-related technology information

Conceptually:

```text
Technology LEF
      ↓
"What physical rules does this technology have?"
```

## Standard-Cell LEF

Standard-cell LEF describes the physical abstract of an individual cell.

Examples:

- Cell width and height
- SITE
- Pin locations
- Pin layers
- Power/ground pins
- Obstructions
- Symmetry/orientation

Conceptually:

```text
Cell LEF
      ↓
"How is this particular cell represented physically for P&R?"
```

---

# 6. LEF Example — BUFx2

The ASAP7 BUFx2 cell we inspected contained:

```text
SIZE 0.27 BY 0.27 ;
SITE asap7sc7p5t ;
SYMMETRY X Y ;
```

The cell also contained:

- Input pin A
- Output pin Y
- VDD
- VSS
- M1 pin shapes
- Routing obstructions

The ASAP7 placement site was approximately:

```text
0.054 µm × 0.270 µm
```

Therefore a 0.27 µm-wide cell occupies approximately:

```text
0.27 / 0.054 = 5 sites
```

---

# 7. Routing Layers

ASAP7 has multiple metal routing layers.

We inspected technology LEF definitions such as:

```text
M1
M2
M3
M4
...
```

The technology LEF specifies properties such as:

- Direction
- Width
- Spacing
- Pitch

Example concepts:

```text
M1 → vertical
M2 → horizontal
M3 → vertical
M4 → horizontal
```

The exact layer usage depends on the technology and flow configuration.

---

# 8. Routing Tracks

OpenROAD needs a routing grid.

The ASAP7 platform contains:

```text
flow/platforms/asap7/openRoad/make_tracks.tcl
```

A track definition contains:

```text
offset
pitch
```

### Pitch

Distance between repeating routing tracks.

### Offset

Position of the first track relative to the coordinate origin.

Conceptually:

```text
|     |     |     |     |
0    pitch  pitch pitch
↑
offset determines where the grid starts
```

Important distinction:

> Technology LEF describes technology layer rules, while `make_tracks.tcl` establishes the routing grid used by OpenROAD.

---

# 9. Floorplan

Floorplanning establishes the initial physical organization of the chip.

Important concepts:

- Die area
- Core area
- Core utilization
- Aspect ratio
- Placement rows
- Standard-cell sites
- Macro locations
- Routing layers

Conceptually:

```text
Die
┌──────────────────────────────┐
│                              │
│   Core                       │
│   ┌──────────────────────┐   │
│   │                      │   │
│   │  Standard-cell rows  │   │
│   │                      │   │
│   └──────────────────────┘   │
│                              │
└──────────────────────────────┘
```

OpenROAD can initialize the floorplan using parameters such as:

```text
CORE_UTILIZATION
CORE_ASPECT_RATIO
CORE_MARGIN
DIE_AREA
CORE_AREA
```

---

# 10. Placement Rows and Sites

Standard cells are placed in predefined rows.

The `SITE` defines the legal placement grid.

Conceptually:

```text
Row
|site|site|site|site|site|site|

[INV] [BUF] [DFF] [NAND]
```

Cells must align with the legal placement grid.

---

# 11. Macro Placement

Macros are large physical blocks such as SRAMs or other hard blocks.

Macro placement decides where these large blocks are located in the floorplan.

Important considerations:

- Connectivity
- Wirelength
- Routing congestion
- Core boundary
- Macro-to-macro interaction
- Pin accessibility

Macro placement generally happens before standard-cell placement.

---

# 12. Halo

A halo is a **keep-away region around a macro**.

Conceptually:

```text
        HALO
  ┌─────────────────┐
  │  ┌───────────┐  │
  │  │   MACRO   │  │
  │  └───────────┘  │
  └─────────────────┘
```

Purpose:

- Provide routing space
- Improve macro pin accessibility
- Reduce local congestion
- Prevent standard cells from being packed directly against the macro

### Easy definition

> Halo = keep standard-cell placement away from a macro boundary.

---

# 13. Placement Blockage

A placement blockage is a region where standard-cell placement is prohibited or restricted.

It does not have to surround a macro.

```text
Core
┌──────────────────────────────┐
│                              │
│       ┌──────────────┐       │
│       │  BLOCKAGE    │       │
│       │  restricted  │       │
│       │  placement   │       │
│       └──────────────┘       │
│                              │
└──────────────────────────────┘
```

### Halo vs Placement Blockage

```text
Halo
→ Macro-associated keep-away region

Placement blockage
→ General region where cell placement is restricted
```

Placement blockages can be hard or partial/soft depending on the implementation.

---

# 14. Routing Blockage

A routing blockage restricts where routing wires can be created.

```text
Placement blockage → restrict cells

Routing blockage   → restrict wires
```

Do not confuse routing blockages with placement blockages.

---

# 15. Power Distribution Network — PDN

The PDN distributes power and ground throughout the design.

Main concepts:

```text
VDD → Power
VSS → Ground
```

We studied:

- Rails
- Stripes
- Rings
- Power connections
- IR drop
- Electromigration

Conceptually:

```text
Upper-level power
      ↓
    Stripes
      ↓
   Lower-level
     rails
      ↓
 Standard cells
```

The ASAP7 PDN strategy we inspected uses:

```text
M1 / M2 → local cell-level power structures
M5 / M6 → higher-level power distribution
```

The inspected ASAP7 strategy did not contain a conventional `add_pdn_ring` command, so do not assume a ring is generated by that specific configuration.

---

# 16. IR Drop

IR drop is the voltage drop caused by current flowing through resistance.

Basic relationship:

```text
Vdrop = I × R
```

Higher current or resistance produces larger voltage drop.

Lower voltage at a cell can affect cell delay and therefore timing.

---

# 17. Electromigration — EM

Electromigration is the movement/degradation of metal material caused by high current density over time.

Power networks therefore need suitable:

- Metal widths
- Stripe spacing
- Current capacity
- Via structures

This is one reason higher-level power metals are often wider.

---

# 18. Tap Cells and Endcaps

## Tap Cell

Tap cells provide periodic well/substrate connections.

Purpose includes helping satisfy well/substrate and latch-up-related technology requirements.

ASAP7 flow uses:

```text
TAPCELL_ASAP7_75t_R
```

The inspected ASAP7 tapcell script uses a distance parameter to control periodic insertion.

## Endcap

Endcap cells are used at row boundaries to provide proper physical termination and satisfy technology-specific requirements.

Do not assume tap cells and endcaps have the same function even if a particular flow uses the same master cell for both.

---

# 19. Standard-Cell Placement

Placement determines the physical locations of standard cells.

Main objectives:

- Reduce wirelength
- Control density
- Improve timing
- Reduce congestion
- Improve routability

The placement flow is:

```text
Floorplan
    ↓
Macro Placement
    ↓
I/O Placement
    ↓
Global Placement
    ↓
Detailed Placement / Legalization
    ↓
CTS
```

---

# 20. Global Placement

Global placement finds approximately good locations for cells.

It considers factors such as:

- Wirelength
- Density
- Timing
- Routability

Conceptually:

```text
Synthesis netlist
      ↓
Global placement
      ↓
Approximate cell locations
```

Global placement does not necessarily produce final legal locations.

---

# 21. Timing-Driven Placement

When timing-driven placement is enabled, critical timing paths receive additional consideration.

Conceptually:

```text
Critical path
FF1 ───────── FF2

        ↓

Try to reduce physical distance
and improve timing
```

Placement affects timing because interconnect length affects parasitic resistance/capacitance and therefore delay.

---

# 22. Routability-Driven Placement

Routability-driven placement considers congestion.

Conceptually:

```text
Placement
    ↓
Congestion estimation
    ↓
Move cells away from congested regions
    ↓
More routable placement
```

---

# 23. Detailed Placement / Legalization

Detailed placement takes the approximate global placement and makes it physically legal.

It handles:

- Site alignment
- Row alignment
- Overlap removal
- Legal orientations
- Local optimization

Conceptually:

```text
Global placement
      ↓
Approximate locations
      ↓
Detailed placement
      ↓
Legal locations
```

A legal placement means cells satisfy physical placement requirements such as valid rows, site alignment, orientation and no illegal overlap.

---

# 24. Placement Padding

Placement padding reserves additional space around cells during placement.

Conceptually:

```text
Without padding:

[INV][BUF][NAND][DFF]

With padding:

[INV]  [BUF]  [NAND]  [DFF]
```

Padding is different from a macro halo.

```text
Cell padding → extra placement space around cells

Macro halo   → keep-away region around a macro
```

---

# 25. Placement and Parasitics

After placement, OpenROAD can estimate interconnect parasitics:

```text
estimate_parasitics -placement
```

Conceptually:

```text
Cell locations
     ↓
Estimated wire length
     ↓
Estimated R/C
     ↓
Estimated delay
     ↓
Timing analysis / optimization
```

After detailed routing, extracted parasitics can be more accurate.

---

# 26. GDSII

GDSII is the detailed physical layout database.

It contains actual geometry such as:

- Metal shapes
- Diffusion/active shapes
- Poly/gate structures
- Contacts
- Vias
- Physical interconnect
- Cell geometry

Conceptually:

```text
Standard-cell GDS
       +
Placed cells
       +
Power network
       +
Routed interconnect
       ↓
Final GDSII
```

---

# 27. LEF vs GDS

This is an important interview distinction.

### LEF

Abstract physical representation used efficiently by P&R.

Contains:

- Dimensions
- Pins
- Sites
- Obstructions
- Physical abstract information

### GDS

Detailed physical geometry.

```text
LEF → "How can P&R use this cell?"

GDS → "What is the actual layout geometry?"
```

---

# 28. Modes, Corners and Scenarios

## Mode

Mode represents how the design is operating.

Examples:

```text
Functional mode
Scan/Test mode
Low-power mode
```

## Corner

Corner represents the PVT and associated library/RC conditions used for analysis.

```text
P = Process
V = Voltage
T = Temperature
```

The exact corner definitions are technology/platform-specific.

## Scenario

A scenario is a specific combination of:

```text
Mode + Corner + associated constraints/analysis settings
```

Example:

```text
Functional + Slow
Functional + Fast
Scan + Slow
Scan + Fast
```

### Easy memory

```text
MODE     → What is the chip doing?

CORNER   → Under what PVT/analysis condition?

SCENARIO → Mode + Corner + associated constraints
```

---

# 29. Overall Physical Design Flow

The concepts studied on Day 1 fit into the larger flow:

```text
RTL
 ↓
Simulation
 ↓
SDC Constraints
 ↓
Synthesis
 ↓
Floorplan
 ↓
Power Planning
 ↓
Macro / I/O Placement
 ↓
Global Placement
 ↓
Detailed Placement
 ↓
CTS
 ↓
Routing
 ↓
STA
 ↓
DRC / LVS / Physical Verification
 ↓
GDSII
```

---

# 30. Key Interview Points

### `.lib`

Timing and electrical behavior of cells.

### `.lef`

Physical abstract used for placement and routing.

### `.gds`

Actual layout geometry.

### Global placement

Finds good approximate locations.

### Detailed placement

Makes placement legal and performs local optimization.

### Halo

Keep-away region around a macro.

### Placement blockage

Restricts cell placement in a region.

### Routing blockage

Restricts wire routing in a region.

### PDN

Distributes VDD/VSS through rails, stripes and other power structures.

### Tap cell

Provides periodic well/substrate connection.

### Mode

Functional operating condition.

### Corner

PVT/analysis condition.

### Scenario

Mode + corner + associated constraints/settings.

---

# Day 1 Summary

Day 1 established the physical-design foundation needed before starting the actual RTL-to-GDSII implementation.

The major mental model is:

```text
.lib → How cells behave

.lef → How cells fit physically

.v   → What cells logically do

.gds → What cells physically look like
```

and:

```text
Floorplan
   ↓
Placement
   ↓
CTS
   ↓
Routing
   ↓
STA / Physical Verification
   ↓
GDSII
```

**Status: Day 1 completed.**
