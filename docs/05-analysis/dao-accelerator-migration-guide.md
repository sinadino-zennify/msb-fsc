# DAO-AI-Accelerator → MSB: Migration Guide

**Purpose**: Step-by-step guide to migrate DAO-AI-Accelerator to the MSB approach  
**Date**: 2025-11-06  
**Status**: Recommended

---

## Overview

This guide helps you migrate the DAO-AI-Accelerator repository to use the superior MSB AI context system and architecture patterns.

**Migration Time**: ~2-4 hours  
**Difficulty**: Medium  
**Breaking Changes**: Yes (.cursorrules → modular system)

---

## Pre-Migration Checklist

- [ ] Backup current DAO-AI-Accelerator repository
- [ ] Review [dao-accelerator-comparison.md](./dao-accelerator-comparison.md)
- [ ] Ensure git working directory is clean
- [ ] Create migration branch: `git checkout -b feature/msb-migration`

---

## Phase 1: Add MSB AI Context Files

### 1.1 Create Context System Files

Copy these files from MSB to DAO-AI-Accelerator root `docs/`:

```bash
# From MSB docs/ to DAO-AI-Accelerator docs/
cp msb/docs/ai-context-sequence.md dao-accelerator/docs/
cp msb/docs/context-manifest.md dao-accelerator/docs/
cp msb/docs/rules-global.md dao-accelerator/docs/
```

### 1.2 Create Modular Rules Folder

```bash
# Create rules folder
mkdir -p dao-accelerator/docs/rules/

# Copy modular rules
cp msb/docs/rules/apex-rules.md dao-accelerator/docs/rules/
cp msb/docs/rules/lwc-rules.md dao-accelerator/docs/rules/
cp msb/docs/rules/mobile-rules.md dao-accelerator/docs/rules/
cp msb/docs/rules/dev-rules.md dao-accelerator/docs/rules/
cp msb/docs/rules/general-rules.md dao-accelerator/docs/rules/
```

### 1.3 Update ai-context-sequence.md

Replace placeholders in `ai-context-sequence.md`:

```markdown
# Before:
**Maintainer**: Main Street Bank Development Team

# After:
**Maintainer**: DAO Accelerator Team
```

Update file paths if needed to match DAO-AI-Accelerator structure.

### 1.4 Update context-manifest.md

Same updates as above - replace placeholder names.

### 1.5 Update rules-global.md

1. Replace "Main Street Bank" with "{{PROJECT_NAME}}"
2. Keep template variables for project-specific content
3. Verify object names match your project (or keep generic)

---

## Phase 2: Reorganize Examples

### 2.1 Restructure Examples Folder

```bash
cd dao-accelerator/examples/

# Create organized structure
mkdir -p apex/ lwc/ custom-metadata/

# Move zifi-project if it exists
# (Keep as reference implementation)

# Create README
cat > README.md << 'EOF'
# Examples

Non-deployable reference patterns and implementations.

## Structure

- `apex/` - Apex code patterns and examples
- `lwc/` - Lightning Web Component examples
- `custom-metadata/` - Custom metadata type examples
- `zifi-project/` - Complete reference implementation (if exists)

## Usage

These examples are for reference only and should not be deployed to orgs.
Use them as templates for your own implementations.
EOF
```

### 2.2 Add Pattern Examples (Optional)

If you have reusable patterns, organize them:

```bash
examples/
├── README.md
├── apex/
│   ├── service-pattern-example.cls
│   └── selector-pattern-example.cls
├── lwc/
│   ├── wizard-step-example/
│   └── data-table-example/
└── custom-metadata/
    └── wizard-step-mdt-example.xml
```

---

## Phase 3: Add Architecture Documentation

### 3.1 Copy ARCHITECTURE.md

```bash
# If DAO-AI-Accelerator doesn't have detailed architecture doc
cp msb/docs/01-foundation/ARCHITECTURE.md dao-accelerator/docs/01-foundation/

# Edit to remove MSB-specific wizard details if not applicable
# Or keep if you want to adopt metadata-driven wizard pattern
```

### 3.2 Create ADR Structure

