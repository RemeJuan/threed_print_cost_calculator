# UX Refresh Direction

## Goal

Modernise the application UI to better align with the updated branding, launcher icon direction, launch assets, and overall product positioning.

The app should feel:
- professional
- engineering-focused
- modern
- trustworthy
- data-driven
- premium without being flashy

The refresh is intended to evolve the existing application rather than redesign it completely.

This is no longer a loose design exploration document.

This document defines the intended implementation direction for the UI refresh.

The latest calculator/results mockup should be treated as the primary visual reference for the refresh.

The target outcome is a more premium, cohesive, workshop-tool style application while preserving the simplicity and usability of the current workflows.

---

# Core Design Principles

## Keep Existing UX Patterns

Avoid introducing unnecessary UX complexity.

Do NOT introduce:
- sliders for calculator values
- unnecessary charts
- decorative 3D previews inside calculator flows
- excessive glow effects
- fintech/SaaS gradients everywhere
- gamified UI patterns
- cluttered dashboards

The app is a utility tool first.

---

## Desired Visual Tone

The UI should feel closer to:
- professional workshop tooling
- slicer software aesthetics
- engineering instrumentation
- modern dark-mode productivity apps

Not:
- gaming UI
- cyberpunk dashboards
- generic AI SaaS templates

---

# Visual Direction

The refresh direction is based heavily on the latest calculator/results screen mockup.

The application should move away from:
- flat material-style utility screens
- monochromatic dark surfaces
- visually identical cards
- generic Flutter styling
- purely functional layouts

The application should move toward:
- layered dark surfaces
- stronger hierarchy
- richer spacing
- more intentional grouping
- refined accent usage
- more premium visual depth
- workshop-tool aesthetics
- professional instrumentation styling

The app should feel:
- modern
- technical
- premium
- mature
- intentional

without becoming flashy.

---

# Color System

## Foundation Colors

```dart
// Core brand colors retained from the original palette.
const DARK_BLUE = Color(0xFF1A1C2B);
const DEEP_BLUE = Color(0xFF0D0D17);
const LIGHT_BLUE = Color(0xFF5499FE);

// UI refresh surface system.
const APP_BACKGROUND = Color(0xFF010710);
const CARD_BACKGROUND = Color(0xFF0A1625);
const SHELL_BACKGROUND = Color(0xFF040C1A);
const SHELL_BORDER = Color(0xFF0F1929);
const RESULT_SURFACE = Color(0xFF131B31);

// UI refresh typography colors.
const OFF_WHITE = Color(0xFFE6E9F0);
const MUTED_BLUE_GREY = Color(0xFF929CB0);
```

These remain the core brand foundation colors.

However, the refresh is NOT limited to only these three colors anymore.

The newer renders demonstrated that the application benefits significantly from a broader supporting palette.

The refresh should introduce a controlled supporting accent spectrum.

All implementation color tokens should use `Color(0xFF...)` format for consistency.

Avoid mixing `Color.fromRGBO(...)` and hex color declarations unless there is a specific reason.

---

## APP_BACKGROUND

Primary refreshed application background.

Use for:
- scaffold backgrounds
- app shell backgrounds
- launch/splash backgrounds
- fullscreen surfaces
- deepest page-level backgrounds

This should become the default page background across the refreshed UI.

---

## DEEP_BLUE

Legacy deep brand color from the original palette.

Keep available for compatibility and secondary dark surfaces, but prefer `APP_BACKGROUND` for new scaffold/page backgrounds.

---

## CARD_BACKGROUND

Primary refreshed card and grouped surface color.

Use for:
- cards
- grouped containers
- summary sections
- settings surfaces
- input groups
- modal content areas
- reusable surface components
- FAQ accordion surfaces
- standard modal content surfaces

This should become the default surface color for refreshed UI components.

Cards should no longer feel visually flat.

Surfaces should feel layered and intentionally grouped against `APP_BACKGROUND`.

---

## DARK_BLUE

Legacy elevated surface color from the original palette.

Keep available for compatibility, but prefer `CARD_BACKGROUND` for new refreshed cards and grouped surfaces.

---

## LIGHT_BLUE

Primary interactive accent.

Use for:
- CTA buttons
- active states
- selected navigation items
- totals
- important values
- focus states
- active icons
- interactive emphasis

