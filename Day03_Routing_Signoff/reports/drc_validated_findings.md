# Validated DRC Findings

## 1. 11 blank-category records

The marker polygons were inspected. Their coordinates included diagonal closing edges, demonstrating non-orthogonal top-level geometry.

## 2. Library-side checks

Isolated library-cell checks reproduced:

- AO211: `GATE.ACTIVE.S.4`
- DFF: `LIG.S.4-5`, `V1.S.4`

This supports classifying those markers separately from newly routed top-level geometry.

## 3. M4.S.5

Investigated M4 geometry showed:

```text
Required spacing = 25 nm
Observed spacing = 24 nm
Shortfall         = 1 nm
```

The geometry was found in the route-stage DEF/ODB, so it was not introduced solely by final GDS conversion.

## 4. M1.S.6

Generic M1 spacing checks were not treated as equivalent to the exact ASAP7 M1.S.6 rule because the PDK rule contains additional filtering/interaction logic. This prevented an incorrect conclusion from a simplistic geometric query.
