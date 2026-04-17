---
description: Upgrade Dart/Flutter packages in two phases: compatible updates first, then major updates with validation
agent: build
---

Upgrade project dependencies in a safe, staged way.

Goals:
- Apply patch and minor updates first
- Validate the project after compatible upgrades
- Then handle major updates carefully
- Fix breakages and validate again
- Prefer small, safe changes over aggressive bulk churn

Instructions:

1. Inspect the current dependency state.
   - Run `dart pub outdated`
   - Identify direct dependencies that are out of date
   - Separate:
     - compatible upgrades
     - major upgrades

2. Phase 1: compatible upgrades only.
   - Run `dart pub upgrade`
   - Do not start major upgrades yet
   - Review what changed in `pubspec.lock` and any workspace/package files

3. Validate after Phase 1.
   - Run the normal project validation steps
   - Prefer this order unless the repo defines another:
     - dependency fetch if needed
     - code generation if used
     - formatter if needed
     - analyzer
     - tests
   - If validation fails, fix only issues introduced by the compatible upgrades
   - Re-run validation until green or clearly blocked

4. Re-check upgrade state.
   - Run `dart pub outdated` again
   - Identify remaining major-version candidates

5. Phase 2: major upgrades.
   - Do not blindly upgrade everything and then hope for the best
   - Prefer upgrading direct major dependencies one at a time or in small related batches
   - For each major dependency or batch:
     - update the dependency constraint as needed
     - run `dart pub upgrade --major-versions`
     - inspect changelog or migration impact if needed
     - fix breaking changes in code
     - run analyzer and tests before proceeding

6. Validation after majors.
   - Run the full project validation again
   - Ensure the final state is clean and working

7. Output summary:
   - compatible upgrades applied
   - major upgrades applied
   - breaking changes fixed
   - validation steps run
   - anything still blocked or needing manual review

Rules:
- Prefer upgrading direct dependencies before chasing transitive ones
- Do not change unrelated code
- Do not rewrite architecture just to satisfy a dependency upgrade
- If a major upgrade causes broad churn or uncertain behavior, stop and report instead of forcing it through
- If the repo has a workspace, respect workspace-wide dependency resolution
- Follow AGENTS.md if it defines the exact validation commands