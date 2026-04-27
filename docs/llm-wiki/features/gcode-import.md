# G-code import (in-progress)

## Context
- G-code import was previously rejected and later revived with phased scope.

## Decisions
- Implement in phases.
- Initial phase limited to upload + preview.

## Tradeoffs
- Limited format/support in early milestone.
- Faster delivery and earlier feedback loop.

## Rejected Ideas
- Full parser in first release.
- Deep slicer integrations upfront.

## Implementation Notes
- Candidate library noted: `gcode_view`.
- TODO: verify in code whether this library is still the active choice.

## Known Issues
- Feature is incomplete and not yet end-to-end.
- TODO: verify in code current parser/preview limitations by format and size.

## TODOs
- Build upload flow.
- Add preview UI.
- Validate file formats.
- Run beta testing.
