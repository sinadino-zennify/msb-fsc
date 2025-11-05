# Context Manifest (Deterministic List)

## READ FIRST (strict order - MANDATORY FOR ALL TASKS)

- `docs/00-START-HERE.md`
- `docs/01-foundation/` (entire folder)
- `docs/02-requirements/` (entire folder)
- `docs/03-workflows/` (entire folder)
- `docs/04-implementation/` (entire folder - includes all subfolders: architecture-decisions, session-notes, setup-instructions)
- `PROJECT.md`

---

## READ SECOND (if touching Salesforce code or running scripts)

- `force-app/main/` (if change touches Salesforce code)
- `scripts/README.md` (if scripts/CLIs involved)

---

## READ THIRD (tests, examples, deeper analysis)

- `docs/05-analysis/` (entire folder)
- `examples/README.md`
- `examples/apex/`
- `examples/lwc/`
- `examples/custom-metadata/`

---

## DO NOT READ (by default)

- `session-notes/architecture-demo.md`
- Any auto-generated or temporary files

---

## Agent Instructions (repeatable)

1. **ALWAYS** read **READ FIRST** in the order listed (mandatory for all tasks).
2. If the task touches Salesforce code or scripts, also read **READ SECOND**.
3. If the task touches tests/examples/analysis, also read **READ THIRD**.
4. Run the Validation Loop in `docs/ai-context-sequence.md`.
5. Only then produce design → code → tests.

---

## Trigger Phrase

> "Use the AI context manifest."

Agents must interpret this as loading this file **and** `docs/ai-context-sequence.md` before doing anything else.

---

**Last Updated**: 2025-11-05  
**Maintainer**: Main Street Bank Development Team
