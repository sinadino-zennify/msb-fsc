# Main Street Bank - Development Backlog

**Last Updated**: 2025-11-05  
**Client**: Main Street bank

---

## 🎯 Active Sprint

### In Progress
- [ ] **ST-002** — Populate Existing Data from Opportunity ([story file](ST-002-populate-existing-data-from-opportunity.md))

### Up Next
- [ ] ST-003 — Additional Applicants Typeahead (depends on ST-002)
- [ ] ST-004 — Persist Draft/Submit
- [ ] ST-005 — Product Rules & Recommendations

---

## 📋 Backlog

- [ ] **Implement Full Persistence Logic**: The current `WizardPersistenceService` only creates an `ApplicationForm` record. All other step handlers (`upsertApplicantStep`, `upsertBusinessStep`, etc.) are stubs. This story tracks the work to implement the actual DML to create/update `Applicant`, `Account`, and other related records from the wizard payloads.
- [ ] **Experience Cloud Compatibility**: Make the `daoWizardContainer` LWC compatible with Experience Cloud. This includes: refactoring Workspace API calls to be environment-aware, updating the component's meta.xml file with community targets, ensuring guest user permissions are handled, and verifying styling works with community themes.

_Track new stories here or link to story files in `docs/02-requirements/`_

---

## ✅ Completed

| ID | Title | Completed Date | Summary |
|----|-------|----------------|---------|
| ST-001 | Wizard Foundation (CMDT + Container/Router + Navigation) | 2025-10-27 | CMDT orchestration, container/router pattern, client-side validation, upsert-on-Next persistence. All components deployed to msb-sbox. |

---

## Notes
- Update this file when stories move state.
- On story completion, add a row to the Completed table with a brief summary.