```bash
cd dao-accelerator/docs/04-implementation/

# Create architecture-decisions folder if not exists
mkdir -p architecture-decisions/

# Copy ADR template
cp msb/docs/04-implementation/architecture-decisions/ADR-TEMPLATE.md \
   dao-accelerator/docs/04-implementation/architecture-decisions/

# Create README
cat > architecture-decisions/README.md << 'EOF'
# Architecture Decision Records (ADRs)

This directory contains architecture decisions made for this project.

## ADR Index

- [ADR-TEMPLATE](./ADR-TEMPLATE.md) - Template for new ADRs

## How to Create an ADR

1. Copy ADR-TEMPLATE.md
2. Rename to ADR-XXXX-description.md
3. Fill in sections
4. Update this index
5. Commit with PR

## Status Definitions

- **Accepted**: Decision is approved and active
- **Proposed**: Under review
- **Deprecated**: No longer applicable
- **Superseded**: Replaced by newer ADR
EOF
```

---

## Phase 4: Deprecate .cursorrules

### 4.1 Rename (Don't Delete Yet)

```bash
# Keep for reference during transition
mv .cursorrules .cursorrules.deprecated

# Add deprecation notice
cat > .cursorrules << 'EOF'
# ⚠️ DEPRECATED - DO NOT USE

This file has been deprecated in favor of the new modular AI context system.

## New System (Use Instead)

1. Read: `docs/ai-context-sequence.md` - Loading protocol
2. Read: `docs/context-manifest.md` - File manifest  
3. Read: `docs/rules-global.md` - Global rules
4. Read: `docs/rules/` - Modular rules by concern

## Why Deprecated?

- IDE-specific (Cursor only)
- Monolithic (400+ lines)
- Hard to maintain
- Not scalable

## Trigger Phrase

Instead of relying on .cursorrules, tell your AI:

> "Use the AI context manifest"

This works with ANY AI tool (Cursor, Windsurf, GitHub Copilot, etc.)

---

**Migration Date**: YYYY-MM-DD  
**Old File**: Kept as .cursorrules.deprecated for reference
EOF
```

### 4.2 Update README.md

Update the main README to reflect new system:

```markdown
## 🤖 AI-Optimized Development

This accelerator uses an **IDE-agnostic AI context system** that works with any AI tool.

### How It Works

1. **ai-context-sequence.md** - Defines tier-based context loading
2. **context-manifest.md** - Lists all context files in order
3. **rules-global.md** - Global, IDE-agnostic rules
4. **rules/** folder - Modular rules (Apex, LWC, Mobile, Dev, General)

### Getting Started with AI

Tell your AI agent:

> "Use the AI context manifest"

The agent will:
1. Load `docs/ai-context-sequence.md`
2. Read `docs/context-manifest.md`
3. Load context in tiers (Foundation → Code → Analysis)
4. Apply appropriate rules from `docs/rules/`

### Supported AI Tools

- ✅ Cursor
- ✅ Windsurf  
- ✅ GitHub Copilot
- ✅ Claude Code
- ✅ Any AI with file reading capability

**Why Better than .cursorrules?**

| Feature | Old (.cursorrules) | New (MSB System) |
|---------|-------------------|------------------|
| IDE Support | Cursor only | Any IDE |
| Organization | Monolithic | Modular |
| Maintainability | Hard | Easy |
| Scalability | Limited | High |
| Token Efficiency | All-or-nothing | Tier-based |
```

---

## Phase 5: Update init-dao-project.sh

### 5.1 Modify Setup Script

Update the initialization script to use new system:

```bash
# In init-dao-project.sh, replace .cursorrules section with:

echo "🤖 Setting up AI context system..."

# Update rules-global.md with project name
sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" docs/rules-global.md

# Update context files
sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" docs/ai-context-sequence.md
sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" docs/context-manifest.md

# Create trigger message
echo ""
echo "✅ AI Context System Configured!"
echo ""
echo "Tell your AI agent:"
echo ""
echo "  \"Use the AI context manifest\""
echo ""
echo "This works with ANY AI tool (Cursor, Windsurf, GitHub Copilot, etc.)"
```

---

## Phase 6: Update Documentation

### 6.1 Update 00-START-HERE.md

Add reference to new context system:

```markdown
## 🧠 Working with AI Agents

This project uses an **IDE-agnostic AI context system**.

**Trigger Phrase:**
> "Use the AI context manifest."

**What Happens:**
1. Agent reads `docs/ai-context-sequence.md`
2. Loads context in tiers (Foundation → Code → Analysis)
3. Applies rules from `docs/rules/` as needed
4. Validates against constraints at each tier

**Key Files:**
- `docs/ai-context-sequence.md` - Loading protocol
- `docs/context-manifest.md` - File list
- `docs/rules-global.md` - Global rules
- `docs/rules/` - Modular rules (Apex, LWC, Mobile, Dev, General)

**Works With:**
- Cursor, Windsurf, GitHub Copilot, Claude Code, etc.
- Any AI with file reading capability
```

### 6.2 Update PROJECT.md

Add new file references:

```markdown
## 🔗 Key Links

**AI Context System:**
- Loading Protocol: `/docs/ai-context-sequence.md`
- File Manifest: `/docs/context-manifest.md`
- Global Rules: `/docs/rules-global.md`
- Modular Rules: `/docs/rules/`

**Documentation:**
- Getting Started: `/docs/00-START-HERE.md`
- Architecture: `/docs/01-foundation/ARCHITECTURE.md`
- Data Model: `/docs/01-foundation/data-model.md`
- Requirements: `/docs/02-requirements/`
- ADRs: `/docs/04-implementation/architecture-decisions/`
```

---

## Phase 7: Testing & Validation

### 7.1 Test with Different AI Tools

Test the new system with multiple AI tools:

```bash
# Test 1: Cursor
# Open Cursor, create new chat
# Say: "Use the AI context manifest"
# Verify it loads context correctly

# Test 2: Windsurf (if available)
# Same test as above

# Test 3: GitHub Copilot
# Use Copilot Chat
# Say: "Use the AI context manifest"
# Verify it loads context
```

### 7.2 Validate Context Loading

Create a validation test file:

```markdown
# AI Context Validation Test

## Test Checklist

Ask your AI to confirm it read:

- [ ] `docs/rules/` (all 5 rule files)
- [ ] `docs/00-START-HERE.md`
- [ ] `docs/01-foundation/` (entire folder)
- [ ] `docs/02-requirements/` (entire folder)
- [ ] `docs/03-workflows/` (entire folder)
- [ ] `docs/04-implementation/` (entire folder)
- [ ] `PROJECT.md`

Ask AI to summarize:
- [ ] What are the core Apex rules?
- [ ] What are the LWC architecture requirements?
- [ ] What are the correct FSC object names?
- [ ] What is the deployment process?

If AI can answer all above, context system is working correctly.
```

---

## Phase 8: Cleanup & Finalization

### 8.1 Remove Deprecated Files

After confirming new system works:

```bash
# Optional: Keep .cursorrules.deprecated for historical reference
# Or delete completely:
rm .cursorrules.deprecated

# Remove backup files
find . -name "*.bak" -delete
```

### 8.2 Update Version History

In README.md:

```markdown
## 🔄 Version History

### v2.0.0 (2025-11-XX)
- **BREAKING**: Migrated to IDE-agnostic AI context system
- Added `ai-context-sequence.md` for tier-based context loading
- Added `context-manifest.md` for deterministic file list
- Added `rules-global.md` for IDE-agnostic global rules
- Added modular `docs/rules/` folder (Apex, LWC, Mobile, Dev, General)
- Deprecated `.cursorrules` (replaced by modular system)
- Reorganized `examples/` by technology type
- Added ADR structure with template
- Enhanced architecture documentation

### v1.0.0 (2025-01-XX)
- Initial release with .cursorrules-based system
```

### 8.3 Create Migration ADR

Document this migration decision:

```bash
# Create ADR-0001-migrate-to-msb-context-system.md
```