This remains the dominant accent color.

---

## SHELL_BACKGROUND

Primary refreshed shell/chrome background.

Use for:
- bottom navigation container
- nav shell surfaces
- header/app chrome surfaces where a visible shell is needed
- modal chrome where appropriate

This replaces the narrower `NAV_BAR_BACKGROUND` naming because the color is useful beyond the bottom navigation.

It should visually separate shell/chrome areas from `APP_BACKGROUND` without feeling like a floating component.

---

## SHELL_BORDER

Subtle separator color for shell/chrome boundaries.

Use for:
- bottom navigation top border
- subtle modal separators
- grouped surface separators where required

Apply through wrapper/container decoration when the Flutter theme does not expose a border property.

---

## RESULT_SURFACE

High-emphasis result surface color.

Use for:
- final totals
- quote totals
- key pricing summaries
- important financial result cards

This surface should sit between `CARD_BACKGROUND` and `LIGHT_BLUE` in visual priority.

It should feel important and authoritative without becoming a warning, CTA, or decorative accent.

Use sparingly. If applied everywhere, it loses its value.

---

## Supporting Cyan

Soft cyan/electric blue accents are now allowed.

Use for:
- subtle glow treatments
- premium highlights
- active informational elements
- focus accents
- visual polish

Must remain subtle.

Avoid cyberpunk/neon styling.

---

## Amber / Warm Highlight

Muted amber/yellow accents are intentionally allowed.

Use for:
- risk emphasis
- warnings
- key insights
- important highlighted statistics
- visual contrast moments

The mockups demonstrated that the warm contrast significantly improved readability and visual richness.

Important:
- amber/yellow is an accent only
- it should NEVER become the dominant UI color
- usage should remain sparse and intentional

---

## Text Colors

Pure white should be avoided where possible.

Use:
- off-white for primary content
- muted grey-blue for secondary text
- lower-contrast text for labels and metadata

This should create stronger visual hierarchy and reduce visual harshness.

---

# Surface Hierarchy

The refreshed UI should follow a clear surface hierarchy:

- `APP_BACKGROUND` → page/application background
- `SHELL_BACKGROUND` → bottom navigation shell, header/app chrome, modal chrome where appropriate
- `CARD_BACKGROUND` → cards, grouped content, accordions, settings sections, input groups, standard modal content
- `SHELL_BORDER` → subtle nav/card/modal separators where required
- `RESULT_SURFACE` → final totals, quote totals, key pricing summaries, high-emphasis result cards
- `LIGHT_BLUE` → primary interaction and emphasis
- `OFF_WHITE` → primary readable text
- `MUTED_BLUE_GREY` → secondary text, inactive icons, metadata
- status accent colors → stock/risk/status badges only, used sparingly and semantically

Avoid creating one-off background colors unless a new reusable token is deliberately introduced.

---

# Visual Elements To Keep From Mockups

The latest mockup direction introduced several elements worth implementing.

Keep:
- darker layered surfaces
- softer elevated cards
- stronger grouped content
- more premium spacing
- refined blue gradients
- restrained glow accents
- stronger CTA buttons
- larger total emphasis
- cleaner grouped result summaries
- richer visual depth
- more intentional typography hierarchy

These changes made the app feel significantly more premium without changing the workflow.

---

# Visual Elements To Avoid

Do NOT introduce:
- sliders
- decorative charts
- decorative 3D previews in workflows
- fake analytics panels
- excessive glow
- gaming UI aesthetics
- cyberpunk styling
- overly bright neon colors
- cluttered dashboards
- glassmorphism
- unnecessary motion
- flashy transitions

The app is still fundamentally:
- a utility tool
- a calculation workflow
- a productivity application

Usability remains the priority.

---

# Launcher Icon Direction

## Current Preferred Direction

The currently preferred launcher direction is:
- layered print stack
- simplified print nozzle
- geometric technical styling
- dark blue + light blue palette
- minimal but recognisable structure

The icon should:
- clearly communicate 3D printing
- remain readable at small sizes
- avoid generic layered-shape ambiguity
- avoid clipart aesthetics
- avoid finance-style cost iconography

The nozzle + layer stack direction is currently preferred over:
- layers-only concepts
- dollar-sign concepts
- detailed printer illustrations

