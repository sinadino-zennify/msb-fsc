<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md for correct object names
✅ Correct: ApplicationForm, Applicant, Account (Business), FinancialAccount
❌ Wrong: Application__c, Applicant__c, Loan__c, Business_Relationship__c
-->

# ST-001: Wizard Foundation (CMDT + Container/Router + Navigation)

**Story ID**: ST-001  
**Work Item**: LWC-001, SVC-001, SVC-002, DM-001  
**Status**: Not Started  
**Created**: 2025-10-24  
**Last Updated**: 2025-10-24

---

## 📋 Story Overview

**As a** Salesforce user completing Deposit Account Opening (DAO)  
**I want** a multi-step guided wizard that renders steps in the correct order and validates input  
**So that** I can complete applications consistently with proper navigation, validation, and orchestration

---

## 🎯 Acceptance Criteria

- [ ] CMDT exists to orchestrate wizard steps
  - `Wizard_Step__mdt` with fields: `WizardApiName__c`, `Order__c`, `ComponentBundle__c`, `StepLabel__c`, `ValidatorClasses__c`, `Skippable__c`, `HelpText__c`
  - At least 3 records for a sample wizard (e.g., DAO_Business_InBranch: Applicant, Product, Review)
- [ ] Container LWC renders a progress indicator and active step via a router child
  - Container: `daoWizardContainer`
  - Router: `daoWizardStepRouter`
  - Progress shows step labels from CMDT (`StepLabel__c` or DeveloperName)
- [ ] Navigation implemented: Previous, Next, Save & Exit
  - Next triggers client-side validate from step + optional server-side validators from CMDT
  - Save & Exit emits an event with current step
- [ ] Conditional rendering of child LWCs works via router
  - Router chooses child by `ComponentBundle__c` and exposes `validate()`
- [ ] Step sequence honors CMDT `Order__c`
- [ ] Supporting Apex implemented
  - `WizardConfigService.getSteps(wizardApiName)` (cacheable) returns ordered DTOs
  - `WizardValidationService.validateStep(...)` runs pluggable validators (semicolon-separated class names)
  - Example validator `OfacNameScreeningValidator` implemented as stub
- [ ] Unit tests ≥85% coverage on Apex
- [ ] Deployed to `msb-sbox` and verified in App Builder

---

## 🛠️ Tasks and Sub-Tasks

- [ ] Define Custom Metadata Type `Wizard_Step__mdt`
  - [ ] Create CMDT object metadata with required fields (`WizardApiName__c`, `Order__c`, `ComponentBundle__c`, `StepLabel__c`, `ValidatorClasses__c`, `Skippable__c`, `HelpText__c`)
  - [ ] Add sample records for `DAO_Business_InBranch` (Applicant, Product, Review)
  - [ ] Add CMDT to `package.xml` (or ensure wildcard covers CMDT) and deploy
  - [ ] Verify via SOQL that records are retrievable and ordered by `Order__c`

- [ ] Implement Apex: `WizardConfigService`
  - [ ] Create `WizardStepDTO` and `getSteps(wizardApiName)` with `@AuraEnabled(cacheable=true)`
  - [ ] SOQL orders by `Order__c`; maps fields to DTO; returns list
  - [ ] Unit tests for ordering, labeling defaulting, and null/blank inputs

- [ ] Implement Apex: `WizardValidationService` + example validator
  - [ ] Define `WizardValidator` interface and `ValidationResponse`
  - [ ] Implement `validateStep(...)` to iterate semicolon-separated class names
  - [ ] Implement `OfacNameScreeningValidator` stub (example)
  - [ ] Unit tests including negative cases (class not found / wrong type)

- [ ] Scaffold LWCs (container, router, steps)
  - [ ] `daoWizardContainer` with progress indicator, event handlers, `lwc:ref` access to child
  - [ ] `daoWizardStepRouter` with explicit conditional branches per `ComponentBundle__c` and `@api validate()` pass-through
  - [ ] Minimal step shells: `applicantDetails`, `productSelection`, `reviewAndSubmit` with `validate()` and `payloadchange`

