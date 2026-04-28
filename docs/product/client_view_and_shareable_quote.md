# Client View and Shareable Quote

## Summary

Adds a client-safe presentation mode for quote results derived from pricing output. It should let users switch from internal costing details to a simplified shareable quote without exposing sensitive inputs.

## Goals

- Turn pricing results into a client-safe quote view
- Let users switch between internal and client-facing output
- Support easy sharing in common lightweight formats

## Scope

### In scope

- Use existing pricing output as the quote basis
- Toggle between internal and client view
- Shareable output as image and/or text
- Hide sensitive cost inputs in client view

### Out of scope

- Customer approval workflows
- Hosted quote links or backend delivery
- CRM or invoicing integrations

## Key Decisions

- Client quote output uses pricing output rather than raw cost-only values.
- Users can toggle between internal and client views.
- Shareable output will support image and/or text formats.
- Sensitive cost inputs are hidden in the client-facing view.

## Open Questions

- Should shared output be generated from the current calculator screen only, or also from saved history entries?

## Implementation Notes

- Reuse calculator and pricing state instead of creating a separate quote computation path.
- Riverpod should drive the internal/client view toggle so multiple surfaces stay consistent.
- Share flow should remain local-first, using platform share/export capabilities without backend storage.
- History integration, if added, should respect existing premium gating and saved job structures.
- Keep all visible copy localized through existing l10n patterns.

## Dependencies

- Depends on pricing model output.
- Likely depends on existing calculator result UI and platform sharing capabilities.
