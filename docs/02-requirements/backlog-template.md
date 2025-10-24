# Main Street Bank - Development Backlog

**Last Updated**: 2025-01-16  
**Project**:  Integration  
**Client**: Main Street bank

---

## 🎯 Active Sprint

### In Progress
- [ ] **[LWC-001]** Create application flow container component
- [ ] **[SVC-001]** Build DAOApplicationService for workflow management
- [ ] **[DM-001]** Define data model and relationships

### Up Next
- [ ] **[LWC-002]** Build applicant details entry screen
- [ ] **[SVC-002]** Build DAOValidationService for data validation
- [ ] **[FLOW-001]** Implement screen navigation logic

---

## 📋 Backlog

### Phase 1: Foundation (LWC + Backend Services)

**LWC Components**
- [ ] **[LWC-001]** Create application flow container component
- [ ] **[LWC-002]** Build applicant details entry screen
- [ ] **[LWC-003]** Build product selection interface
- [ ] **[LWC-004]** Build collateral entry screen
- [ ] **[LWC-005]** Build review and submit screen
- [ ] **[LWC-006]** Build application status dashboard

**Apex Services**
- [ ] **[SVC-001]** Build DAOApplicationService for workflow management
- [ ] **[SVC-002]** Build DAOValidationService for data validation
- [ ] **[SVC-003]** Build DAOWorkflowService for state management
- [ ] **[SVC-004]** Build DAOProductService for product selection logic

**Data Model**
- [ ] **[DM-001]** Define object relationships and ER diagram
- [ ] **[DM-002]** Create custom fields for external IDs
- [ ] **[DM-003]** Validate FSC object usage

**Screen Flow Logic**
- [ ] **[FLOW-001]** Implement screen navigation logic
- [ ] **[FLOW-002]** Build state management for multi-step flow
- [ ] **[FLOW-003]** Implement progress tracking
- [ ] **[FLOW-004]** Add save/resume functionality

**Testing**
- [ ] **[SEC-001]** Implement CRUD/FLS checks
- [ ] **[SEC-002]** Add PII encryption
- [ ] **[SEC-003]** Test bulkification (200+ records)

### Phase 2: Integration (Optional)

**API Integration**
- [ ] **[API-001]** Implement REST endpoint (`/dao/application`)
- [ ] **[API-002]** Build request payload DTOs
- [ ] **[API-003]** Build response structure
- [ ] **[API-004]** Add authentication and security

**Mappings**
- [ ] **[MAP-001]** Complete field mappings CSV
- [ ] **[MAP-002]** Document special handling rules
- [ ] **[MAP-003]** Validate data types and formats

---

## 📌 Completed

_Track completed items here_

---

## 🏷️ Work Item Prefixes

- **LWC-** = Lightning Web Components (UI screens, workflows, user experience)
- **SVC-** = Apex Services (business logic, validation, workflow management)
- **FLOW-** = Screen Flow Logic (navigation, state management, user journey)
- **DM-** = Data Model (objects/fields/ER updates)
- **MAP-** = Mappings (external→SF field map & rules)
- **ING-** = Ingestion (parser, mapper, upsert services, tests)
- **API-** = API Development (REST endpoints, authentication, integration)
- **SEC-** = Security (FLS/CRUD, PII handling, permissions)
- **DOC-** = Documentation (ER/mappings/ADRs)

---

**Maintained By**: Development Team  
**Review Frequency**: Weekly