---

## Android

Android can support:
- adaptive icons
- monochrome themed icons
- launcher-specific treatments
- feature graphics

Potential direction:
- full nozzle icon for launcher
- simplified monochrome layer version for themed icons

---

## iOS

The iOS launcher icon should remain:
- simple
- highly readable
- visually balanced
- recognisable without context

Avoid excessive detail.

---

# Surface Design

## Cards

Move toward layered elevated surfaces.

Desired qualities:
- slightly softer corners
- subtle borders or edge separation
- soft depth
- restrained highlights
- cleaner grouping

Avoid:
- flat grey cards
- harsh shadows
- strong gradients
- glassmorphism

The newer mockups demonstrated that slightly richer surfaces significantly improve perceived quality.

The refresh should intentionally introduce:
- subtle gradients
- layered visual depth
- restrained glow separation
- stronger grouping
- more premium elevation treatment

without becoming visually noisy.

---

## AppSurfaceCard

Status: implemented in `lib/shared/widgets/app_surface_card.dart` and used for support FAQ tiles, batch summary cards, and grouped surfaces.

The refresh should introduce a thin reusable surface wrapper.

Suggested component:

```dart
AppSurfaceCard(
  child: ...,
)
```

This component should own:
- `CARD_BACKGROUND`
- subtle border treatment
- border radius
- standard padding
- optional margin
- child passthrough

The component should NOT own:
- business logic
- calculator-specific behavior
- row/column layout decisions
- form behavior

Use `AppSurfaceCard` for:
- calculator cost summary
- calculator grouped input area
- settings cards
- history teaser card
- support/help cards
- FAQ accordion surfaces
- any grouped card-like UI block

The goal is to prevent ad-hoc card styling across the app.

---

## Modals, Dialogs, and Sheets

Modal surfaces should use the shared surface system rather than default Material colors.

Preferred defaults:
- dialog content surfaces → `CARD_BACKGROUND`
- modal/sheet chrome where visible → `SHELL_BACKGROUND`
- modal separators → `SHELL_BORDER`
- page-level modal backgrounds → `APP_BACKGROUND` only when the modal behaves like a full screen route

Theme configuration should globally cover:
- `dialogTheme`
- `bottomSheetTheme`
- modal bottom sheets where supported
- date/time picker themes if used

Any direct `showDialog` or `showModalBottomSheet` background overrides should be checked during the final inline-color audit.

---

# Typography

## Font Selection

The application should migrate from the default system typography to Inter.

Download:
https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip

Inter was selected because it:
- feels modern without looking trendy
- renders numeric values cleanly
- works well in dense utility interfaces
- supports technical/productivity aesthetics well
- improves perceived design quality immediately
- scales cleanly from labels to large totals

The typography direction should feel:
- technical
- premium
- readable
- restrained
- modern

Avoid decorative or futuristic fonts.

---

## Font Weights

Planned usage:

- Inter Regular
- Inter Medium
- Inter SemiBold
- Inter Bold

---

## Typography Usage Rules

### Regular

Use for:
- helper text
- metadata
- descriptions
- secondary information

---

### Medium

Use for:
- labels
- buttons
- inputs
- navigation items
- standard emphasis

---

### SemiBold

Use for:
- section headers
- grouped card titles
- screen subtitles
- grouped result sections

---

### Bold

Use for:
- total cost values
- primary results
- important statistics
- major emphasis moments

Should be used intentionally and sparingly.

---

## Typography Goals

The refresh should improve:
- hierarchy
- scanability
- readability
- perceived polish
- spacing rhythm
- emphasis clarity

A significant portion of the visual refresh should come from typography improvements alone.

---

# Header Component

## AppScreenHeader

The refresh should use a reusable shared header component. The current direction is for `AppScreenHeader` to act as the full screen header/app bar surface, not just styled title text.

Suggested component:

```dart
AppScreenHeader(
  title: 'Print History',
)
```

Implementation direction:
- `AppScreenHeader` may implement `PreferredSizeWidget` if used directly as a `Scaffold.appBar`
- it should own the full header bar area
- it should not be limited to title text rendering

This component should become the default top-level screen header throughout the application.

The goal is to centralise:
- title styling
- typography rules
- spacing
- color emphasis
- alignment
- trailing actions
- subtitle support

