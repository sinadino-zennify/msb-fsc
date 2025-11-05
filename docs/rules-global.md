# Main Street Bank Salesforce Project - AI Agent Rules

**Version**: 2.0  
**Last Updated**: 2025-11-05  
**Single Source of Truth**: This file contains global, IDE-agnostic rules for all AI agents

---

## 🎯 Project Objective (Phase 1)

**Goal**: Build LWC-based screens and supporting backend infrastructure to guide Salesforce users through the complete deposit account opening process.

**Outcomes (Phase 1)**:
- Create intuitive LWC screens for each step of the account opening process
- Build Apex services to support the LWC workflows and business logic
- Implement data validation, state management, and workflow navigation
- Optional: Integrate with external applications for data ingestion
- Lifecycle: Account Creation → Application Form → Applicant Details → Product Selection → Collateral Entry → Review & Submit → Account Funding

**Why this order**: We need user-friendly interfaces that guide users through the complex deposit account opening process, with robust backend services supporting the workflow.

---

## 🔴 MANDATORY PRE-WORK CHECKLIST

Complete EVERY time before starting ANY task:

1. **READ** `/docs/rules/` (entire folder) - **CRITICAL** Salesforce development rules:
   - `apex-rules.md` - Apex coding standards, governor limits, security, testing
   - `dev-rules.md` - Application development, permissions, integrations
   - `general-rules.md` - General Salesforce development requirements
   - `lwc-rules.md` - Lightning Web Component architecture and best practices
   - `mobile-rules.md` - Mobile LWC development requirements
2. **READ** `/docs/00-START-HERE.md` - Project orientation and quick start
3. **READ** `/docs/01-foundation/` (entire folder) - Including:
   - `ARCHITECTURE.md` - **CRITICAL** for wizard reusability patterns
   - `data-model.md` - **SOURCE OF TRUTH** for object names and relationships
4. **READ** `/docs/02-requirements/` (entire folder) - Including:
   - `backlog.md` - Current and planned work items
   - All story files - Story context and Tasks/Sub-Tasks
5. **READ** `/docs/03-workflows/` (entire folder) - **CRITICAL** for process flows and component boundaries
6. **READ** `/docs/04-implementation/` (entire folder) - **CRITICAL** including:
   - `architecture-decisions/` - Why decisions were made (ADRs)
   - `session-notes/` - What has been implemented and lessons learned
   - `setup-instructions/` - Environment and deployment setup
7. **READ** `/PROJECT.md` - Active scope and overview
8. **SCAN** `force-app/main/default/objects/` - Check existing objects/fields (verify API names)
9. **REVIEW** `docs/05-analysis/` - Check latest analysis reports for current state
10. **REVIEW** `/examples/` - Non-deployable reference patterns (LWC, Apex, CMDT)
11. **CONFIRM** All context is loaded before proceeding

**⚠️ CRITICAL**: If you cannot access ANY of these files/folders, STOP and ask the user.

---

## 📋 Correct Object Names (FSC) - NON-NEGOTIABLE

### ✅ Use These Names (Canonical):

| Logical Name | Object Type | API Name | Notes |
|--------------|-------------|----------|-------|
| **ApplicationForm** | FSC | `ApplicationForm` | Loan/deposit application |
| **Applicant** | FSC | `Applicant` | Individual applicants |
| **Account** (Business) | Standard | `Account` | Business accounts (RecordType) |
| **Account** (PersonAccount) | Standard | `Account` | Individual accounts (RecordType) |
| **FinancialAccount** | FSC | `FinServ__FinancialAccount__c` | Loan/financial account |
| **FinancialAccountRole** | FSC | `FinServ__FinancialAccountRole__c` | Account roles on financial accounts |
| **ApplicationFormProduct** | FSC | `ApplicationFormProduct` | Products on applications |
| **Product2** | Standard | `Product2` | Loan products |
| **Due_Diligence__c** | Custom | `Due_Diligence__c` | Compliance tracking |
| **Assigned_Products__c** | Custom | `Assigned_Products__c` | Applicant-Product junction |
| **Collateral__c** | Custom | `Collateral__c` | Collateral items |
| **Collateral_Owner__c** | Custom | `Collateral_Owner__c` | Collateral ownership |
| **Collateral_Association__c** | Custom | `Collateral_Association__c` | Collateral-Account association |
| **Collateral_Assessment__c** | Custom | `Collateral_Assessment__c` | Collateral valuations |
| **Task** | Standard | `Task` | Checklist items |

### ❌ NEVER Use These Incorrect Names:

- ~~`Application__c`~~ → Use `ApplicationForm`
- ~~`Application`~~ (without Form) → Use `ApplicationForm`
- ~~`Loan__c`~~ → Use `FinServ__FinancialAccount__c` or `FinancialAccount`
- ~~`Business_Relationship__c`~~ → Use `Account` (Business)
- ~~`Checklist__c`~~ → Use `Task`
- ~~`Checklist_Item__c`~~ → Use `Task`
- ~~Custom `Applicant__c`~~ → It's an FSC object, use `Applicant`

