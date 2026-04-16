---
description: Update CHANGELOG.md from git tags by comparing the latest documented version to the newest newer tag
agent: build
---

Update `CHANGELOG.md` using released versions only.

Goals:
- Use git tags as the source of truth
- Only add a changelog entry when a newer tag exists than the latest version already documented in `CHANGELOG.md`
- Generate the entry from the diff between those two tags
- Keep the changelog user-facing and free of internal noise

Instructions:

1. Read `CHANGELOG.md` and identify the latest version already documented.
   - Prefer the topmost version entry.
   - Extract only the version number, for example `2.5.2`.
   - Ignore any build metadata suffix such as `+1` when comparing versions.
   - Normalize versions to their base release form before any comparison or output.

2. Inspect git tags.
   - Find whether a newer tag exists than the latest documented version.
   - Use version-aware sorting, not simple string sorting.
   - Treat tags with or without a leading `v` as equivalent when comparing versions.
   - Group tags by their base release version, so `2.5.2+1` and `2.5.2+2` both belong to `2.5.2`.

3. If no newer tag exists:
   - Do not modify `CHANGELOG.md`.
   - Report that the changelog is already up to date.

4. If a newer tag exists:
   - Select:
      - previous version = latest version already documented in `CHANGELOG.md`
      - new version = newest git tag that is newer than the documented version
      - changelog heading version = the new version with any build metadata removed
   - Generate the changelog content from the changes between those two tags only.

5. Analyse the changes between the two tags.
   - Review commit subjects and, where needed, inspect changed files for context.
   - Focus only on user-visible impact.

6. Include:
   - new features
   - user-visible improvements
   - bug fixes with user impact
   - settings or UI changes users would notice
   - behavior changes that affect app usage

7. Exclude:
   - refactors with no user-visible effect
   - internal tooling
   - CI/CD
   - logging
   - analytics
   - tests
   - dependency or maintenance work unless it clearly changed user experience

8. Write the new changelog entry in the existing `CHANGELOG.md` style.
   - Preserve the existing structure if the file already has one.
   - If no clear structure exists, use:

## [x.y.z] - YYYY-MM-DD

### Added
- ...

### Changed
- ...

### Fixed
- ...

9. Writing rules:
   - user-facing
   - concise
   - slightly more descriptive than store notes
   - no implementation details unless needed for user clarity
   - group related items together
   - do not invent features or claim impact that is not supported by the diff

10. Placement:
    - Insert the new version entry at the top of the changelog entries
    - Do not overwrite previous history

11. Version formatting:
    - Never write build metadata in the changelog heading.
    - If the selected git tag is `2.7.0+3`, the heading must be `## [2.7.0] - YYYY-MM-DD`.
    - Build metadata may only affect which commits are included, not the displayed version.

12. Final output:
    - state the documented version found
    - state the newer tag selected
    - state the git range used
    - state whether `CHANGELOG.md` was updated

Execution guidance:
- Prefer checking tags first before doing deeper analysis.
- If multiple newer tags exist, only generate the next missing top entry for the newest tag.
- If the diff is too noisy to safely infer user-facing changes, produce a conservative entry and explicitly say what was uncertain.
- If the latest documented version in `CHANGELOG.md` does not have a matching git tag, stop and report the mismatch instead of guessing.