into a single reusable implementation.

---

## Header Typography Direction

Headers should feel:
- cleaner
- more premium
- more intentional
- less like default Flutter app bars

The header styling should become part of the application's visual identity.

Potential characteristics:
- larger typography
- stronger spacing
- reduced visual clutter
- less default Material styling
- more custom visual rhythm

---

## Header Color Rules

The header component should automatically apply title color emphasis rules.

### Single Word Titles

Single-word titles should render entirely in `LIGHT_BLUE`.

Examples:
- `Calculator`
- `Materials`
- `Printers`
- `Settings`

This creates stronger visual identity without awkward color splitting.

---

### Multi-Word Titles

Multi-word titles should transition from darker/off-white text into `LIGHT_BLUE` emphasis.

The final semantic word should generally receive the accent color.

Examples:
- `Print History`
- `Batch Costing`
- `Material Settings`
- `Power Usage`

Expected behavior:
- earlier words use off-white
- final/important word uses `LIGHT_BLUE`

This creates a more natural visual flow and stronger emphasis hierarchy.

---

## Special Cases

Longer titles may bias emphasis toward the final important semantic word.

Example:
- `3D Print Calculator`

Potential rendering:
- `3D Print` → off-white
- `Calculator` → `LIGHT_BLUE`

The emphasis should feel intentional rather than mechanically split.

---

## Header Component Responsibilities

The shared header component should eventually support:
- optional subtitle
- optional trailing actions
- optional leading actions
- animated transitions
- page-level consistency
- spacing standardisation
- responsive sizing

Avoid per-screen custom header styling where possible.

The goal is to make the header component part of the application's core visual identity.


## Goals

Improve hierarchy and readability.

Current UI is functional but visually flat.

Focus on:
- stronger section titles
- larger totals
- more spacing rhythm
- cleaner grouping
- better contrast between labels and values

---

## Typography Direction

Labels:
- smaller
- lower contrast
- secondary emphasis

Values:
- larger
- clearer
- stronger visual weight

Totals:
- dominant
- immediately scannable
- LIGHT_BLUE emphasis acceptable

---

# Calculator / Results Screen

## This Is The Anchor Screen

The calculator/results flow should become the primary design reference for the entire app.

Most other screens should inherit:
- card styling
- spacing
- typography
- buttons
- icon treatment
- navigation behavior

The goal is to redesign a single high-quality screen and allow the rest of the application to inherit naturally.

---

# Input Section Direction

Inputs should feel:
- cleaner
- grouped
- intentional
- easier to scan

Potential direction:
- grouped sections
- icon + label rows
- stronger spacing
- less raw form-field appearance

Avoid introducing interaction complexity.

The app remains data-entry heavy.

The calculator input fields should sit inside a grouped `AppSurfaceCard` wrapper.

Floating input fields directly on the page background should be avoided because they feel visually disconnected from the refreshed design language.

---

# Result Section Direction

The result section is the primary value moment.

It should:
- visually stand out
- feel premium
- clearly communicate value
- improve scanability

Potential improvements:
- larger total cost presentation
- stronger spacing
- grouped summaries
- clearer category separation
- stronger hierarchy

Avoid overcomplication.

---

# Navigation

## Bottom Navigation

Desired direction:
- darker integrated surface
- stronger active state
- more subtle inactive state
- slightly more refined spacing
- cleaner icons

Implementation notes:
- use `SHELL_BACKGROUND` for the nav container
- apply `SHELL_BORDER` as a top border on the nav wrapper/container
- keep spacing safe-area aware
- avoid a floating/glassmorphism navigation treatment
- centralise styling in an `AppBottomNavigation` or equivalent wrapper when practical

Avoid floating/glassmorphism navigation.

---

# Buttons

The refresh should introduce reusable app button components instead of relying directly on mixed `ElevatedButton`, `OutlinedButton`, `FilledButton`, and `TextButton` usage per screen.

Button styling should be centralised so actions feel consistent across calculator, settings, history, paywall, support, and batch costing flows.

---

## Button Components

Suggested reusable components:

- `AppPrimaryButton`
- `AppSecondaryButton`
- `AppTertiaryButton`

Status: implemented in `lib/shared/widgets/app_buttons.dart` and migrated across batch costing, history, settings, and related dialogs.

