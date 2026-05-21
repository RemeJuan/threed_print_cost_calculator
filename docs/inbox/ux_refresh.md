

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
const DARK_BLUE = Color.fromRGBO(26, 28, 43, 1);
const DEEP_BLUE = Color.fromRGBO(13, 13, 23, 1);
const LIGHT_BLUE = Color.fromRGBO(84, 153, 254, 1);
```

These remain the core brand foundation colors.

However, the refresh is NOT limited to only these three colors anymore.

The newer renders demonstrated that the application benefits significantly from a broader supporting palette.

The refresh should introduce a controlled supporting accent spectrum.

---

## DEEP_BLUE

Primary application background.

Use for:
- scaffold backgrounds
- app chrome
- navigation surfaces
- dialogs
- bottom navigation backgrounds
- fullscreen surfaces

Should remain the darkest primary color.

---

## DARK_BLUE

Primary elevated surface color.

Use for:
- cards
- grouped containers
- summary sections
- settings surfaces
- input groups
- bottom sheets
- modal surfaces

Cards should no longer feel visually flat.

Surfaces should feel layered and intentionally grouped.

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

# Typography

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

Avoid floating/glassmorphism navigation.

---

# Buttons

## Primary Actions

Primary CTA buttons should:
- use LIGHT_BLUE
- feel substantial
- have stronger presence
- use cleaner spacing
- avoid excessive rounding

Avoid glossy button styling.

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

# Scope Management

## Important

This refresh should live on a dedicated branch.

Suggested branch:

```text
feature/ui-theme-refresh
```

Main branch should remain focused on feature stability.

The refresh should be implemented as:
- shared components
- reusable theme primitives
- inherited styling improvements

Not:
- isolated one-off screen redesigns

---

# Shared Components To Extract

Potential reusable components:

- `AppSurfaceCard`
- `CalculatorInputRow`
- `CostSummaryCard`
- `PrimaryActionButton`
- `AppBottomNavigation`
- `SectionHeader`
- `AppMetricRow`

Goal:
- allow screens to inherit improvements automatically
- reduce redesign duplication
- minimise UI drift

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
