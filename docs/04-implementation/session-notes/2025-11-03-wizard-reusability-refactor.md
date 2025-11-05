# Session Note: Wizard Reusability & Handler Map Refactoring

**Date**: 2025-11-03  
**Participants**: Development Team  
**Duration**: ~2 hours  
**Sprint**: Foundation Phase

---

## 🎯 Session Objectives

1. Formalize the wizard reusability pattern for future DAO projects
2. Refactor `WizardPersistenceService` to use a more maintainable routing pattern
3. Document architectural decisions and implementation patterns

---

## ✅ Completed Work

### 1. Created Architecture Documentation
- **File**: `/docs/01-foundation/ARCHITECTURE.md`
- **Content**:
  - Core principles (Configuration over Code, Container is Generic, Services are Decoupled)
  - Step-by-step guide for creating new wizards
  - Service dependencies and contracts
  - Example metadata record structure

### 2. Refactored WizardPersistenceService
- **File**: `/force-app/main/default/classes/WizardPersistenceService.cls`
- **Changes**:
  - Replaced brittle `if/else if` chain with handler map pattern
  - Defined `IStepHandler` interface for consistency
  - Created inner handler classes for each step type
  - Added missing handlers for Additional, Services, and Documents steps
  - Added comprehensive JavaDoc comments for maintainability

**Before**:
```apex
if (stepDeveloperName.contains('Applicant')) {
    return upsertApplicantStep(...);
} else if (stepDeveloperName.contains('Business')) {
    // ...
}
```

**After**:
```apex
private static final Map<String, IStepHandler> stepHandlers = new Map<String, IStepHandler>{
    'DAO_Business_InBranch_Applicant' => new ApplicantStepHandler(),
    'DAO_Business_InBranch_Business' => new BusinessStepHandler(),
    // ...
};

IStepHandler handler = stepHandlers.get(stepDeveloperName);
if (handler != null) {
    return handler.handle(applicationId, payload, response);
}
```

### 3. Deployed to Sandbox
- **Org**: msb-sbox
- **Deploy ID**: `0AfWE00000ElN9B0AV`
- **Status**: Succeeded
- **Components**: WizardPersistenceService.cls

### 4. Created ADRs
- **ADR-0002**: Configuration-Driven Wizard Pattern
  - Documents the metadata-driven wizard approach
  - Explains reusability strategy
  - Provides implementation guide
  
- **ADR-0003**: Step Handler Map Pattern
  - Documents the handler map refactoring
  - Explains rationale for moving away from if/else if
  - Provides code examples

---

## 🔍 Key Findings

### Wizard Container Analysis
- `daoWizardContainer` is already generic and reusable
- Accepts `@api wizardApiName` property for dynamic wizard loading
- No hardcoded step references found
- **Conclusion**: Frontend is ready for multi-wizard support

### Persistence Service Issues Found
- Original code only had handlers for 4 of 7 steps
- Three steps (Additional, Services, Documents) would have failed
- `.contains()` matching was fragile and risky
- **Resolution**: Added missing handlers and implemented map pattern

### Metadata Schema
- All 7 wizard steps confirmed in metadata:
  - DAO_Business_InBranch_Applicant
  - DAO_Business_InBranch_Business
  - DAO_Business_InBranch_Product
  - DAO_Business_InBranch_Additional
  - DAO_Business_InBranch_Services
  - DAO_Business_InBranch_Documents
  - DAO_Business_InBranch_Review

---

## 📝 Implementation Notes

### Handler Map Pattern
- Each step requires 3 components:
  1. Private method for business logic (e.g., `upsertApplicantStep`)
  2. Inner class implementing `IStepHandler`
  3. Map entry registering the step's DeveloperName

### Adding New Steps (Future)
```apex
// 1. Create the method
private static PersistenceResponse upsertNewStep(...) {
    // logic here
}

// 2. Create the handler class
private class NewStepHandler implements IStepHandler {
    public PersistenceResponse handle(...) {
        return upsertNewStep(...);
    }
}

// 3. Register in the map
'DAO_Business_InBranch_NewStep' => new NewStepHandler()
```

---

## 🚀 Next Steps

### Immediate
- [x] Deploy refactored service to sandbox
- [x] Create ADRs for architectural decisions
- [x] Update documentation

### Short-term
- [ ] Address Experience Cloud compatibility (Goal #2)
- [ ] Add CSS styling hooks for branding
- [ ] Consider packaging strategy (Unlocked Package?)

### Long-term
- [ ] Create second wizard to validate reusability pattern
- [ ] Build developer onboarding guide
- [ ] Implement automated tests for handler map

---

## 📚 Documentation Created/Updated

### New Files
- `/docs/01-foundation/ARCHITECTURE.md`
- `/docs/04-implementation/architecture-decisions/ADR-0002-configuration-driven-wizard.md`
- `/docs/04-implementation/architecture-decisions/ADR-0003-step-handler-map-pattern.md`
- `/docs/04-implementation/session-notes/2025-11-03-wizard-reusability-refactor.md` (this file)

### Modified Files
- `/force-app/main/default/classes/WizardPersistenceService.cls`

---

## 💡 Lessons Learned

1. **Configuration over Code**: The metadata-driven approach requires more upfront design but pays dividends in maintainability
2. **Exact Matching**: String matching with `.contains()` is dangerous; exact map lookups are safer
3. **Documentation is Critical**: For reusable frameworks, clear documentation is as important as the code itself
4. **Verify Assumptions**: Always check metadata records before assuming step names

---

## 🎓 Knowledge Sharing

### For New Developers
- Read `/docs/01-foundation/ARCHITECTURE.md` first
- Understand the `wizardApiName` pattern
- Review ADR-0002 and ADR-0003 for context

### For Architects
- The pattern is proven and deployed
- Consider this approach for other multi-variant features
- Handler map pattern is reusable beyond wizards

---

**Session Owner**: Development Team  
**Review Status**: Complete  
**Follow-up Required**: Experience Cloud compatibility analysis
