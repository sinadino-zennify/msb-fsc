<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md for correct object names
✅ Correct: ApplicationForm, Applicant, Account (Business), FinancialAccount
❌ Wrong: Application__c, Applicant__c, Loan__c, Business_Relationship__c
-->

# Main Street Bank - Getting Started

**Client:** Main Street bank  
**Integration:**   
**Org:** msb-sbox

Welcome to the Main Street Bank Salesforce project! This guide will help you get oriented.

---

## 🎯 What is This Project?

This project implements a **Deposit Account Opening (DAO)** integration for Main Street bank using Salesforce Financial Services Cloud (FSC).

**Goal**: Ingest application data from  and create/update Salesforce records for:
- Business and Person Accounts
- Application Forms
- Applicants
- Products
- Due Diligence
- Financial Accounts (loans/deposits)

---

## 📂 Project Structure

```
Main Street Bank/
│
├── docs/                           ← All documentation
│   ├── 01-foundation/              ← Source of truth documentation
│   │   ├── data-model.md           ← Object names, relationships, ER diagrams
│   │   ├── field-mappings.csv      ← →SF field mappings (USER-MAINTAINED)
│   │   ├── field-mappings.md       ← Field mapping docs & context (AGENT-MAINTAINED)
│   │   └── object-glossary.md      ← Quick reference for objects
│   │
│   ├── 02-requirements/            ← User stories and backlog
│   │   ├── backlog.md              ← Prioritized backlog
│   │   └── ST-*.md                 ← User story files
│   │
│   ├── 03-workflows/               ← External app workflows
│   │
│   ├── 04-implementation/          ← Implementation artifacts
│   │   ├── architecture-decisions/ ← ADRs (why decisions were made)
│   │   ├── session-notes/          ← What's been implemented
│   │   └── *.md                    ← API docs, quickstarts
│   │
│   └── 05-analysis/                ← Analysis reports
│
├── force-app/                      ← Salesforce metadata
│   └── main/default/
│       ├── classes/                ← Apex classes
│       └── objects/                ← Custom objects and fields
│
├── scripts/                        ← Utility scripts
│
├── .cursorrules                    ← AI agent instructions
├── PROJECT.md                      ← Project status tracker
└── package.xml                     ← Salesforce deployment manifest
```

---

## 🚀 Quick Start for Developers

### 1. Setup Your Environment

```bash
# Initialize the project with your details
./init-dao-project.sh

# Authenticate with Salesforce
sf org login web --alias msb-sbox
```

### 2. Review Source of Truth Documents

| What | Where |
|------|-------|
| How agents should work | `/.cursorrules` |
| Project status | `/PROJECT.md` |
| Architecture & reusability patterns | `/docs/01-foundation/ARCHITECTURE.md` |
| Object names & relationships | `/docs/01-foundation/data-model.md` |
| Field mappings | `/docs/01-foundation/field-mappings.csv` (source) + `.md` (context) |
| External app workflows | `/docs/03-workflows/` |

### 3. Deploy Metadata

```bash
# Deploy custom objects
sf project deploy start --source-dir force-app/main/default/objects --target-org msb-sbox
```

### 4. Start Coding

See [Common Tasks](#-common-tasks) below for typical workflows.

---

## 🏗️ Common Tasks

| Task | Workflow |
|------|----------|
| Start new task | 1. Check `/docs/02-requirements/backlog.md`<br>2. Read story in `/docs/02-requirements/`<br>3. **For API work**: Read `/docs/03-workflows/`<br>4. Implement → Test → Deploy |
| Add object/field | 1. Update `/force-app/main/default/objects/`<br>2. Update `/docs/01-foundation/data-model.md`<br>3. Update `package.xml`<br>4. Deploy |
| Add field mapping | 1. **USER**: Update `/docs/01-foundation/field-mappings.csv`<br>2. **AGENT**: Sync `field-mappings.md` to document changes |
| Complete task | 1. Mark complete in story file<br>2. Add notes to `/docs/04-implementation/session-notes/` |

---

## 🧠 Working with AI Agents

> Agents: open `/.cursorrules` before any work. This file is hidden; ensure your IDE search includes hidden files. Agents must explicitly open this file at the start of each session.

This project is optimized for AI-assisted development. The `.cursorrules` file contains comprehensive instructions for agents.

**Key principle**: The CSV file (`field-mappings.csv`) is **USER-MAINTAINED**. Agents read it but never modify it.

---

## 📚 Learn More

- **Architecture Guide**: `/docs/01-foundation/ARCHITECTURE.md`
- **Data Model**: `/docs/01-foundation/data-model.md`
- **API Integration**: `/docs/04-implementation/dao-api-quickstart.md`
- **Architecture Decisions**: `/docs/04-implementation/architecture-decisions/`
- **Examples**: `/examples/zifi-project/` (reference implementation)

---

## ❓ Need Help?

1. Check `/docs/00-START-HERE.md` (this file)
2. Review `/docs/01-foundation/data-model.md` for object relationships
3. Check `/docs/04-implementation/architecture-decisions/` for context
4. Contact the development team

---

**Created**: 2025-01-16  
**Last Updated**: 2025-01-16  
**Maintainer**: Main Street bank Development Team

