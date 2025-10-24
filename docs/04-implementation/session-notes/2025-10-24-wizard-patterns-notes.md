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
  - Call server validators configured in CMDT via `WizardValidationService.validateStep(...)` (semicolon‑separated class names).
  - If last step and valid → submit to Apex orchestration; else advance.
- Rationale: LWC cannot instantiate arbitrary components from strings; router uses explicit template branches (can be code‑generated later).

---


Notes: Validators align with Phase‑1 integrations (KYC/KYB/OFAC via FIS Code Connect; COCC booking via MuleSoft; doc gen/e‑sign later). Use the validator hook for those calls.

---

##  Best‑practice guardrails
- Apex: enforce CRUD/FLS; keep validators stateless; bulkify if validating many; use Named Credentials + MuleSoft; manage endpoints/timeouts in CMDT; tests ≥85%, mock validators; include negative tests (class‑not‑found / wrong‑type).
- LWC: use `@wire` for cacheable reads, imperative for mutations; keep steps small and pure; emit normalized `payloadchange`; accessibility with progress indicator and error summaries; hygiene via ESLint/Prettier + CI.

---

##  Optional enhancements
- Step‑level feature flags via `FeatureFlag__c` on `Wizard_Step__mdt`.
- Role‑based visibility via `RequiredPermission__c`.
- Generated Router: script to emit `<template if:true>` branches from CMDT.
- Data prefill from related records (e.g., Opportunity/Account) for in‑branch.

---

## References
- Examples: `/examples/` → LWC, Apex, Custom Metadata
- ADR: `docs/04-implementation/architecture-decisions/ADR-0001-lwc-architecture.md`