- [ ] Implement navigation & validation wiring
  - [ ] Previous/Next handlers, Save & Exit event
  - [ ] Client-side validation by invoking child `validate()`
  - [ ] Server-side validation using CMDT-provided `ValidatorClasses__c`

- [ ] Sequence and progress UI
  - [ ] Use `WizardConfigService.getSteps` results to set order and labels
  - [ ] Progress indicator reflects current and upcoming steps

- [ ] App Builder wiring
  - [ ] Expose container to App Page; set `wizardApiName`
  - [ ] Verify rendering and step transitions in org

- [ ] Documentation & notes
  - [ ] Update `docs/04-implementation/session-notes/` with progress and lessons
  - [ ] Ensure `/examples/` remain in sync with implemented pattern

- [ ] Deployment & verification
  - [ ] Update `package.xml` as needed
  - [ ] Deploy to `msb-sbox` and validate in UI

---

## 🔧 Technical Implementation

### Objects Involved
- ApplicationForm (FSC) – downstream orchestration target (no schema changes in this story)
- Custom Metadata Types – `Wizard_Step__mdt`

### Fields Required (Wizard_Step__mdt)
- `WizardApiName__c` (Text, Required)
- `Order__c` (Number, Required)
- `ComponentBundle__c` (Text, Required)
- `StepLabel__c` (Text)
- `ValidatorClasses__c` (Text)
- `Skippable__c` (Checkbox, default false)
- `HelpText__c` (Long Text)

### Apex Classes
- `WizardConfigService.cls`
- `WizardValidationService.cls`
- `OfacNameScreeningValidator.cls` (example stub)
- Tests: `WizardConfigServiceTest.cls`, `WizardValidationServiceTest.cls`, `OfacNameScreeningValidatorTest.cls`

### LWC Components
- `daoWizardContainer` (container: progress, routing, navigation, save/exit)
- `daoWizardStepRouter` (router: conditional rendering, pass-through `validate()`)
- Step examples/scaffolds: `applicantDetails`, `productSelection`, `reviewAndSubmit` (minimal shells with `validate()` and `payloadchange`)

### Notes
- Use `@AuraEnabled(cacheable=true)` for `getSteps` (supports `@wire` in LWC)
- Prefer imperative Apex for validate/mutation calls
- Router branches are explicit `<template if:true>` blocks; can be code-generated later

---

## 🧪 Testing Requirements

- [ ] Apex unit tests ≥85% coverage across new classes
- [ ] Negative tests for validator resolution (class not found / wrong type)
- [ ] LWC tests for navigation state and router rendering (at least smoke tests)

---

## 📦 Deployment

- [ ] Add CMDT object/records, Apex classes, and LWCs to [package.xml](cci:7://file:///Users/cristianosinadino/Workspace/Salesforce/Pro/zennify/msb/package.xml:0:0-0:0)
- [ ] Deploy to `msb-sbox`
- [ ] Verify container on an App Page with `wizardApiName = DAO_Business_InBranch`

---

## 📝 Implementation Notes

- Examples for CMDT, Apex services, and LWCs are available under [/examples/](cci:7://file:///Users/cristianosinadino/Workspace/Salesforce/Pro/zennify/msb/examples:0:0-0:0)
- ADR reference: [docs/04-implementation/architecture-decisions/ADR-0001-lwc-architecture.md](cci:7://file:///Users/cristianosinadino/Workspace/Salesforce/Pro/zennify/msb/docs/04-implementation/architecture-decisions/ADR-0001-lwc-architecture.md:0:0-0:0)

---

## ✅ Definition of Done

- [ ] CMDT defined and sample records in place
- [ ] Container + Router LWCs functional with Next/Prev/Save & Exit
- [ ] Router renders correct child by `ComponentBundle__c` and honors `Order__c`
- [ ] Server validators invoked from CMDT list
- [ ] Tests and deployment complete
- [ ] Session notes added under [docs/04-implementation/session-notes/](cci:7://file:///Users/cristianosinadino/Workspace/Salesforce/Pro/zennify/msb/docs/04-implementation/session-notes:0:0-0:0)

---

**Assigned To**: [Developer Name]  
**Related Stories**: [ST-002 (e.g., Persist Draft/Submit), ST-003 (e.g., Product Rules)]