### 🔑 External ID Field Names:

**Integration:**

| Object | Field API Name | Purpose |
|--------|----------------|---------|
| ApplicationForm | `DAOApplicationId__c` | Application ID |
| Applicant | `DAOApplicantId__c` | Applicant ID |
| Account | `DAOBusinessId__c` | Business ID |

**⚠️ CRITICAL**: Always verify API names in `force-app/main/default/objects/` before coding.

---

## 📝 Standard Operating Procedure

Always follow these steps in order:

1. **PICK** a single backlog item from `/docs/02-requirements/backlog.md`
2. **READ** the matching story file in `/docs/02-requirements/` if applicable
3. **VERIFY** object/field names in `/docs/01-foundation/data-model.md` and `force-app/main/default/objects/`
4. **REVIEW** `docs/05-analysis/` for current implementation status
5. **IMPLEMENT** with minimal diffs; follow naming already in repo
6. **TEST** Add/adjust tests; ensure bulkification (200+ records) and CRUD/FLS
7. **DOCUMENT** If objects/fields changed:
   - Update `/docs/01-foundation/data-model.md`
   - Add session notes to `/docs/04-implementation/session-notes/`
8. **PACKAGE** Create metadata entries in `package.xml` for each new component
9. **DEPLOY** Deploy to target org and verify
10. **FINALIZE** Mark task complete in story file

---

## ✅ Task Tracking Protocol (MANDATORY)

- **Every story must include** a `Tasks and Sub-Tasks` section with actionable checkboxes.
- **Before coding:** Review the story's Tasks/Sub-Tasks. If missing or unclear, add/clarify them in the story file under `docs/02-requirements/`.
- **During work:** Update Task/Sub-Task checkboxes as progress is made. Keep them in sync with actual work.
- **On completion:** Ensure all Tasks/Sub-Tasks are checked or explicitly deferred with a note in the story.
- **Transparency:** Prefer small updates to the story over vague session notes; session notes should summarize highlights and decisions.

---

## 📄 File Creation Rules (MANDATORY)

### For Documentation Files (.md):

```markdown
<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md for correct object names
✅ Correct: ApplicationForm, Applicant, Account (Business), FinancialAccount
❌ Wrong: Application__c, Applicant__c, Loan__c, Business_Relationship__c
-->

# [Title]
```

### For Apex Classes (.cls):

```java
/**
 * @description [Description]
 * 
 * DATA MODEL: Uses ApplicationForm, Applicant, Account, FinancialAccount
 * See /docs/01-foundation/data-model.md for complete data model
 * 
 * @author [Author]
 * @date YYYY-MM-DD
 */
public class ClassName {
    // ...
}
```

### File Types Requiring Headers:
- ✅ All .md files in `/docs/`
- ✅ All .cls (Apex classes)
- ✅ All README files
- ✅ All implementation/progress documents
- ✅ All session summaries

**NO EXCEPTIONS**: Creating a file without the appropriate header is incomplete work.

---

## 🧪 Testing Requirements

- All Apex tests must be ≥85% coverage
- Tests must be bulkified (200+ records)
- Follow test patterns in existing test classes
- Minimal test data in setup method
- Minimal assertions per test
- No DML in test methods outside of `Test.startTest()` / `Test.stopTest()`

---

## 📦 Deployment Requirements

- Update `package.xml` for ALL new components
- Deploy to target org: `sf project deploy start --source-dir [path] --target-org msb-sbox`
- Verify deployment success before marking task complete
- Update documentation after successful deployment
- Document any deployment issues in `/docs/04-implementation/session-notes/`

---

## 🎯 Code Quality Standards

- Use `with sharing` for security (unless specific reason not to)
- Check CRUD/FLS permissions before DML operations
- Bulkify all DML operations (handle 200+ records)
- Handle exceptions gracefully with try-catch
- Add meaningful debug statements for troubleshooting
- Follow existing code patterns in the repo
- Use descriptive variable names
- Add inline comments for complex logic

---

## 🏗️ Enterprise Patterns (fflib-apex-common)

When applicable, follow enterprise patterns:

- **Domain Pattern**: Business logic in Domain classes (extend `fflib_SObjectDomain`)
- **Selector Pattern**: SOQL queries in Selector classes (extend `fflib_SObjectSelector`)
- **Service Pattern**: Complex operations in Service classes
- **Unit of Work**: Use for transaction management and bulkification
- **Trigger Pattern**: Triggers only delegate to Domain classes (no business logic)

**Note**: Not all classes require fflib patterns. Use judgment based on complexity.

---

## 🔍 Definition of Done

Before marking a task complete:

- [ ] Apex code is bulkified and handles 200+ records
- [ ] CRUD/FLS enforced where applicable
- [ ] Tests written/updated with ≥85% coverage on touched classes
- [ ] Metadata added to `package.xml` for all new components
- [ ] Deployed successfully to target org
- [ ] If schema changed:
  - [ ] Updated `/docs/01-foundation/data-model.md`
  - [ ] Session notes added to `/docs/04-implementation/session-notes/` (if significant work)
