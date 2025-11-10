# DAO-AI-Accelerator: Complete Push List

**Purpose**: Detailed list of components to push from MSB to DAO-AI-Accelerator  
**Date**: 2025-11-06  
**Status**: Ready for Implementation

---

## 📦 Complete Component List

### 1. AI Context System (Priority 1 - Foundation)

#### Files to Push:
```bash
# From MSB → DAO-AI-Accelerator
docs/ai-context-sequence.md
docs/context-manifest.md
docs/rules-global.md
docs/rules/
├── apex-rules.md
├── lwc-rules.md
├── mobile-rules.md
├── dev-rules.md
└── general-rules.md
```

**Action**: Copy as-is, replace "Main Street Bank" with "{{PROJECT_NAME}}"

---

### 2. Wizard Framework - Core Components (Priority 1 - Essential)

#### A. Custom Metadata Type
```bash
force-app/main/default/objects/Wizard_Step__mdt/
├── Wizard_Step__mdt.object-meta.xml
└── fields/
    ├── ComponentBundle__c.field-meta.xml
    ├── HelpText__c.field-meta.xml
    ├── Order__c.field-meta.xml
    ├── Skippable__c.field-meta.xml
    ├── StepLabel__c.field-meta.xml
    ├── ValidatorClasses__c.field-meta.xml
    └── WizardApiName__c.field-meta.xml
```

**Purpose**: Defines wizard step configuration schema

#### B. Apex Services
```bash
force-app/main/default/classes/
├── WizardConfigService.cls
├── WizardConfigService.cls-meta.xml
├── WizardConfigServiceTest.cls
├── WizardConfigServiceTest.cls-meta.xml
├── WizardPersistenceService.cls
├── WizardPersistenceService.cls-meta.xml
├── WizardPersistenceServiceTest.cls
└── WizardPersistenceServiceTest.cls-meta.xml
```

**Purpose**: Backend services for wizard configuration and persistence

**Note**: 
- `WizardPersistenceService` contains MSB-specific handlers
- Either make it generic OR provide as example pattern
- See recommendation below

#### C. Container LWC
```bash
force-app/main/default/lwc/daoWizardContainer/
├── daoWizardContainer.css
├── daoWizardContainer.html
├── daoWizardContainer.js
└── daoWizardContainer.js-meta.xml
```

**Purpose**: Generic wizard container (the "player")

#### D. Step Router LWC
```bash
force-app/main/default/lwc/daoWizardStepRouter/
├── daoWizardStepRouter.html
├── daoWizardStepRouter.js
└── daoWizardStepRouter.js-meta.xml
```

**Purpose**: Dynamic step component loader

#### E. Action Components (Optional but Recommended)
```bash
force-app/main/default/lwc/openDaoWizardAction/
├── openDaoWizardAction.html
├── openDaoWizardAction.js
└── openDaoWizardAction.js-meta.xml

force-app/main/default/aura/openDaoWizardTab/
├── openDaoWizardTab.cmp
├── openDaoWizardTab.cmp-meta.xml
└── openDaoWizardTabController.js
```

**Purpose**: Quick actions to launch wizards

---

### 3. Example Step LWCs (Priority 2 - Reference Implementation)

```bash
force-app/main/default/lwc/applicantDetails/
force-app/main/default/lwc/businessDetails/
force-app/main/default/lwc/productSelection/
force-app/main/default/lwc/reviewAndSubmit/
force-app/main/default/lwc/additionalServices/
force-app/main/default/lwc/documentUpload/
force-app/main/default/lwc/additionalApplicants/
```

**Purpose**: Example step implementations showing the pattern

**Note**: 
- These contain MSB-specific business logic
- Push to `examples/lwc/wizard-steps/` as reference
- Not for direct deployment

---

### 4. Example Wizard Configuration (Priority 2 - Reference)

```bash
force-app/main/default/customMetadata/
├── Wizard_Step__mdt.DAO_Business_InBranch_Applicant.md-meta.xml
├── Wizard_Step__mdt.DAO_Business_InBranch_Business.md-meta.xml
├── Wizard_Step__mdt.DAO_Business_InBranch_Product.md-meta.xml
├── Wizard_Step__mdt.DAO_Business_InBranch_Review.md-meta.xml
├── Wizard_Step__mdt.DAO_Business_InBranch_Services.md-meta.xml
├── Wizard_Step__mdt.DAO_Business_InBranch_Documents.md-meta.xml
└── Wizard_Step__mdt.DAO_Business_InBranch_Additional.md-meta.xml
```

