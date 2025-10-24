# DAO-AI-Accelerator

**Version**: 1.0.0  
**Created**: 2025-01-16  
**License**: MIT

> A production-ready accelerator for building Deposit Account Opening (DAO) integrations on Salesforce Financial Services Cloud with AI-assisted development.

---

## 🎯 What is This?

**DAO-AI-Accelerator** is a comprehensive starter template for building deposit account opening solutions on Salesforce Financial Services Cloud (FSC). It provides:

✅ **LWC-based user screens** for guided deposit account opening workflows  
✅ **Apex backend services** for business logic and data validation  
✅ **Complete data model** with FSC objects + custom extensions  
✅ **Screen-by-screen user journey** from application to funding  
✅ **Field mapping framework** (CSV + documentation)  
✅ **REST API patterns** for optional external application integration  
✅ **Custom objects** for collateral, assessments, and due diligence  
✅ **AI agent rules** optimized for DAO projects  
✅ **Documentation templates** for requirements, ADRs, workflows  
✅ **Interactive setup script** for quick project initialization  
✅ **Reference implementation** (ZiFi project example)

---

## 🚀 Quick Start

### 1. Download the Accelerator

```bash
# Clone or download the repository
git clone [repository-url]
cd DAO-AI-Accelerator

# Or download and extract the ZIP file
```

### 2. Run the Setup Script

```bash
chmod +x init-dao-project.sh
./init-dao-project.sh
```

You'll be prompted for:
- **Project Name** (e.g., "BankXYZ")
- **Client Name** (e.g., "Bank XYZ")
- **Org Alias** (e.g., "bankxyz-dev")
- **Integration Source** (e.g., "AngularApp")
- **Instance URL** (e.g., "https://test.salesforce.com")

### 3. Authenticate with Salesforce

```bash
sf org login web --alias YOUR_ORG_ALIAS
```

### 4. Deploy Custom Objects

```bash
sf project deploy start --source-dir force-app/main/default/objects --target-org YOUR_ORG_ALIAS
```

### 5. Start Building!

Read `SETUP-GUIDE.md` for complete onboarding instructions.

---

## 📦 What's Included

### 📁 Directory Structure

```
DAO-AI-Accelerator/
├── docs/                           # All documentation
│   ├── 01-foundation/              # Data model, field mappings
│   ├── 02-requirements/            # User stories, backlog
│   ├── 03-workflows/               # User workflows, external app workflows
│   ├── 04-implementation/          # ADRs, session notes, LWC architecture
│   └── 05-analysis/                # Analysis reports
│
├── force-app/                      # Salesforce metadata
│   └── main/default/
│       ├── lwc/                    # Lightning Web Components
│       │   ├── daoApplicationFlow/ # Multi-step application flow
│       │   ├── applicantDetails/   # Applicant information screens
│       │   ├── productSelection/   # Product selection interface
│       │   ├── collateralEntry/    # Collateral information entry
│       │   ├── reviewAndSubmit/    # Final review screen
│       │   └── applicationStatus/  # Status tracking dashboard
│       ├── classes/                # Apex classes
│       │   ├── DAOApplicationService.cls
│       │   ├── DAOValidationService.cls
│       │   ├── DAOWorkflowService.cls
│       │   ├── DAOProductService.cls
│       │   └── patterns/           # Code pattern documentation
│       └── objects/                # Custom objects
│           ├── Assigned_Products__c/
│           ├── Collateral__c/
│           ├── Collateral_Owner__c/
│           ├── Collateral_Association__c/
│           ├── Collateral_Assessment__c/
│           ├── Account/            # DAOBusinessId__c field
│           ├── Applicant/          # DAOApplicantId__c field
│           └── ApplicationForm/    # DAOApplicationId__c field
│
├── scripts/                        # Utility scripts
│   ├── test-api-template.apex     # API test template
│   └── README.md
│
├── examples/                       # Reference implementations
│   └── zifi-project/              # ZiFi working example
│
├── .cursorrules                    # AI agent instructions (templated)
├── accelerator-config.json         # Project configuration
├── PROJECT.md                      # Project status template
├── init-dao-project.sh            # Interactive setup script
└── package.xml                     # Salesforce deployment manifest
```

### ⚡ LWC Components Included

