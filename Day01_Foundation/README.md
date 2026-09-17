# Day 1 — ASAP7 Physical Design Foundations

## Objective

Understand the basic physical design concepts and physical views required for an RTL-to-GDSII flow using the ASAP7 7nm predictive technology platform and OpenROAD.

## Topics Covered

### Library Views

- `.lib` — Timing, power, logical and electrical characteristics
- `.lef` — Physical abstract used for placement and routing
- `.v` — Logical Verilog model
- `.gds` — Actual physical layout geometry

### Liberty

Studied:

- Cell area
- Input/output capacitance
- Timing arcs
- Cell rise/fall delay
- Rise/fall transition
- Setup and hold constraints
- Lookup tables
- Input slew and output capacitance
- PVT corners

Example cell:

`BUFx2_ASAP7_75t_R`

### Technology LEF and Cell LEF

Technology LEF:
- Routing layers
- Layer direction
- Width
- Spacing
- Pitch
- Via definitions

Cell LEF:
- Cell dimensions
- Site
- Pin locations
- Power/ground pins
- Routing obstructions
- Symmetry and orientation

### Floorplan

Studied:

- Die area
- Core area
- Core utilization
- Aspect ratio
- Placement rows
- Standard-cell sites
- Macro placement
- Halo and blockages

### Power Distribution Network

Studied:

- VDD and VSS
- Standard-cell rails
- Power stripes
- Power connections
- IR drop
- Electromigration

### Tap Cells and Endcaps

Studied the purpose of tap cells and endcap cells and their role in physical design reliability and row termination.

### Standard-Cell Placement

Global placement considers:

- Wirelength
- Density
- Timing
- Routability

Detailed placement / legalization handles:

- Site alignment
- Row alignment
- Overlap removal
- Legal orientations
- Local optimization

Placement flow:

Floorplan
→ Macro Placement
→ I/O Placement
→ Global Placement
→ Detailed Placement / Legalization
→ CTS

### GDSII

GDS contains the actual physical layout geometry, including physical shapes for layers, cells, vias and interconnect.

## Hands-on Exploration

Inspected the ASAP7 platform files and OpenROAD flow scripts, including:

- ASAP7 Liberty files
- Standard-cell LEF files
- Technology LEF
- Standard-cell GDS files
- ASAP7 routing track configuration
- Tap-cell and endcap insertion
- Floorplan initialization
- ASAP7 PDN configuration
- Global placement flow
- Detailed placement and legalization

## Overall RTL-to-GDSII Flow

RTL
→ Simulation
→ Synthesis
→ Floorplan
→ Placement
→ CTS
→ Routing
→ STA / Physical Verification
→ GDSII

## Tools / Environment

- ASAP7 7nm predictive technology platform
- OpenROAD
- OpenROAD-flow-scripts
- WSL2 / Ubuntu
- VS Code

## Status

**Day 1 — Foundation completed**

Next: **Day 2 — RTL Design, Simulation and SDC Constraints**
EOF