**Purpose**: Complete wizard configuration example

**Recommendation**: Push to `examples/custom-metadata/` as reference

---

### 5. Architecture Documentation (Priority 1 - Critical)

```bash
docs/01-foundation/ARCHITECTURE.md
docs/04-implementation/architecture-decisions/
├── ADR-0002-configuration-driven-wizard.md
├── ADR-0003-step-handler-map-pattern.md
└── ADR-TEMPLATE.md
```

**Purpose**: 
- Explains the wizard pattern
- Documents key architectural decisions
- Provides template for new ADRs

---

## 🎯 Recommended Push Strategy

### Strategy A: Framework + Examples (Recommended)

**Push as Core (Deployable):**
1. ✅ AI Context System
2. ✅ Wizard_Step__mdt (Custom Metadata Type)
3. ✅ WizardConfigService (Apex)
4. ✅ **Generic** WizardPersistenceService (Apex) - see refactoring below
5. ✅ daoWizardContainer (LWC)
6. ✅ daoWizardStepRouter (LWC)
7. ✅ openDaoWizardAction (LWC) - optional
8. ✅ Architecture documentation

**Push as Examples (Non-Deployable):**
1. ✅ Step LWCs → `examples/lwc/wizard-steps/`
2. ✅ Wizard metadata records → `examples/custom-metadata/`
3. ✅ MSB-specific persistence handlers → `examples/apex/`

---

## 🔧 Required Refactoring

### WizardPersistenceService Cleanup

The current `WizardPersistenceService` contains MSB-specific handlers for:
- Applicant step
- Business step
- Product step
- Review step
- Services step
- Documents step
- Additional step

**Option A: Make it Generic (Recommended)**

Refactor to interface-based pattern where projects provide their own handlers:

```apex
// Generic interface
public interface IWizardStepPersistenceHandler {
    PersistenceResponse handle(Id recordId, String stepName, Map<String, Object> payload);
}

// Project registers handlers
public class WizardPersistenceService {
    private static Map<String, IWizardStepPersistenceHandler> handlers = new Map<String, IWizardStepPersistenceHandler>();
    
    public static void registerHandler(String stepName, IWizardStepPersistenceHandler handler) {
        handlers.put(stepName, handler);
    }
    
    @AuraEnabled
    public static PersistenceResponse saveStep(Id recordId, String stepName, Map<String, Object> payload) {
        IWizardStepPersistenceHandler handler = handlers.get(stepName);
        if (handler != null) {
            return handler.handle(recordId, stepName, payload);
        }
        // Default: no-op or simple JSON storage
        return new PersistenceResponse(true, 'Step saved');
    }
}
```

**Option B: Provide Stub Implementation**

Push a minimal version with TODO comments:

```apex
public class WizardPersistenceService {
    @AuraEnabled
    public static PersistenceResponse saveStep(Id recordId, String stepName, Map<String, Object> payload) {
        // TODO: Implement step-specific persistence logic
        // See examples/apex/WizardPersistenceHandlers.cls for patterns
        
        System.debug('Saving step: ' + stepName + ' for record: ' + recordId);
        System.debug('Payload: ' + JSON.serialize(payload));
        
        return new PersistenceResponse(true, 'Step saved (stub implementation)');
    }
}
```

Then provide MSB handlers in `examples/apex/WizardPersistenceHandlers.cls`

**Recommendation**: Use **Option B** (stub + examples) for simplicity

---

## 📂 Proposed DAO-AI-Accelerator Structure (After Push)