These should own:
- colour treatment
- typography
- border radius
- minimum height
- horizontal padding
- disabled state
- loading state if needed
- icon spacing when used with icons

They should NOT own:
- business logic
- navigation logic
- form behavior
- screen-specific layout

---

## Shared Button Rules

All app buttons should share:
- consistent height
- consistent radius
- Inter Medium or SemiBold text treatment
- predictable icon spacing
- accessible tap targets
- clear disabled states

Avoid one-off button styling in individual screens.

---

## Primary Button

Primary buttons are for the main action on a screen or section.

Use for:
- save
- continue
- calculate/recalculate
- upgrade where it is the primary CTA
- confirm actions

Visual treatment:
- filled background
- use `LIGHT_BLUE` as the default fill
- the render direction suggests `#4485F1`, which is close enough to `LIGHT_BLUE` that a new token is not required unless visual testing proves otherwise
- text should be high contrast
- strong but not glossy

Avoid:
- gradients unless deliberately added later as a tokenised style
- oversized shadows
- glossy effects

---

## Secondary Button

Secondary buttons are for visible but lower-priority actions.

Use for:
- reset
- cancel-like alternatives
- secondary navigation actions
- batch costing entry if not the main page action
- preview/sample actions

Visual treatment:
- transparent background
- `LIGHT_BLUE` border
- `LIGHT_BLUE` text
- same height/radius as primary buttons
- lower visual weight than primary

This should replace harsh white-outline buttons where possible.

The calculator reset button is a good candidate for the secondary button style.

---

## Tertiary Button

Tertiary buttons are for low-emphasis actions.

Use for:
- inline actions
- help links
- minor dismiss actions
- low-priority text actions

Visual treatment:
- text only
- `LIGHT_BLUE` text
- no border
- no filled background
- minimal visual weight

---

## Button Implementation Direction

Initial implementation should:
- create the reusable button components
- migrate obvious low-risk usages first
- avoid changing workflows
- avoid redesigning entire screens at the same time

Priority candidates:
- calculator reset button → `AppSecondaryButton`
- calculator save button → `AppPrimaryButton`
- batch costing entry button → likely `AppSecondaryButton` unless it becomes the main CTA
- support/contact button → `AppPrimaryButton` or `AppSecondaryButton` depending on screen context
- low-emphasis links/actions → `AppTertiaryButton`


The goal is to test the button system in practice before applying it everywhere.

---

# Chips & Badges

The refresh should introduce reusable chip and badge components instead of relying on default Material chip styling.

The Materials screen is the first clear use case.

Current filter chips feel too close to default form controls and should be refined to match the new surface language.

---

## Component Split

Filter chips and stock badges should be separate reusable components.

Suggested components:

- `AppFilterChip`
- `StockStatusBadge`

They may share internal styling primitives, but they represent different semantics:

- filter chips are interactive controls
- stock badges are informational status indicators

Avoid creating one overloaded component that handles both jobs.

---

## AppFilterChip

Status: implemented in `lib/shared/widgets/app_filter_chip.dart` and used in batch costing source filters.

Used for:
- material type filters
- stock state filters
- future segmented filtering/grouping controls

Inactive state:
- visually recedes
- uses a filled muted surface
- uses `CARD_BACKGROUND` or a very close derived surface color
- uses subtle border treatment, likely `BORDER_SUBTLE`
- uses muted/off-white text
- avoids dominant white outlines

Active state:
- clearly selected
- visually connects to the refreshed blue accent system
- uses `LIGHT_BLUE` as the primary accent reference
- may use a subtle blue tint/fill
- may use stronger text/icon contrast
- should not become neon or glossy

The component should preserve compact readability without feeling cramped.

---

## Shared Search Bar

Status: implemented in `lib/shared/widgets/app_search_bar.dart` and reused by history plus materials search surfaces.

The shared search bar should own:
- compact outlined/underlined search treatment consistent with the app theme
- shared clear-button behavior
- optional labels and hints
- consistent search icon treatment

It should stay a thin wrapper around `TextField`/`TextFormField`-style inputs rather than owning page-specific filtering logic.

---

## StockStatusBadge

Used for:
- `In stock`
- `Low stock`
- `Out of stock`

These badges are informational, not interactive.

