---
name: r8-analyzer
description: Analyzes Android R8 and ProGuard keep rules for redundant, overly broad, and subsumed rules. Use when optimizing Android app size, removing redundant R8 keep rules, or troubleshooting ProGuard configurations.
license: Apache-2.0; derived from android/skills performance/r8-analyzer (Google LLC)
metadata:
  author: Google LLC; adapted for this project
  source: https://github.com/android/skills/tree/main/performance/r8-analyzer
  last-updated: '2026-08-05'
---

# R8 Analyzer

> Adapted from `android/skills` by Google LLC under Apache-2.0. See [LICENSE.txt](LICENSE.txt).
> Project adaptation: supports Flutter projects with an `android/` Gradle module; normal agent output is allowed. Modified files carry this notice.

## Scope

- Research and recommendations only. Do not modify build files or keep rules unless the user separately requests changes.
- First verify the project has an Android Gradle module. For Flutter, inspect `android/` and run Gradle commands from that directory.
- Use a temporary `tmp/r8analysis` directory beneath the Android Gradle project. Do not commit generated artifacts.

## Step 1. Setup and configuration check

- Inspect `build.gradle`, `build.gradle.kts`, `gradle.properties`, and `libs.versions.toml` when present.
- Use [references/CONFIGURATION.md](references/CONFIGURATION.md) to identify missing optimizations.
- If AGP is below 9.0, recommend upgrade for build-time optimization.
- Verify `android.enableR8.fullMode=false` is absent from `gradle.properties`.

## Step 2. Analysis path selection

- Determine the R8 version from Gradle configuration.
- R8 9.3.7-dev or later: use **Path A — Quantitative**.
- Older R8 or unavailable quantitative prerequisites: use **Path B — Heuristic**.

### Path A — Quantitative

- Require Python and the `protobuf` package.
- Follow [references/CONFIGURATION-ANALYZER.md](references/CONFIGURATION-ANALYZER.md) to produce the configuration analyzer protobuf, JSON, and `analysis_result.txt`.
- Use the generated `analysis_result.txt` for scores and rule impact metrics.
- The linked reference has commands rooted at the Gradle project. For this Flutter project, run them from `android/` and adapt paths accordingly.

### Path B — Heuristic

- Inspect project keep-rule files.
- Compare candidate rules with [references/REDUNDANT-RULES.md](references/REDUNDANT-RULES.md). Recommend **Remove** only for rules demonstrably covered by library consumer rules.
- Use [references/KEEP-RULES-IMPACT-HIERARCHY.md](references/KEEP-RULES-IMPACT-HIERARCHY.md) and [references/REFLECTION-GUIDE.md](references/REFLECTION-GUIDE.md) to rank broad rules and identify reflection requirements. Recommend **Refine** for broad rules.
- Recommend Macrobenchmark coverage using [UI Automator](references/android/training/testing/other-components/ui-automator.md) before applying a proposed change.

## Step 3. Report

- Follow [references/REPORT_FORMAT.md](references/REPORT_FORMAT.md).
- Use generated metrics for Path A; use inspected evidence for Path B.
- Omit report sections with no findings.
- State assumptions and unavailable evidence. Do not claim quantitative scores without generated analyzer output.

## Constraints

- Do not remove keep rules merely because they look redundant; preserve rules required by reflection, native code, serialization, or optional dependencies.
- Do not explain generic R8 benefits. Focus on concrete project findings and validation needed.