- [ ] Updated story file with completion status

---

## 📊 Available Reports (docs/05-analysis/)

Before starting any task, review these for current state:

- `metadata-audit-reports/` - Metadata inventory and gap analysis
- Check for implementation tracking and coverage summaries

---

## 🏷️ Work Item Prefixes

Use these prefixes in commits and documentation:

- **LWC-** = Lightning Web Components (UI screens, user experience)
- **SVC-** = Apex Services (business logic, validation, orchestration)
- **DM-** = Data Model (objects/fields/ER updates)
- **ING-** = Ingestion (parser, mapper, upsert services, tests)
- **API-** = API Development (REST endpoints, authentication, integration)
- **SEC-** = Security (FLS/CRUD, PII handling, permissions)
- **DOC-** = Documentation (ER/ADRs)

---

## 🌿 Git Workflow & Branching Strategy

**MANDATORY**: All new features and bug fixes must be developed on dedicated branches.

### Branch Naming Convention

Use descriptive, kebab-case branch names with prefixes:

- **`feature/[description]`** — For new features (e.g., `feature/add-collateral-validation`)
- **`bugfix/[description]`** — For bug fixes (e.g., `bugfix/fix-applicant-lookup`)
- **`hotfix/[description]`** — For urgent production fixes (e.g., `hotfix/security-patch`)
- **`docs/[description]`** — For documentation-only changes (e.g., `docs/update-adr-index`)

### Branch Workflow

1. **Create Branch**: Always create a feature branch from `main` (or your default branch)
   ```bash
   git checkout -b feature/your-feature-description
   ```

2. **Document Purpose**: In your first commit or PR, include:
   - What the feature/fix does
   - Why it's needed
   - Rollback plan if something goes wrong

3. **Commit Often**: Make small, logical commits with descriptive messages
   ```bash
   git commit -m "feat: Add validation for collateral amount field"
   ```

4. **Pull Request**: When ready, create a PR using the template in `.github/pull_request_template.md`

5. **Merge**: Only merge after:
   - [ ] Tests pass
   - [ ] Code review complete (if applicable)
   - [ ] Documentation updated
   - [ ] Deployed to sandbox and verified

### Rollback Strategy

Every branch/PR must document how to roll back:

**Option 1: Revert the merge commit**
```bash
git revert -m 1 <merge-commit-hash>
```

**Option 2: Revert specific commit(s)**
```bash
git revert <commit-hash>
```

**Option 3: Redeploy previous tag**
```bash
git checkout <previous-tag>
sf project deploy start --source-dir force-app --target-org msb-sbox
```

### Commit Message Format

Follow conventional commits:

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **refactor**: Code refactoring (no functional change)
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

Example: `feat(wizard): Add handler map pattern to persistence service`

---

## 🚫 Guardrails (Do NOT do these)

- Do NOT commit directly to `main` branch - always use feature branches
- Do NOT create overlapping objects/fields - search `force-app/main/default/objects/` first
- Do NOT invent answers to open questions - ask the user
- Do NOT build non-essential automation in Phase 1
- Do NOT commit PII to logs, debug statements, or sample files
- Do NOT use incorrect object names (Loan__c, Business_Relationship__c, etc.)

---

## 🔒 Invariants (Do NOT break these)

- Use FSC objects where they exist; create customs only for separation of concerns
- Every FinancialAccount (loan) must link to an Account and identify Applicants via FinancialAccountRole
- Use External ID fields for idempotent upserts (DAOApplicationId__c, etc.)
- PII fields (SSN, DOB) must be protected with FLS and encryption
- ApplicationForm is the master record for applications; Applicant is master-detail to ApplicationForm

---

## 📂 File Hierarchy (Quick Reference)

**AI Guidelines**: `/ai-guidelines.md` (entrypoint for all agents)  
**Context Sequence**: `/docs/ai-context-sequence.md` (ordered read sequence)  
**Context Manifest**: `/docs/context-manifest.md` (file list)  
**Global Rules**: `/docs/rules-global.md` (this file)  
**Getting Started**: `/docs/00-START-HERE.md`  
**Project Status**: `/PROJECT.md`  
**Architecture**: `/docs/01-foundation/ARCHITECTURE.md`  
**Data Model**: `/docs/01-foundation/data-model.md`  
**Requirements**: `/docs/02-requirements/`  
**Architecture Decisions**: `/docs/04-implementation/architecture-decisions/` (ADRs)  
**Session Notes**: `/docs/04-implementation/session-notes/`  
**Object Metadata**: `/force-app/main/default/objects/`  
**Analysis Reports**: `/docs/05-analysis/`

---

**Last Updated**: 2025-11-05  
**Review**: Every sprint  
**Maintainer**: Main Street bank Development Team