```markdown
# ADR-0001: Migrate to MSB AI Context System

**Status**: Accepted  
**Date**: 2025-11-XX  
**Deciders**: [Team Names]

## Context

The original DAO-AI-Accelerator used a single .cursorrules file for AI agent instructions. This approach had limitations:

1. **IDE Lock-in**: Only worked with Cursor IDE
2. **Monolithic**: 400+ lines in single file
3. **Not Scalable**: Hard to maintain and extend
4. **Token Inefficient**: All-or-nothing loading

The MSB project developed a superior approach with:
- IDE-agnostic context system
- Tier-based loading
- Modular rules organization
- Better documentation structure

## Decision

We will migrate DAO-AI-Accelerator to use the MSB AI context system.

**Components:**
1. `ai-context-sequence.md` - Tier-based loading protocol
2. `context-manifest.md` - Deterministic file list
3. `rules-global.md` - IDE-agnostic global rules
4. `docs/rules/` - Modular rules folder

**Deprecated:**
- `.cursorrules` file

## Consequences

### Positive
- Works with any AI tool (Cursor, Windsurf, Copilot, etc.)
- Better organized, easier to maintain
- More efficient token usage (tier-based loading)
- Scalable for future enhancements
- Better separation of concerns

### Negative
- Breaking change for existing users
- Requires updating documentation
- Need to train team on new system

### Neutral
- Migration effort: ~2-4 hours
- Backward compatibility: None (breaking change)

## Implementation

See [dao-accelerator-migration-guide.md](../05-analysis/dao-accelerator-migration-guide.md)

## References

- [Comparison Analysis](../05-analysis/dao-accelerator-comparison.md)
- MSB Repository: [sinadino-zennify/msb](link-if-public)
```

---

## Phase 9: Commit & Release

### 9.1 Commit Changes

```bash
# Review all changes
git status

# Stage new files
git add docs/ai-context-sequence.md
git add docs/context-manifest.md
git add docs/rules-global.md
git add docs/rules/

git add .cursorrules  # deprecation notice
git add examples/
git add docs/04-implementation/architecture-decisions/

# Commit
git commit -m "feat: Migrate to MSB IDE-agnostic AI context system

BREAKING CHANGE: Deprecated .cursorrules in favor of modular context system

- Add ai-context-sequence.md (tier-based loading)
- Add context-manifest.md (deterministic file list)
- Add rules-global.md (IDE-agnostic rules)
- Add docs/rules/ (modular rules by concern)
- Deprecate .cursorrules (replaced by modular system)
- Reorganize examples/ by technology type
- Add ADR structure with template
- Update documentation

See docs/05-analysis/dao-accelerator-migration-guide.md for details."
```

### 9.2 Create Pull Request

```bash
# Push branch
git push origin feature/msb-migration

# Create PR with description:
```

**PR Title**: Migrate to MSB IDE-Agnostic AI Context System

**Description**:

This PR migrates the DAO-AI-Accelerator to use the superior MSB AI context system.

**Changes:**
- ✅ Add tier-based context loading system
- ✅ Add modular rules organization
- ✅ Deprecate IDE-specific .cursorrules
- ✅ Reorganize examples by technology
- ✅ Add ADR structure
- ✅ Update all documentation

**Breaking Changes:**
- `.cursorrules` deprecated (replaced by modular system)
- Agents must use new trigger phrase: "Use the AI context manifest"

**Benefits:**
- Works with ANY AI tool (not just Cursor)
- Better organization and maintainability
- More efficient token usage
- Scalable for future enhancements

**Testing:**
- [x] Tested with Cursor
- [ ] Tested with Windsurf
- [ ] Tested with GitHub Copilot
- [x] Context loading validated
- [x] Documentation updated

**References:**
- [Comparison Analysis](docs/05-analysis/dao-accelerator-comparison.md)
- [Migration Guide](docs/05-analysis/dao-accelerator-migration-guide.md)
- [ADR-0001](docs/04-implementation/architecture-decisions/ADR-0001-migrate-to-msb-context-system.md)

---

## Rollback Plan

If migration causes issues:

```bash
# Rollback to previous version
git revert <migration-commit-hash>

# Or restore .cursorrules
git checkout main -- .cursorrules
```

---

## Post-Migration Checklist

- [ ] All new files committed
- [ ] .cursorrules deprecated with notice
- [ ] README.md updated
- [ ] init-dao-project.sh updated
- [ ] Documentation updated (00-START-HERE.md, PROJECT.md)
- [ ] Examples reorganized
- [ ] ADR created
- [ ] Tested with 2+ AI tools
- [ ] PR created and reviewed
- [ ] Version history updated
- [ ] Team notified of breaking change

---

## Support

If you encounter issues during migration:

1. Check [dao-accelerator-comparison.md](./dao-accelerator-comparison.md)
2. Review MSB repository for examples
3. Create issue in repository
4. Contact development team

---

**Migration Guide Version**: 1.0  
**Last Updated**: 2025-11-06  
**Maintainer**: DAO Accelerator Team
