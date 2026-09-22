# Day 03 Command Reference

## Environment

```bash
cd ~/asap7_tools/OpenROAD-flow-scripts/flow
```

## Routing

```bash
make route DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

Force rebuild when configuration changes:

```bash
make -B route DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

## GDS

```bash
make gds DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

## DRC

```bash
make drc DESIGN_CONFIG=./designs/asap7/alu32_pipeline/config.mk
```

## OpenROAD

```bash
/home/reguri/asap7_tools/OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad -no_init
```

## Post-route STA

```tcl
read_db /home/reguri/asap7_tools/OpenROAD-flow-scripts/flow/results/asap7/alu32_pipeline/base/5_route.odb
foreach lib [glob /home/reguri/asap7_tools/OpenROAD-flow-scripts/flow/platforms/asap7/lib/NLDM/*RVT_FF_nldm*] { read_liberty $lib }
read_sdc /home/reguri/asap7_tools/OpenROAD-flow-scripts/flow/results/asap7/alu32_pipeline/base/5_route.sdc
report_checks -path_delay max -from [all_registers] -to [all_registers] -group_path_count 10
report_checks -path_delay min -from [all_registers] -to [all_registers] -group_path_count 10
```

## Baseline protection

```bash
cp results/asap7/alu32_pipeline/base/5_route.odb results/asap7/alu32_pipeline/base/5_route_baseline.odb
cp results/asap7/alu32_pipeline/base/5_route.sdc results/asap7/alu32_pipeline/base/5_route_baseline.sdc
```
