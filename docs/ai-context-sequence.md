# AI Context Sequence

Read in this exact order—top to bottom. Summarize each tier before proceeding.

---

## Tier 1 — Global & Foundations (MUST READ - ALWAYS)

1. `docs/rules/` (entire folder - **CRITICAL**: apex-rules.md, dev-rules.md, general-rules.md, lwc-rules.md, mobile-rules.md)
2. `docs/00-START-HERE.md`
3. `docs/01-foundation/` (entire folder)
4. `docs/02-requirements/` (entire folder)
5. `docs/03-workflows/` (entire folder)
6. `docs/04-implementation/` (entire folder - includes ADRs, session notes, setup instructions)
7. `PROJECT.md`

**Extract**
- **Salesforce development rules** (Apex, LWC, mobile, general dev practices)
- Project objectives & non-negotiables
- Domain concepts & constraints
- Naming/structure conventions visible in docs
- Acceptance criteria and backlog scope
- Process flows, component boundaries, API contracts
- Error-handling, security, and performance notes
- Implementation decisions (ADRs) & session notes

---

## Tier 2 — Code & Scripts (IF TOUCHING SALESFORCE CODE OR RUNNING SCRIPTS)

7. `force-app/main/` (Salesforce code & metadata)
8. `scripts/README.md` (if running scripts)

**Extract**
- Existing code patterns and implementations
- Metadata structure and relationships

---

## Tier 3 — Analysis & Examples (REFERENCE WHEN TESTING OR DESIGNING)

9. `docs/05-analysis/` (entire folder)
10. `examples/README.md`
11. `examples/apex`, `examples/lwc`, `examples/custom-metadata` (as relevant)

**Extract**
- Known pitfalls, tradeoffs, performance notes
- Example patterns to mimic or avoid

---

## Exclusions (unless explicitly requested)

- `session-notes/*` (root-level historical notes)
- Any auto-generated or temporary files

---

## Validation Loop (MANDATORY before output)

1. Check requested change against Tier 1 constraints.
2. If logic/UI/API touched, re-check Tier 2 docs (ADRs, session notes).
3. Ensure examples/tests align with Tier 3 guidance.
4. If any mismatch, revise or ask for clarification.

---

## Output Protocol

- **First**, list which files you read (paths).
- **Summarize** the constraints you extracted (bulleted).
- **Propose** a design in 3–7 bullets.
- **Generate** code (small, reviewable diffs).
- **Provide** test plan + usage notes.
- **Provide** toggle/rollback instructions when applicable.

If any step is blocked by missing context, **halt** and specify what's missing.

---

**Last Updated**: 2025-11-05  
**Maintainer**: Main Street Bank Development Team
