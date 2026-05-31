# Store Metadata Rewrite: Free/Premium Alignment

**Limits per `docs/app_store_metadata_rules.md` — single source of truth.**
**Proposed copy below is draft-quality. Tighten to canonical limits before replacing metadata files.**

---

## Proposed Android Description

3D Print Cost Calculator helps makers and small print businesses calculate the real cost of every print before they quote, sell, or start a job.

Most makers only calculate filament cost. Real print costs also include electricity, printer power usage, failed prints, labour, setup time, and business overhead.

Use it to cost prints with confidence, protect your margins, and keep pricing consistent.

Built for hobbyists, makers, side hustles, and small print businesses.

### Free features

• Core print costing
• Electricity costing
• Multi-material costing
• Single-print G-code import
• Up to 5 saved materials (manual management)
• Up to 2 printer profiles
• Up to 7 history entries
• Individual job export
• Manual batch costing for up to 3 items
• Offline-first operation

Calculate real jobs, save core data, review recent work, and cost small batches without an account or subscription.

### Premium features

Premium is for higher volume work, faster workflows, and business pricing tools.

Unlock:

• Unlimited materials
• Unlimited printer profiles
• Unlimited history
• Full and bulk export
• Batch G-code import
• Faster batch setup from G-code files
• Unlimited batch costing
• Labour pricing
• Failure risk cost modelling
• Markup support
• Setup fees
• Rounding rules
• Detailed cost breakdowns
• Material import
• Filament inventory and remaining spool tracking
• Advanced configuration

### Why makers use it

• Solve the real pricing problem, not only filament math
• Quote more consistently across repeat jobs
• Handle both simple jobs and more advanced business workflows
• Keep your data on your device
• Work without accounts, cloud lock-in, or forced sync

### Privacy-first

No accounts
No cloud dependency
No tracking requirement
Your app data stays on your device


---

## Proposed Apple Description

Know your print costs before you quote.

3D Print Cost Calculator helps makers and small print businesses calculate accurate 3D printing costs using more than filament alone. Include electricity, printer power usage, failed prints, labour, setup time, and business overhead in one clear workflow.

Use it to cost jobs consistently, protect margins, and move faster from estimate to price.

Built for hobbyists, makers, side hustles, and small print businesses.

Free includes:

• Core print costing
• Electricity costing
• Multi-material costing
• Single-print G-code import
• Up to 5 saved materials (manual management)
• Up to 2 printer profiles
• Up to 7 history entries
• Individual job export
• Manual batch costing for up to 3 items
• Offline-first operation

Free is designed to be genuinely useful. You can cost real prints, save key data, review recent jobs, and handle small manual batches without needing an account.

Premium adds tools for scale, pricing control, and faster workflows:

• Unlimited materials
• Unlimited printer profiles
• Unlimited history
• Full and bulk export
• Batch G-code import
• Faster batch setup from G-code files
• Unlimited batch costing
• Labour pricing
• Failure risk cost modelling
• Markup support
• Setup fees
• Rounding rules
• Detailed cost breakdowns
• Material import
• Filament inventory and remaining spool tracking
• Advanced configuration

Privacy-first by design:

• No accounts
• No cloud dependency
• No required tracking
• Your data stays on your device

Designed to stay simple on the surface while remaining accurate underneath.

---

## Proposed Android Changelog

Expanded the free plan.

* Multi-material costing is now available to all users
* Single-print G-code import is now included on Free
* Save up to 5 materials, 2 printer profiles, and 7 history entries on Free
* Manual batch costing is available for up to 3 items per batch
* Premium now focuses on advanced pricing tools, batch workflows, inventory tracking, exports, and unlimited usage

---

## Proposed Apple What's New

Expanded the free plan.

• Multi-material costing is now available to all users
• Single-print G-code import is now included on Free
• Save up to 5 materials, 2 printer profiles, and 7 history entries on Free
• Manual batch costing is available for up to 3 items per batch
• Premium now focuses on advanced pricing tools, batch workflows, inventory tracking, exports, and unlimited usage

---

## Short Rationale

- Reframed Free as useful without defensive wording. Current copy still reads like core value sits behind Premium.
- Made pricing problem main message. Current copy mentions features first, problem second.
- Fixed feature ownership. Current metadata marks several now-free features as Premium-only.
- Replaced vague upsell lines like "client-ready pricing" with concrete Premium tools.
- Increased privacy/offline emphasis. Strong differentiator. Fits current product.
- Kept Android slightly more ASO-shaped. Kept Apple cleaner, less keyword-heavy, same positioning.

---

## Outdated / Inconsistent Metadata Found

- "Material stock tracking with automatic updates" shown as Free. Current product: manual material management is Free, but material import and stock/remaining filament tracking are Premium.
- "Multi-material print support" shown as Premium. Current product: Free.
- "G-code import for faster setup" shown as Premium. Current product: single-print G-code import Free; batch G-code import Premium.
- "Batch costing for multiple prints" shown as Premium. Current product: manual batch costing Free up to 3 items.
- "Save and review print history" shown as Premium. Current product: Free up to 7 entries.
- "Multiple printer profiles" shown as Premium. Current product: Free up to 2 printer profiles.
- "Currency formatting" mentioned. Risky/outdated for store promise.
- Free list too thin. Makes app look like demo.

### Current Apple description
- Same core issues as Android:
  - stock tracking incorrectly free (manual material management is Free, but stock tracking remains Premium)
  - multi-material incorrectly premium
  - G-code import incorrectly premium-only
  - batch costing incorrectly premium-only
  - history incorrectly premium-only
  - printer profiles framed too narrowly as premium
  - currency formatting claim likely outdated/misaligned
- "For makers who sell prints…" section good intent, but feature mapping no longer accurate.

### Current Android changelog
- Entirely centered on "Batch costing is here for Pro users".
- Outdated against current model.
- Misses biggest customer-facing change: expanded Free plan.

### Current Apple release notes
- Same problem as Android changelog.
- Still frames batch costing as Pro-only instead of split workflow.

---

## Metadata Items That Should Also Be Updated

- Android short description
- Apple subtitle
- Apple promotional text
- Screenshot captions on both stores
- Feature graphic / Play promo art copy
- App preview video text overlays, if any
- First 3 screenshots especially — likely still too premium-gated
- Any comparison graphics showing Premium as "unlock everything"
- In-app paywall marketing copy for consistency with store text
- Premium comparison table and downgrade messaging
- "What's New" announcement copy if it still uses old premium framing
- Store listing keywords / keyword field review for Apple
- Any website / landing page copy that mirrors old store text
- Support / FAQ upgrade comparison table if public-facing

## Recommended Screenshot / Caption Positioning

Keep screenshot captions short for localization. Avoid long claims and compound sentences.

- Screenshot 1: True print cost
- Screenshot 2: Not just filament
- Screenshot 3: Import G-code
- Screenshot 4: Batch costing
- Screenshot 5: Pricing tools
- Screenshot 6: Offline first

Alternative short caption set:

- Screenshot 1: Calculate true cost
- Screenshot 2: Track key costs
- Screenshot 3: Import G-code
- Screenshot 4: Cost small batches
- Screenshot 5: Price with control
- Screenshot 6: Private by design

---

ClickUp Task: (pending)
Next steps:
- Verify Play Store and App Store character limits against `docs/app_store_metadata_rules.md`.
- Tighten proposal copy to character limits before replacing metadata files.
- Update paywall copy to match the new Free/Premium model.
- Review downgrade messaging and over-cap behaviour.
- Review screenshot captions before regeneration and localization.
