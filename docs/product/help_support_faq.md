## Support
- Website: https://printcostcalc.app
- Support email: 3d@printcostcalc.app
- Support ID: Provided in-app (from `premiumStateProvider`)
- Roadmap: Opens `https://printcostcalc.app/roadmap` in browser
- App version: Exposed via `SettingsVersionTapTarget`

When contacting support, include:
- Support ID
- App version
- Short description of the issue

Support card quick link:
- Roadmap (`View what’s coming`)

---

## Short FAQs

**What weight should I enter?**  
Enter the *total spool weight* (e.g. 1kg, 750g). The app calculates per-gram cost from this.

**Why does electricity matter?**
Long prints and high-wattage printers can significantly impact cost. Ignoring this leads to underpricing.

**How is failure risk calculated?**  
Risk % is applied only to *base print costs* (filament + electricity). It models expected loss from failed prints.

**What is labour / processing time?**  
Time spent preparing, cleaning, post-processing, or monitoring prints. This is optional but critical for pricing services.

**What is markup?**  
Markup is a percentage added on top of total cost to generate a selling price. It accounts for profit, overhead, and business margin.

**What is a setup fee?**  
A fixed cost added per job (e.g. machine prep, calibration, admin). Useful for small prints where time overhead dominates.

**Why are my totals changing unexpectedly?**  
Common causes:
- Switching materials with different cost/weight
- Changing printer wattage or electricity rate
- Risk or labour settings enabled/disabled

**Why is my cost lower than expected?**  
Check:
- Electricity rate (kWh)
- Printer wattage
- Labour not included
- Risk % set to 0

**Why is my cost higher than expected?**  
Check:
- High risk %
- High labour rate
- Expensive material profile

---

## Links
- Website: https://printcostcalc.app
- Privacy policy: https://printcostcalc.app/privacy.html
- Terms: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
- X / Twitter: https://x.com/PrintCostCalc
- Instagram: https://www.instagram.com/3dprintcostcalculator
- Mastodon: https://mastodon.social/@printcostcalc

---

## About
3D Print Cost Calculator is a local-first tool designed to help makers and small print businesses accurately price prints.

Key principles:
- No accounts
- No cloud sync
- No tracking
- All data stored locally on device

The calculator combines:
- Filament cost
- Electricity usage
- Failure risk modelling
- Labour and processing time
- Optional pricing (markup, setup fees)

This ensures pricing reflects *true cost*, not just material spend, helping avoid underpricing and improving sustainability of print work.

---

## Notes for Future Expansion
- Pricing model deep-dive (markup, rounding rules)
- Client-facing quote explanation
- Material management guidance
- G-code import explanation