They should be visually distinct from filter chips.

### In Stock

Visual direction:
- restrained green tinted surface
- subtle border
- readable green text
- premium/tooling feel rather than game-style saturation

### Low Stock

Visual direction:
- muted amber/orange tinted surface
- amber/orange text
- subtle border
- noticeable but restrained

### Out Of Stock

Visual direction:
- muted/dimmed surface
- low-emphasis text
- should immediately communicate reduced availability

---

## Shared Chip/Badge Rules

Both chip and badge components should:
- use Inter typography
- share the radius system
- align with the card/surface hierarchy
- avoid hardcoded one-off styling
- avoid oversized padding
- remain compact but readable

Avoid:
- default Material chip styling
- harsh white borders
- glossy effects
- neon fills
- ad-hoc per-screen badge colors

---

## Initial Implementation Targets

Priority targets:
- Materials filter chips
- Materials stock status badges

Do not change filtering behavior or stock logic.

This is a visual/component extraction task only.

---

# Segmented Controls

Segmented buttons are used for mutually exclusive mode selection, such as batch-wide vs per-item configuration.

They are not filter chips and should not use `AppFilterChip`.

Theme direction:
- use global `segmentedButtonTheme` where possible
- selected segment should use a muted filled/tinted surface
- unselected segment should remain transparent or close to `APP_BACKGROUND`
- border should use `SHELL_BORDER` or another subtle shared separator token
- text should carry the state clearly
- avoid default Material styling where it clashes with the refreshed UI

Do not add decorative selected icons unless the specific control already requires them semantically.

The goal is a clean mode switch, not a checklist or filter chip.

---

# Icons

## Icon Direction

Icons should feel:
- technical
- geometric
- clean
- consistent
- modern

Potential inspiration:
- blueprint tooling
- printer UI systems
- technical dashboards

Avoid:
- playful icons
- emoji-like visuals
- inconsistent line weights

---

# Motion

## Motion Principles

Animation should be restrained.

Good:
- subtle fades
- small transitions
- count-up totals
- smooth state changes

Bad:
- bouncing
- flashy motion
- excessive parallax
- attention-seeking transitions

---

# Implementation Strategy

## Branch Strategy

The refresh should live on its own dedicated branch.

Suggested branch:

```text
feature/ui-theme-refresh
```

Main should remain focused on:
- batch costing
- feature stability
- release readiness

The UI refresh should progress independently.

---

## Shared Theme First

The refresh should primarily be implemented through:
- theme primitives
- shared surfaces
- shared components
- typography rules
- navigation styling
- inherited visual behavior

The goal is NOT to redesign every screen individually.

The goal is to allow most screens to inherit improvements automatically.

---

## Anchor Screen

The calculator/results screen is the primary reference screen.

This screen should define:
- spacing
- typography
- card treatment
- input styling
- button styling
- grouping behavior
- elevation
- accent usage
- navigation styling

Most of the rest of the application should naturally inherit from this direction.

---

# Shared Components To Extract

Potential reusable components:

- `AppSurfaceCard` — thin reusable surface wrapper for cards, accordions, grouped inputs, settings sections, and support panels
- `CalculatorInputRow`
- `CostSummaryCard`
- `AppPrimaryButton` — filled primary CTA using the refreshed blue action treatment
- `AppSecondaryButton` — transparent outlined button with blue border/text
- `AppTertiaryButton` — text-only low-emphasis action button
- `AppFilterChip` — reusable interactive filter chip for material/stock filters
- `StockStatusBadge` — reusable informational status badge for stock state display
- `AppSegmentedControl` or global `segmentedButtonTheme` — mutually exclusive mode selection styling
## Key Reminder

# Final Technical Pass

Before considering the refresh complete, do a focused technical cleanup pass.

Check for:
- inline `Color(...)` usage that should be a shared token
- `Colors.white`, `Colors.white54`, and similar defaults that should use `OFF_WHITE`, `MUTED_BLUE_GREY`, or semantic text/icon tokens
- remaining `DEEP_BLUE` / `DARK_BLUE` usages that should now be `APP_BACKGROUND`, `CARD_BACKGROUND`, `SHELL_BACKGROUND`, or `RESULT_SURFACE`
- direct button styling that should use `AppPrimaryButton`, `AppSecondaryButton`, or `AppTertiaryButton`
- direct card/container decoration that should use `AppSurfaceCard`
- modal/dialog background overrides that should be handled through theme tokens
- duplicated chip/status styling that should use `AppFilterChip` or `StockStatusBadge`

