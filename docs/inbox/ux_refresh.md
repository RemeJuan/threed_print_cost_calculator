# UX Refresh Direction

## Goal

Modernise the application UI to better align with the updated branding, launch assets, iconography, and overall product positioning.

The app should feel:
- professional
- engineering-focused
- modern
- trustworthy
- data-driven
- premium without being flashy

The refresh is intended to evolve the existing application rather than redesign it completely.

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

# Core Color Palette

## Existing Brand Colors

```dart
const DARK_BLUE = Color.fromRGBO(26, 28, 43, 1);
const DEEP_BLUE = Color.fromRGBO(13, 13, 23, 1);
const LIGHT_BLUE = Color.fromRGBO(84, 153, 254, 1);
```

---

# Color Usage Rules

## DEEP_BLUE

Primary application background.

Use for:
- scaffold backgrounds
- navigation backgrounds
- dialogs
- bottom navigation surfaces
- app chrome

Should create depth and contrast.

---

## DARK_BLUE

Primary elevated surface color.

Use for:
- cards
- grouped content sections
- input containers
- sheets
- summary panels
- settings sections

Should be subtle and restrained.

Avoid heavy gradients.

---

## LIGHT_BLUE

Primary accent color.

Use for:
- active states
- CTA buttons
- focused inputs
- active navigation items
- important totals
- icons
- highlights
- emphasis text

Should remain the dominant accent color throughout the application.

Avoid introducing many additional accent colors.

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
