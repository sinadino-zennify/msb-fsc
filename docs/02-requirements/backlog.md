# Main Street Bank - Development Backlog

**Last Updated**: 2025-11-05  
**Client**: Main Street bank

---

## 🎯 Active Sprint

### In Progress
- [ ] **ST-002** — Persist Application Data ([story file](ST-002-persist-application-data.md))
  - Implement full persistence logic for ApplicationForm, Business Account, Applicant, PersonAccount, and ACRs
  - Handle conditional persistence based on wizard step context
  - Status: Not Started (story created 2025-11-05)

### Up Next
- [ ] **ST-003** — Pre-populate Wizard Data ([story file](ST-003-pre-populate-wizard-data.md))
  - Pre-populate wizard from Opportunity or Account (Business/Person)
  - Supports 3 entry points with field mappings from MSB-24
  - Depends on: ST-002
- [ ] ST-004 — Additional Applicants Typeahead
  - Depends on: ST-003
- [ ] ST-005 — Product Rules & Recommendations

---

## 📋 Backlog

- [ ] **Experience Cloud Compatibility**: Make the `daoWizardContainer` LWC compatible with Experience Cloud. This includes: refactoring Workspace API calls to be environment-aware, updating the component's meta.xml file with community targets, ensuring guest user permissions are handled, and verifying styling works with community themes.
- [ ] **Wizard UI Polish**: Additional UI enhancements beyond high-priority fields (e.g., conditional field visibility, field help text, inline validation messages)

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