This pass should not change UX flows.

It is only to remove visual drift and hardcoded styling.

---
- `AppBottomNavigation`
- `SectionHeader`
- `AppMetricRow`

Goal:
- allow screens to inherit improvements automatically
- reduce redesign duplication
- minimise UI drift

---

# Design System Audit Backlog

Latest audit pass found the refresh foundation is in place, but the app still has several style gaps where widgets bypass shared tokens or hardcode visual values inline.

The biggest remaining issue is not the base palette itself.

The biggest remaining issue is missing semantic tokens layered on top of the base palette.

`app_colors.dart` now covers the core brand/surface colors well, but the app still needs shared semantic tokens for:
- text emphasis levels
- icon emphasis levels
- subtle borders/dividers
- overlay/scrim surfaces
- status colors
- destructive/warning/success/info treatments

Without those semantic tokens, refreshed screens still fall back to `Colors.white*`, `Colors.red`, `Colors.green`, `Colors.orange`, `Colors.amber`, and raw `Color.fromRGBO(...)` values.

---

## Highest-Priority Cleanup Targets

### 1. Duplicate Raw Palette Values

These should be converted to shared tokens first because they represent clear design-system drift rather than legitimate one-off styling.

Current duplicate/raw values found:
- `Color.fromRGBO(26, 28, 43, 1)`
  - `lib/materials/csv_import/csv_import_page.dart`
  - `lib/settings/materials/suggestion_typeahead.dart`
  - this should map to an existing shared token, likely `DARK_BLUE`
- `Color.fromRGBO(8, 8, 18, 1)`
  - `lib/shared/components/accordion_menu/accordion_menu.dart`
  - `lib/history/components/history_export_preview_sheet.dart`
  - this should become a named token, likely a preview/export/overlay surface token such as `PREVIEW_SURFACE` or `OVERLAY_SURFACE`
- `Color.fromRGBO(255, 255, 255, 0.04)`
  - `lib/history/components/batch_history_item.dart`
  - this should become a semantic overlay token such as `SURFACE_OVERLAY_SUBTLE`

These are strong candidates because they appear intentional and reusable, not accidental.

---

### 2. Status Colors Are Still Scattered

The audit found many places still using raw status/action colors directly in widgets.

Examples:
- `lib/shared/widgets/stock_status_badge.dart`
- `lib/materials/csv_import/csv_import_page.dart`
- `lib/batch_costing/widgets/batch_import_file_row.dart`
- `lib/calculator/view/components/history_load_warning_banner.dart`
- `lib/materials/widgets/material_card.dart`
- `lib/settings/settings_slidable_item.dart`
- `lib/history/components/history_item_slidable_wrapper.dart`
- `lib/calculator/view/components/materials_selection/material_row.dart`
- `lib/history/components/history_item_actions.dart`
- `lib/app/promo_history_tab_icon.dart`

Recommended semantic tokens to introduce:
- `STATUS_SUCCESS`
- `STATUS_WARNING`
- `STATUS_ERROR`
- `STATUS_INFO`
- `STATUS_NEUTRAL`
- optionally `ACTION_DUPLICATE` if duplicate actions intentionally keep a distinct accent from primary/edit actions

Important:
- destructive actions should not rely on raw `Colors.red`
- warnings should not rely on raw `Colors.amber`
- success states should not rely on raw `Colors.green`
- informational/status badges should come from shared semantic intent tokens

---

### 3. White / Grey Text and Icon Variants Are Hardcoded Too Often

Many refreshed surfaces still use direct Flutter whites instead of shared text/icon tokens.

Recurring values found:
- `Colors.white`
- `Colors.white70`
- `Colors.white60`
- `Colors.white54`
- `Colors.white38`
- `Colors.white24`
- `Colors.white12`

