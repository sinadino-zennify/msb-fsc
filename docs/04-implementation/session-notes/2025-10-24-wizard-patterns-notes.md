<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md for correct object names
✅ Correct: ApplicationForm, Applicant, Account (Business), FinancialAccount
❌ Wrong: Application__c, Applicant__c, Loan__c, Business_Relationship__c
-->

# Session Notes: Wizard Patterns (Container → Router → Steps)

**Date**: 2025-10-24  
**Maintained By**: Main Street bank Development Team

---

## How it all works (flow)
- Container wires to `WizardConfigService.getSteps(wizardApiName)` and shows progress using `StepLabel__c` (or DeveloperName).
- Renders one step at a time through `daoWizardStepRouter`, which chooses the child LWC by `ComponentBundle__c` from CMDT.
- On Next:
  - Call step’s client validate (`reportValidity()` + custom rules via a small public API on each step).
  - Persist via Apex upsert for the active step; surface any DML/CRUD/FLS errors to the UI.
  - If last step and valid → submit to Apex orchestration; else advance.
- Rationale: LWC cannot instantiate arbitrary components from strings; router uses explicit template branches (can be code‑generated later).

---


Notes: Iteration 1 keeps validation client‑side only and performs upsert on Next to catch DML/CRUD/FLS issues early. Server‑side business validators (KYC/KYB/OFAC, etc.) will be reintroduced in a later story behind a pluggable seam.

---

##  Best‑practice guardrails
- Apex: enforce CRUD/FLS; keep validators stateless; bulkify if validating many; tests ≥85%
- LWC: ensure fields being displayed on UI have their correspondent fieldApiName in the backend. see `force-app/main/default/objects` for fieldApiName
- LWC: use `@wire` for cacheable reads, imperative for mutations; keep steps small and pure; emit normalized `payloadchange`; accessibility with progress indicator and error summaries; hygiene via ESLint/Prettier + CI.

---

##  Optional enhancements
- Step‑level feature flags via `FeatureFlag__c` on `Wizard_Step__mdt`.
- Role‑based visibility via `RequiredPermission__c`.
- Generated Router: script to emit `<template if:true>` branches from CMDT.

---

## References
- Examples: `/examples/` → LWC, Apex, Custom Metadata
- ADR: `docs/04-implementation/architecture-decisions/ADR-0001-lwc-architecture.md`
