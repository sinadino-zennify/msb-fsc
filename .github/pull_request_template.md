# Pull Request

## Summary
<!-- What changed? Why? Be specific and concise. -->

---

## Context Ingestion (required)
<!-- Confirm you followed the AI context loading process -->

### Files Read
<!-- List the exact file paths you read, in order -->
- [ ] `ai-guidelines.md`
- [ ] `docs/ai-context-sequence.md`
- [ ] `docs/context-manifest.md`
- [ ] `docs/rules-global.md`
- [ ] Additional files: _(list below)_

### Constraints Extracted
<!-- Bulleted list of key constraints that informed your work -->
- 
- 
- 

---

## Design
<!-- Key decisions in 3–7 bullets -->
- 
- 
- 

---

## Branch Information
<!-- Required for all feature branches -->

**Branch Name**: `feature/[description]` or `bugfix/[description]`  
**Feature Description**: <!-- Brief description of what this branch implements -->  
**Rollback Plan**: <!-- How to revert if needed (e.g., merge revert PR, git revert commit hash, redeploy previous tag) -->

---

## Tests
<!-- What tests were added/updated? -->

### Test Cases
- 
- 

### Coverage Note
<!-- Confirm ≥85% coverage on touched classes -->
- [ ] Tests pass locally
- [ ] Coverage verified (≥85% on modified classes)

---

## Feature Flag / Rollback
<!-- How can this be toggled off or rolled back? -->

**Flag Name & Default**: <!-- e.g., `enableNewWizardStep` (default: false) -->  
**Revert Plan**: <!-- e.g., PR #123 or git tag v1.2.3 -->

---

## Deployment Notes
<!-- Any special deployment considerations? -->

- [ ] Updated `package.xml` for new components
- [ ] Deployed to sandbox: <!-- Org name and deploy ID -->
- [ ] Updated documentation (if schema/architecture changed)

---

## Checklist

- [ ] Followed `docs/ai-context-sequence.md` Validation Loop
- [ ] Read all required context files listed in `docs/context-manifest.md`
- [ ] Updated examples/tests as needed
- [ ] Security & performance considered
- [ ] Branch created with descriptive name (`feature/` or `bugfix/` prefix)
- [ ] Rollback plan documented above
- [ ] No PII committed to logs or sample files
- [ ] Verified canonical object names (ApplicationForm, Applicant, etc.)

---

**Created**: <!-- Date -->  
**Author**: <!-- Name/Handle -->