High-signal files include:
- `lib/materials/widgets/material_card.dart`
- `lib/history/components/batch_history_item.dart`
- `lib/history/components/history_item_material_breakdown.dart`
- `lib/calculator/view/calculator_results.dart`
- `lib/materials/csv_import/csv_import_page.dart`
- `lib/materials/widgets/materials_page.dart`
- `lib/app/header_actions.dart`
- `lib/app/app_page.dart`
- `lib/app/app_page_shell_config.dart`
- `lib/history/components/history_teaser.dart`
- `lib/gcode_import/widgets/gcode_import_preview_section.dart`

Recommended semantic tokens to introduce:
- `TEXT_PRIMARY`
- `TEXT_SECONDARY`
- `TEXT_TERTIARY`
- `ICON_PRIMARY`
- `ICON_MUTED`
- `BORDER_SUBTLE`
- `DIVIDER_SUBTLE`

Likely direction:
- `TEXT_PRIMARY` should align with `OFF_WHITE`
- lower emphasis levels should use shared muted values rather than ad-hoc alpha variants in every feature

---

### 4. Overlay / Preview / Scrim Blacks Are Still Hardcoded

Preview surfaces and scrims still use direct black values in a few places.

Examples:
- `lib/gcode_import/widgets/gcode_import_preview_section.dart`
- `lib/gcode_import/widgets/gcode_import_preview_dialog.dart`
- `lib/calculator/view/components/materials_selection/materials_header.dart`

Current raw values include:
- `Colors.black`
- `Colors.black87`
- `Colors.transparent`

Recommended tokens:
- `SCRIM_DARK`
- `PREVIEW_BACKDROP`
- `TRANSPARENT`

Even if these remain visually identical, naming them makes the design language explicit and keeps these treatments discoverable.

---

## Lower-Priority Cleanup

These are less urgent, but still worth addressing after the semantic token pass.

- `lib/shared/theme.dart`
  - `unselectedItemColor: Colors.white54`
  - should eventually route through shared nav/text/icon tokens
- `lib/shared/widgets/app_buttons.dart`
  - uses raw white foreground/loading colors
  - acceptable short-term, but should eventually use shared semantic foreground tokens
- `lib/history/components/history_export_preview_sheet.dart`
  - preview surface still uses raw color token candidate and raw `ElevatedButton.icon`
  - should eventually align with shared surface/button patterns

---

## Recommended Cleanup Order

### Phase A — Expand Shared Tokens

Add semantic color tokens to `lib/shared/app_colors.dart` for:
- text emphasis
- icon emphasis
- subtle borders/dividers
- overlays/scrims
- status/destructive/success/warning/info usage

This is the key missing layer in the current design system.

### Phase B — Replace Duplicate Raw Palette Values

Replace obvious shared-value repeats first:
- repeated dark surfaces
- repeated translucent overlays
- repeated export/preview backgrounds

These are low-risk, high-confidence conversions.

### Phase C — Replace Status Colors

Centralise all destructive, warning, success, and informational colors through shared semantic tokens.

This should cover:
- slide actions
- delete affordances
- warning banners
- import validation states
- stock badges
- teaser/promo highlights

### Phase D — Replace White/Grey Text and Icon Variants

Move all major `Colors.white*` styling to semantic text/icon tokens.

This reduces drift and makes future contrast tuning much easier.

### Phase E — Clean Overlay and Preview Treatments

Move black/transparent preview treatments to named shared tokens.

This is lower priority than status/text cleanup, but still part of finishing the design system coherently.

---

## Architectural Takeaway

The refresh is no longer blocked on reusable components.

The app already has the major primitives in place:
- `AppSurfaceCard`
- shared buttons
- shared search bar
- shared filter chip
- theme-driven inputs

The next coherence step is semantic color centralisation.

In other words:
- base palette layer = mostly done
- reusable component layer = mostly done
- semantic intent layer = still incomplete

That semantic intent layer is what will eliminate the remaining UI drift.

---

# Initial Implementation Priority

## Phase 1

Focus only on:
- calculator/results screen
- shared theme system
- shared reusable components
- navigation styling
- typography cleanup

---

## Phase 2

Expand naturally into:
- settings
- materials
- printers
- history
- premium screens
- batch costing screens

Only manually redesign screens that do not inherit cleanly.

---

# Key Reminder

The application already has strong functional depth.

The goal of this refresh is NOT to make the app flashy.

The goal is to make the app feel:
- cohesive
- intentional
- premium
- trustworthy
- mature
- professional

while preserving clarity and usability.
