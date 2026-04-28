# G-code Auto Calc

## Summary

Adds a lightweight import-assisted flow that reads basic print metadata from G-code and uses it to prefill calculator inputs. Initial value is faster data entry, not full slicer parity.

## Goals

- Reduce manual entry for time and filament usage
- Use imported G-code data to speed calculator workflows
- Keep imported values easy to review and adjust

## Scope

### In scope

- Extract print time from G-code when available
- Extract filament usage from G-code when available
- Prefill calculator inputs from extracted values

### Out of scope

- Full G-code visualization or editing
- Direct printer or slicer integrations
- Automatic pricing beyond existing calculator and pricing flows

## Key Decisions

- The feature extracts time and filament usage from G-code.
- Extracted values prefill existing calculator inputs.

## Open Questions

- Which slicer metadata formats are acceptable in the first pass?
- How should the UI behave when only one of the two target values is available?

## Implementation Notes

- Best fit is an extension of current calculator input flow, not a separate calculation engine.
- Imported values should land in the same Riverpod-driven form state as manual entries.
- Parsed/imported metadata may need lightweight local models, while final saved jobs should continue using existing history storage patterns.
- Keep parser scope narrow and compatible with current G-code import work.

## Dependencies

- Likely depends on G-code import capability or shared file parsing infrastructure.
- Depends on existing calculator input models and result flow.