```
DAO-AI-Accelerator/
├── docs/
│   ├── ai-context-sequence.md           ← NEW
│   ├── context-manifest.md              ← NEW
│   ├── rules-global.md                  ← NEW
│   ├── rules/                           ← NEW
│   │   ├── apex-rules.md
│   │   ├── lwc-rules.md
│   │   ├── mobile-rules.md
│   │   ├── dev-rules.md
│   │   └── general-rules.md
│   ├── 00-START-HERE.md                 ← UPDATE (reference new context system)
│   ├── 01-foundation/
│   │   ├── ARCHITECTURE.md              ← NEW (wizard patterns)
│   │   ├── data-model.md
│   │   └── field-mappings.csv
│   ├── 02-requirements/
│   ├── 03-workflows/
│   ├── 04-implementation/
│   │   ├── architecture-decisions/      ← NEW
│   │   │   ├── ADR-0002-configuration-driven-wizard.md
│   │   │   ├── ADR-0003-step-handler-map-pattern.md
│   │   │   └── ADR-TEMPLATE.md
│   │   └── session-notes/
│   └── 05-analysis/
│
├── force-app/main/default/
│   ├── classes/
│   │   ├── WizardConfigService.cls           ← NEW
│   │   ├── WizardConfigServiceTest.cls       ← NEW
│   │   ├── WizardPersistenceService.cls      ← NEW (stub version)
│   │   └── WizardPersistenceServiceTest.cls  ← NEW
│   │
│   ├── lwc/
│   │   ├── daoWizardContainer/               ← NEW
│   │   ├── daoWizardStepRouter/              ← NEW
│   │   └── openDaoWizardAction/              ← NEW (optional)
│   │
│   ├── aura/
│   │   └── openDaoWizardTab/                 ← NEW (optional)
│   │
│   └── objects/
│       └── Wizard_Step__mdt/                 ← NEW
│           ├── Wizard_Step__mdt.object-meta.xml
│           └── fields/ (7 fields)
│
├── examples/
│   ├── README.md                             ← UPDATE
│   ├── apex/
│   │   └── WizardPersistenceHandlers.cls     ← NEW (MSB handlers as reference)
│   ├── lwc/
│   │   └── wizard-steps/                     ← NEW
│   │       ├── applicantDetails/
│   │       ├── businessDetails/
│   │       ├── productSelection/
│   │       └── reviewAndSubmit/
│   └── custom-metadata/
│       └── DAO_Business_InBranch_Wizard/     ← NEW
│           └── (7 Wizard_Step__mdt records)
│
├── .cursorrules.deprecated                   ← RENAMED
├── .cursorrules                              ← NEW (deprecation notice)
└── README.md                                 ← UPDATE
```

---

## 📋 Step-by-Step Push Instructions

### Phase 1: AI Context System
```bash
cd DAO-AI-Accelerator/

# Copy context files
cp ../msb/docs/ai-context-sequence.md docs/
cp ../msb/docs/context-manifest.md docs/
cp ../msb/docs/rules-global.md docs/

# Copy rules folder
cp -r ../msb/docs/rules/ docs/

# Update placeholders
sed -i '' 's/Main Street Bank/{{PROJECT_NAME}}/g' docs/rules-global.md
sed -i '' 's/Main Street Bank/{{PROJECT_NAME}}/g' docs/ai-context-sequence.md
sed -i '' 's/Main Street Bank/{{PROJECT_NAME}}/g' docs/context-manifest.md
```

### Phase 2: Wizard Framework Core
```bash
# Copy Custom Metadata Type
cp -r ../msb/force-app/main/default/objects/Wizard_Step__mdt/ \
      force-app/main/default/objects/

# Copy Apex Services
cp ../msb/force-app/main/default/classes/WizardConfigService.* \
   force-app/main/default/classes/

cp ../msb/force-app/main/default/classes/WizardConfigServiceTest.* \
   force-app/main/default/classes/

# Copy LWC Components
cp -r ../msb/force-app/main/default/lwc/daoWizardContainer/ \
      force-app/main/default/lwc/

cp -r ../msb/force-app/main/default/lwc/daoWizardStepRouter/ \
      force-app/main/default/lwc/

cp -r ../msb/force-app/main/default/lwc/openDaoWizardAction/ \
      force-app/main/default/lwc/

# Copy Aura (optional)
cp -r ../msb/force-app/main/default/aura/openDaoWizardTab/ \
      force-app/main/default/aura/
```

### Phase 3: WizardPersistenceService (Choose Option B)
```bash
# Create stub version (manually create this file)
# See "Option B" above for content
```

### Phase 4: Examples
```bash
# Create structure
mkdir -p examples/lwc/wizard-steps/
mkdir -p examples/custom-metadata/DAO_Business_InBranch_Wizard/
mkdir -p examples/apex/

# Copy example step LWCs
cp -r ../msb/force-app/main/default/lwc/applicantDetails/ \
      examples/lwc/wizard-steps/

cp -r ../msb/force-app/main/default/lwc/businessDetails/ \
      examples/lwc/wizard-steps/

cp -r ../msb/force-app/main/default/lwc/productSelection/ \
      examples/lwc/wizard-steps/

cp -r ../msb/force-app/main/default/lwc/reviewAndSubmit/ \
      examples/lwc/wizard-steps/

# Copy example metadata
cp ../msb/force-app/main/default/customMetadata/Wizard_Step__mdt.DAO_Business_InBranch_* \
   examples/custom-metadata/DAO_Business_InBranch_Wizard/

# Copy MSB persistence service as example
cp ../msb/force-app/main/default/classes/WizardPersistenceService.cls \
   examples/apex/WizardPersistenceHandlers.cls
```

