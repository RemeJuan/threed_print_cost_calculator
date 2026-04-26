# Cura

## Identification

Primary marker:

```gcode
;Generated with Cura_SteamEngine 5.x.x
```

## Keys to extract

### Time

Primary:

```gcode
;TIME:626
```

Interpret as seconds.

### Filament

RepRap/Marlin-style:

```gcode
;Filament used: 0.111376m
```

Multi-material variant:

```gcode
;Filament used: 0.02m, 0.05m
```

UltiGCode-style alternatives:

```gcode
;MATERIAL:111.376
;MATERIAL2:50.000
```

### Layer height

```gcode
;Layer height: 0.1
```

### Preview image

No standard embedded-thumbnail comment pattern assumed.

## Real snippet

```gcode
;FLAVOR:Marlin
;TIME:626
;Filament used: 0.111376m
;Layer height: 0.1
;Generated with Cura_SteamEngine master
```

## Quirks

- `;TIME:` strong primary key.
- Filament unit can be meters or flavor-specific material values.
- Header order may vary.
- Best-effort parser target; third-party post-processing can alter comments.

## Confidence

Medium-high