| Component | Purpose | User Journey Step |
|-----------|---------|-------------------|
| **daoApplicationFlow** | Multi-step application container with navigation | Main workflow orchestrator |
| **applicantDetails** | Applicant information entry and validation | Step 1: Applicant Info |
| **productSelection** | Product selection interface with recommendations | Step 2: Product Choice |
| **collateralEntry** | Collateral information and documentation | Step 3: Collateral Details |
| **reviewAndSubmit** | Final review and submission confirmation | Step 4: Review & Submit |
| **applicationStatus** | Status tracking and progress dashboard | Ongoing: Status Monitoring |

### 🏗️ Custom Objects Included

| Object | Purpose | Type |
|--------|---------|------|
| **Assigned_Products__c** | Junction: Applicant → ApplicationFormProduct | Custom |
| **Collateral__c** | Collateral items (master) | Custom |
| **Collateral_Owner__c** | Ownership relationships | Custom (junction) |
| **Collateral_Association__c** | Account associations | Custom (junction) |
| **Collateral_Assessment__c** | Valuation tracking | Custom (detail) |

### 🔑 External ID Fields

Pre-configured external ID fields for upsert operations:
- `Account.DAOBusinessId__c`
- `Applicant.DAOApplicantId__c`
- `ApplicationForm.DAOApplicationId__c`

---

## 🤖 AI-Optimized Development

This accelerator is designed for AI-assisted development with:

- **`.cursorrules`** - Comprehensive AI agent instructions
- **CSV-first approach** - User maintains field mappings in CSV
- **Auto-documentation** - Agents sync MD files from CSV changes
- **Clear boundaries** - Explicit user vs agent responsibilities

### How It Works

1. **You** update `field-mappings.csv` with your external app fields
2. **AI Agent** reads the CSV and syncs `field-mappings.md`
3. **AI Agent** uses mappings to generate code
4. **Result**: Consistent, documented, maintainable code

---

## 📚 Documentation Highlights

### For Developers
- **00-START-HERE.md** - Project orientation
- **data-model.md** - Object relationships and ER diagrams
- **REST-API-Pattern.md** - Code patterns and examples
- **dao-api-quickstart.md** - API integration guide

### For Project Managers
- **PROJECT.md** - Sprint tracking and status
- **backlog-template.md** - Prioritized work items

### For Architects
- **ADR templates** - Document key decisions
- **data-model.md** - Complete entity relationships

---

## 🔒 Security Built-In

- ✅ PII encryption requirements documented
- ✅ CRUD/FLS enforcement patterns
- ✅ Field-level security guidelines
- ✅ OAuth 2.0 authentication setup
- ✅ External ID-based upserts (prevent duplicates)

---

## 🧪 Testing Framework

- ✅ Test script templates
- ✅ Bulkification requirements (200+ records)
- ✅ ≥85% code coverage standard
- ✅ Postman collection for API testing

---

## 📖 Use Cases

Perfect for:
- 💰 **Guided deposit account opening** with step-by-step LWC screens
- 🏦 **Business banking applications** with intuitive user interfaces
- 👤 **Multi-applicant account setups** with collaborative workflows
- 🔐 **Compliance-heavy financial services** with built-in validation
- 🔄 **Optional external app integration** for data synchronization
- 📱 **Self-service customer portals** for account opening
- 🏢 **Bank staff workflows** for assisted account opening

---

## 🛠️ Requirements

- Salesforce Financial Services Cloud (FSC) license
- Salesforce CLI (sf) installed
- Postman (for API testing)
- Basic knowledge of Salesforce development
- Optional: AI coding assistant (Cursor, GitHub Copilot, etc.)

---

## 📖 Documentation

- **SETUP-GUIDE.md** - Comprehensive onboarding guide
- **docs/00-START-HERE.md** - Quick reference for developers
- **examples/zifi-project/** - Working reference implementation

---

## 🤝 Contributing

This accelerator improves with community feedback!

### Found a bug?
1. Check existing issues
2. Create a new issue with details
3. Submit a pull request if you have a fix

### Have an improvement?
1. Fork the repository
2. Make your changes
3. Submit a pull request with description

---

## 📞 Support

- **Documentation**: See `SETUP-GUIDE.md`
- **Issues**: [GitHub Issues](repository-url/issues)
- **Examples**: Check `examples/zifi-project/`

---

## 📜 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

Built by the ZiFi development team based on real-world production implementations.

Special thanks to:
- Salesforce Financial Services Cloud team
- ZiFi project contributors

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-16 | Initial release |

---

**Maintained By**: Development Community  
**Last Updated**: 2025-01-16  
**Next Review**: Quarterly

---

## ⭐ Star This Repository

If this accelerator helped you, please star the repository to help others discover it!

