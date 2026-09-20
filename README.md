# ASAP7 RTL-to-GDSII

A hands-on RTL-to-GDSII physical design project using the **ASAP7 7nm predictive technology platform** and **OpenROAD**.

This project is being developed step-by-step to understand the complete digital physical design flow, from RTL design to final GDSII, with emphasis on practical implementation, debugging, timing analysis, and physical verification.

---

## Project Objective

The goal of this project is to build and document a complete RTL-to-GDSII flow using:

- ASAP7 7nm predictive technology platform
- OpenROAD
- OpenROAD-flow-scripts
- Verilog RTL
- SDC timing constraints
- Static Timing Analysis
- Physical Design
- Physical Verification

The project is structured as a day-by-day learning and implementation journey.

---

## RTL-to-GDSII Flow

```text
RTL Design
    ↓
RTL Simulation
    ↓
SDC Constraints
    ↓
Logic Synthesis
    ↓
Floorplan
    ↓
Power Planning
    ↓
Macro Placement
    ↓
I/O Placement
    ↓
Global Placement
    ↓
Detailed Placement / Legalization
    ↓
Clock Tree Synthesis (CTS)
    ↓
Routing
    ↓
Static Timing Analysis (STA)
    ↓
Physical Verification
    ↓
GDSII
