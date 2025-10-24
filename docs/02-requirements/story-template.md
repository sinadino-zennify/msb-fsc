<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md for correct object names
✅ Correct: ApplicationForm, Applicant, Account (Business), FinancialAccount
❌ Wrong: Application__c, Applicant__c, Loan__c, Business_Relationship__c
-->

# ST-XXX: [Story Title]

**Story ID**: ST-XXX  
**Work Item**: [DM-XXX, API-XXX, etc.]  
**Status**: Not Started | In Progress | Completed  
**Created**: YYYY-MM-DD  
**Last Updated**: YYYY-MM-DD

---

## 📋 Story Overview

**As a** [user role]  
**I want** [functionality]  
**So that** [business value]

---

## 🎯 Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## 🔧 Technical Implementation

### Objects Involved
- ApplicationForm
- Applicant
- Account (Business/PersonAccount)

### Fields Required
- `Field1__c`
- `Field2__c`

### Apex Classes
- `ServiceClass.cls`
- `ServiceClassTest.cls`

---

## 📊 Field Mappings

Reference: `/docs/01-foundation/field-mappings.csv`

|  Field | Salesforce Field | Notes |
|------------------------------|------------------|-------|
| field_name | Object__c.Field__c | Special handling |

---

## 🧪 Testing Requirements

- [ ] Unit tests with ≥85% coverage
- [ ] Bulkification test (200+ records)
- [ ] CRUD/FLS validation
- [ ] PII encryption verified

---

## 📦 Deployment

- [ ] Metadata added to `package.xml`
- [ ] Deployed to msb-sbox
- [ ] Verified in org

---

## 📝 Implementation Notes

_Add notes during implementation_

---

## ✅ Definition of Done

- [ ] Code implemented and tested
- [ ] Documentation updated
- [ ] Deployed to org
- [ ] Acceptance criteria met
- [ ] Session notes added

---

**Assigned To**: [Developer Name]  
**Related Stories**: [ST-XXX, ST-YYY]

