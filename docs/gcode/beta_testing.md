# G-code beta testing

## Objective

- Validate parser accuracy across slicers
- Identify edge cases and missing metadata
- Confirm preview extraction reliability

## Target testers

- 3 iOS testers
- 3 Android testers
- Mix of slicers:
  - Bambu Studio
  - OrcaSlicer
  - PrusaSlicer
  - Cura

## What testers should do

- Import real `.gcode` files
- Compare slicer estimate vs app values
- Confirm result is correct or incorrect
- Test multiple files if possible

## Data to collect

For each test, record:

| Field | Value |
|---|---|
| slicer used | required |
| expected print time | required |
| expected filament usage | required |
| actual values from the app | required |
| preview availability | available / not available |
| result | correct / incorrect |
| notes | optional |

## Known expectations

- Bambu and Orca: high accuracy, preview usually available
- Prusa: good accuracy, preview depends on config
- Cura: time and filament usually available, preview often missing unless post-processing is enabled

## Success criteria

- 80-90% accuracy on time and filament across supported slicers
- No crashes on import
- Graceful handling of missing data
- Preview works where expected

## Out of scope

- G-code rendering
- File storage or reuse
- Perfect slicer parity
