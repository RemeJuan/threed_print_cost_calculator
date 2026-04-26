# Bambu Studio

## Identification

Typical header markers:

```gcode
; HEADER_BLOCK_START
; BambuStudio
; HEADER_BLOCK_END
```

Versioned variant also possible:

```gcode
; BambuStudio 1.x.x
```

## Keys to extract

### Time

Primary:

```gcode
; total estimated time = 6m 39s
```

Supporting but not preferred:

```gcode
; model printing time = 21s
```

### Filament

Primary keys:

```gcode
; total filament length [mm] = 35.16
; total filament weight [g] = 0.11
```

Alternative/supporting key:

```gcode
; total filament volume [cm^3] = 84.58
```

### Layer height

No single stable layer-height key confirmed from current research. Capture if sample files expose one; otherwise leave optional/unknown.

### Preview image

No standard plain-G-code thumbnail pattern confirmed. Bambu preview data may live in container/bgcode workflows instead of portable comment blocks.

## Real snippet

```gcode
; HEADER_BLOCK_START
; BambuStudio
; total estimated time = 6m 39s
; total layer number = 3
; total filament length [mm] = 35.16
; total filament volume [cm^3] = 84.58
; total filament weight [g] = 0.11
; HEADER_BLOCK_END
```

## Quirks

- Metadata grouped in explicit header block.
- Keys use `total ...` naming, not Prusa/Cura naming.
- Some releases reportedly changed or omitted certain filament lines.
- Strong overlap with Orca lineage, but not identical field names.

## Confidence

Medium-high
