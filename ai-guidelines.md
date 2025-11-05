# AI Guidelines (Entrypoint)

**Always load these two files first, in this order:**
1. `docs/ai-context-sequence.md`
2. `docs/context-manifest.md`

**Rules of engagement**
- Do not generate code until you confirm you've read both files.
- Follow the sequencing and validation loop they define.
- If any rule conflicts with a request, halt and ask for clarification.

**Goal**
Ensure every agent (Cursor, Windsurf, Claude, ChatGPT, etc.) reads the same minimal set of docs in a deterministic order.

---

**Trigger Phrase**
> "Use the AI context manifest."

When you see this phrase, immediately load `docs/ai-context-sequence.md` and `docs/context-manifest.md` before proceeding.

---

**Last Updated**: 2025-11-05  
**Maintainer**: Main Street Bank Development Team
