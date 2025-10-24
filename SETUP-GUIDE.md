# DAO-AI-Accelerator - Complete Setup Guide

**Version**: 1.0.0  
**Last Updated**: 2025-01-16

Welcome! This guide will walk you through setting up a new DAO integration project using the accelerator.

---

## 📋 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Initial Setup](#-initial-setup)
3. [Configure Field Mappings](#-configure-field-mappings)
4. [Deploy to Salesforce](#-deploy-to-salesforce)
5. [Set Up API Integration](#-set-up-api-integration)
6. [Working with AI Agents](#-working-with-ai-agents)
7. [Development Workflow](#-development-workflow)
8. [Troubleshooting](#-troubleshooting)

---

## ✅ Prerequisites

Before starting, ensure you have:

- [ ] **Salesforce org** with Financial Services Cloud (FSC) license
- [ ] **Salesforce CLI** installed (`sf`) - [Install Guide](https://developer.salesforce.com/tools/salesforcecli)
- [ ] **Git** installed (optional, for version control)
- [ ] **Postman** installed (for API testing)
- [ ] **Code editor** (VSCode, Cursor, etc.)
- [ ] **System admin access** to Salesforce org

### Verify Prerequisites

```bash
# Check Salesforce CLI
sf --version

# Check Git (optional)
git --version
```

---

## 🚀 Initial Setup

### Step 1: Download the Accelerator

**Option A: Clone from GitHub**
```bash
git clone [repository-url] my-project-name
cd my-project-name
```

**Option B: Download ZIP**
1. Download the ZIP file
2. Extract to your project directory
3. Open terminal in that directory

### Step 2: Run Interactive Setup

```bash
# Make script executable (Mac/Linux)
chmod +x init-dao-project.sh

# Run setup
./init-dao-project.sh
```

**The script will prompt you for:**

| Prompt | Example | Description |
|--------|---------|-------------|
| Project Name | BankXYZ | Short project identifier |
| Client Name | Bank XYZ | Full client name |
| Org Alias | bankxyz-dev | Salesforce org alias |
| Integration Source | AngularApp | External application name |
| Instance URL | https://test.salesforce.com | Salesforce login URL |

**The script will update:**
- ✅ `accelerator-config.json`
- ✅ `.cursorrules` (AI agent rules)
- ✅ `PROJECT.md`
- ✅ All documentation files
- ✅ Postman collection
- ✅ Object metadata descriptions

### Step 3: Review Configuration

Check `accelerator-config.json` to verify all placeholders were replaced:

```bash
cat accelerator-config.json
```

---

## 📊 Configure Field Mappings

### Step 1: Understand Your External Application

Document the fields your external application sends. For each field, you need:
- Field name (snake_case, e.g., `first_name`)
- Data type (Text, Number, Boolean, etc.)
- Which JSON object it belongs to (applicant/business/application)
- Target Salesforce field

### Step 2: Edit the CSV

Open `docs/01-foundation/field-mappings-template.csv` in Excel or a text editor.

**Fill in these columns:**

| Column | Description | Example |
|--------|-------------|---------|
| Row | Sequential number | 1, 2, 3... |
| Salesforce Object | Target object | Account, Applicant, ApplicationForm |
| Salesforce Field API Name | Exact field name | Name, Email, DAOBusinessId__c |
| Angular App Field Name | External field name | business_name, email, dao_business_id |
| Type | Data type | Text, Email, Number, Boolean |
| JSON Object | JSON section | applicant, business, application |
| Mapped | Is it mapped? | Yes, No |
| Notes | Implementation notes | "Required field", "Encrypted" |
| Comments | Questions/clarifications | "Confirm data format with team" |

**Example Row:**
```csv
1,Account,Name,business_name,Text,business,Yes,Legal business name,
2,Account,DAOBusinessId__c,dao_business_id,Text,business,Yes,External ID for upsert,
3,Applicant,FirstName,first_name,Text,applicant,Yes,,
```

### Step 3: Review the Example

Check `examples/zifi-project/dao-field-mappings-example.csv` to see a complete working example with 100+ fields.

**Key observations:**
- Organized by object type
- Consistent naming (dao_*, _id suffixes)
- Comments column used for special cases
- External IDs clearly marked

---

## 🚢 Deploy to Salesforce

### Step 1: Authenticate

```bash
# Login to Salesforce
sf org login web --alias YOUR_ORG_ALIAS

# Verify connection
sf org list
```

### Step 2: Deploy Custom Objects

```bash
# Deploy all custom objects and fields
sf project deploy start --source-dir force-app/main/default/objects --target-org YOUR_ORG_ALIAS
```

**What gets deployed:**
- ✅ Assigned_Products__c (junction object)
- ✅ Collateral__c + related objects (4 objects)
- ✅ External ID fields (DAOBusinessId__c, DAOApplicantId__c, DAOApplicationId__c)

### Step 3: Verify Deployment

```bash
# Open Salesforce Setup
sf org open --target-org YOUR_ORG_ALIAS --path lightning/setup/ObjectManager/home

# Or check deployment status
sf project deploy report --target-org YOUR_ORG_ALIAS
```

**Verify in Setup → Object Manager:**
- [ ] Assigned_Products__c exists
- [ ] Collateral__c and related objects exist
- [ ] Account has DAOBusinessId__c field
- [ ] Applicant has DAOApplicantId__c field
- [ ] ApplicationForm has DAOApplicationId__c field

---

## 🔌 Set Up API Integration

### Step 1: Create Connected App

1. In Salesforce Setup → App Manager
2. Click **New Connected App**
3. Fill in:
   - Name: `[Your Project] API Integration`
   - Contact Email: your-email@example.com
   - Enable OAuth Settings: ✅
   - Callback URL: `https://test.salesforce.com/services/oauth2/callback`
   - OAuth Scopes: `Full access (full)`, `Perform requests at any time (refresh_token, offline_access)`
4. Save and copy Consumer Key + Secret

### Step 2: Configure Postman

1. Import `docs/04-implementation/DAO-API-Postman-Collection.json`
2. Set environment variables:
   - `client_id`: Consumer Key from step 1
   - `client_secret`: Consumer Secret from step 1
   - `username`: Your Salesforce username
   - `password`: Password + Security Token (concatenated)
   - `salesforce_instance_url`: Your instance URL

3. Run "Get OAuth Token" to authenticate
4. Run "DAO Application - Create/Update" to test

See `docs/04-implementation/DAO-API-Postman-Setup.md` for detailed instructions.

---

## 🤖 Working with AI Agents

This accelerator is optimized for AI-assisted development (Cursor, GitHub Copilot, etc.).

### Key Principles

1. **CSV is Source of Truth**
   - YOU maintain `field-mappings.csv`
   - AI reads it but never modifies it
   - AI syncs `field-mappings.md` when you update CSV

2. **AI Pre-Work Checklist**
   - AI must read data model before coding
   - AI must verify object names
   - AI must check field mappings

3. **Clear Responsibilities**
   | Task | Owner | Agent Can Modify? |
   |------|-------|-------------------|
   | field-mappings.csv | User | ❌ NO |
   | field-mappings.md | Agent | ✅ YES |
   | Code implementation | Agent | ✅ YES |
   | Testing | Agent | ✅ YES |

### Using `.cursorrules`

The `.cursorrules` file tells AI agents:
- What object names to use (FSC canonical names)
- How to handle field mappings
- Testing requirements
- Code quality standards
- Deployment procedures

**After running init script**, `.cursorrules` is customized with your project details.

---

## 🔄 Development Workflow

### Typical Task Flow

1. **Pick a task** from `docs/02-requirements/backlog.md`
2. **Read the story** in `docs/02-requirements/ST-XXX.md`
3. **Check field mappings** in `field-mappings.csv`
4. **Review workflows** in `docs/03-workflows/` (for API work)
5. **Implement** the feature
6. **Test** (≥85% coverage, bulkified)
7. **Deploy** to Salesforce
8. **Document** in session notes

### Adding New Field Mappings

1. **You**: Add row to `docs/01-foundation/field-mappings.csv`
2. **You**: Save the CSV file
3. **AI Agent**: Reads CSV and updates `field-mappings.md`
4. **AI Agent**: Uses new mapping in code generation

### Making Architecture Decisions

1. Copy `docs/04-implementation/architecture-decisions/ADR-TEMPLATE.md`
2. Fill in context, decision, rationale
3. Get team review
4. Update status to "Accepted"
5. Add to ADR index

---

## 🐛 Troubleshooting

### Setup Script Issues

**Problem**: Script doesn't replace placeholders

**Solution**:
```bash
# Mac/Linux - use sed with backup
sed -i.bak 's/{{PROJECT_NAME}}/YourProject/g' file.txt

# Check if replacements worked
grep -r "{{" .
```

### Deployment Failures

**Problem**: Field references missing object

**Solution**: Deploy parent objects first
```bash
# Deploy in order
sf project deploy start --source-dir force-app/main/default/objects/Collateral__c
sf project deploy start --source-dir force-app/main/default/objects/Collateral_Owner__c
```

### Authentication Issues

**Problem**: "API disabled for this user"

**Solution**: In Salesforce Setup → Users → [Your User] → check "API Enabled"

**Problem**: "invalid_grant" in Postman

**Solution**: Verify password includes security token (password+token, no space)

---

## 📚 Additional Resources

- **Salesforce FSC Documentation**: https://help.salesforce.com/s/articleView?id=sf.fsc_welcome.htm
- **Salesforce CLI Guide**: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/
- **REST API Guide**: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/
- **OAuth 2.0 Flows**: https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_flows.htm

---

## 🎓 Learning Path

### Week 1: Foundation
- [ ] Run setup script
- [ ] Review data model
- [ ] Deploy custom objects
- [ ] Fill in field mappings (first 10 fields)

### Week 2: Integration
- [ ] Set up Connected App
- [ ] Test API with Postman
- [ ] Implement first API endpoint
- [ ] Write tests

### Week 3: Development
- [ ] Complete field mappings
- [ ] Build ingestion service
- [ ] Add validation rules
- [ ] Deploy to sandbox

### Week 4: Testing & Polish
- [ ] End-to-end testing
- [ ] Performance testing (200+ records)
- [ ] Documentation review
- [ ] Production readiness checklist

---

## ✅ Production Readiness Checklist

Before going live:

- [ ] All field mappings complete and tested
- [ ] ≥85% test coverage on all classes
- [ ] PII fields encrypted
- [ ] CRUD/FLS enforced
- [ ] API authentication secured
- [ ] Error handling comprehensive
- [ ] Debug logs sanitized (no PII)
- [ ] Documentation updated
- [ ] Team trained
- [ ] Runbook created

---

## 📞 Getting Help

1. **Check documentation** in `/docs`
2. **Review examples** in `/examples/zifi-project`
3. **Search issues** in GitHub
4. **Ask the community** (Salesforce Stack Exchange)
5. **Contact support** (if commercial)

---

**Questions?** Open an issue or contact the development team.

**Ready to build?** Start with `docs/00-START-HERE.md`

---

Happy building! 🚀

