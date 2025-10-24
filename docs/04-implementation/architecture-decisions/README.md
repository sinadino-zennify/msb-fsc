# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for Main Street Bank.

---

## 📋 What are ADRs?

Architecture Decision Records document important architectural decisions made during the project. They provide context for future developers and AI agents about **WHY** decisions were made.

---

## 📚 ADR Index

| ID | Title | Status | Date | Summary |
|----|-------|--------|------|---------|
| ADR-0001 | LWC Architecture for DAO (Main Street Bank) | Accepted | 2025-01-16 | Adopt container-child multi-step LWC architecture with orchestrator and standardized events |

_Add your ADRs here_

---

## ✍️ Creating a New ADR

1. Copy `ADR-TEMPLATE.md`
2. Rename to `ADR-XXXX-short-title.md` (increment number)
3. Fill in all sections
4. Get review/approval from team
5. Update status to "Accepted"
6. Add to index table above

---

## 📖 ADR Format

Each ADR should include:
- **Context**: Why we need to make a decision
- **Decision**: What we decided to do
- **Rationale**: Why we chose this approach (pros/cons/alternatives)
- **Consequences**: What becomes easier/harder
- **Implementation**: How to implement the decision

---

## 🔍 Using ADRs

**For Developers:**
- Read ADRs before starting work on related components
- Reference ADR numbers in code comments
- Update ADRs if you find issues with decisions

**For AI Agents:**
- **CRITICAL**: Read ADRs in pre-work checklist
- ADRs explain WHY things are done certain ways
- Never contradict an accepted ADR without consulting user

---

**Maintained By**: Main Street bank Development Team  
**Review**: Quarterly or when major decisions needed