### Phase 5: Documentation
```bash
# Copy architecture docs
cp ../msb/docs/01-foundation/ARCHITECTURE.md \
   docs/01-foundation/

# Copy ADRs
mkdir -p docs/04-implementation/architecture-decisions/
cp ../msb/docs/04-implementation/architecture-decisions/ADR-0002-* \
   docs/04-implementation/architecture-decisions/

cp ../msb/docs/04-implementation/architecture-decisions/ADR-0003-* \
   docs/04-implementation/architecture-decisions/

cp ../msb/docs/04-implementation/architecture-decisions/ADR-TEMPLATE.md \
   docs/04-implementation/architecture-decisions/

cp ../msb/docs/04-implementation/architecture-decisions/README.md \
   docs/04-implementation/architecture-decisions/
```

### Phase 6: Deprecate .cursorrules
```bash
# Rename existing
mv .cursorrules .cursorrules.deprecated

# Create deprecation notice (see content above)
cat > .cursorrules << 'EOF'
# ⚠️ DEPRECATED - See docs/ai-context-sequence.md
...
EOF
```

### Phase 7: Update Documentation
```bash
# Manually update:
# - README.md (AI context system section)
# - docs/00-START-HERE.md (reference new files)
# - docs/04-implementation/architecture-decisions/README.md (index ADRs)
# - examples/README.md (explain structure)
```

---

## ✅ Validation Checklist

After pushing, verify:

- [ ] All wizard framework files present
- [ ] Wizard_Step__mdt custom metadata type deploys successfully
- [ ] WizardConfigService compiles and tests pass
- [ ] daoWizardContainer component loads without errors
- [ ] Example metadata records are in examples/ folder
- [ ] Example step LWCs are in examples/lwc/wizard-steps/
- [ ] Documentation references are correct
- [ ] .cursorrules is deprecated with notice
- [ ] AI context system files present
- [ ] Rules folder is complete
- [ ] ADRs are indexed

---

## 📦 Package.xml Additions

Add these to `package.xml`:

```xml
<!-- Custom Metadata Types -->
<types>
    <members>Wizard_Step__mdt</members>
    <name>CustomObject</name>
</types>

<!-- Apex Classes -->
<types>
    <members>WizardConfigService</members>
    <members>WizardConfigServiceTest</members>
    <members>WizardPersistenceService</members>
    <members>WizardPersistenceServiceTest</members>
    <name>ApexClass</name>
</types>

<!-- Lightning Web Components -->
<types>
    <members>daoWizardContainer</members>
    <members>daoWizardStepRouter</members>
    <members>openDaoWizardAction</members>
    <name>LightningComponentBundle</name>
</types>

<!-- Aura Components (optional) -->
<types>
    <members>openDaoWizardTab</members>
    <name>AuraDefinitionBundle</name>
</types>
```

---

## 🚀 Post-Push Actions

1. **Update README badges/version**: v1.0 → v2.0
2. **Create release notes**: Document wizard framework addition
3. **Update init-dao-project.sh**: Reference new context system
4. **Create usage guide**: How to create a wizard in 5 steps
5. **Record demo video**: Show wizard creation process
6. **Update examples**: Ensure they're clearly marked as non-deployable

---

## 📊 Impact Assessment

### What Gets Better:
- ✅ IDE-agnostic AI context system
- ✅ Reusable wizard framework (metadata-driven)
- ✅ Professional architecture documentation
- ✅ Complete working examples
- ✅ Enterprise-ready patterns

### What Stays the Same:
- ✅ Existing directory structure
- ✅ CSV field mapping approach
- ✅ External ID patterns
- ✅ Core data model

### Breaking Changes:
- ⚠️ .cursorrules deprecated (use new context system)
- ⚠️ Requires understanding of wizard framework

---

## 🎯 Success Criteria

After push, users should be able to:

1. Clone DAO-AI-Accelerator
2. Run init script
3. Deploy wizard framework (core components)
4. Study examples (step LWCs, metadata)
5. Create new wizard by:
   - Creating Wizard_Step__mdt records
   - Building step LWCs following examples
   - Implementing persistence handlers
   - Placing daoWizardContainer on page
6. Use any AI tool (not just Cursor)

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-06  
**Maintainer**: MSB Development Team
