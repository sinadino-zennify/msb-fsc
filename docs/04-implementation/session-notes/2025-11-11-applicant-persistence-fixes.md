# Session Notes: Applicant Persistence & Context Record Fixes

**Date**: 2025-11-11  
**Issues Fixed**: 
1. ApplicationForm not linking to Opportunity/Account when wizard launched from those records
2. Duplicate Applicant records created when navigating back and updating data

---

## Problem Statement

### Issue #1: Missing Context Record Lookups
When starting the wizard from an Opportunity or Account record:
- `ApplicationForm.OpportunityId` was not being set when launched from Opportunity
- `ApplicationForm.AccountId` was not being set when launched from Account or Opportunity
- This broke the relationship between the ApplicationForm and the originating record

### Issue #2: Duplicate Applicant Records
When navigating back to a previously completed step (e.g., Applicant Information) and updating data:
- The system would create a NEW Applicant record instead of updating the existing one
- This resulted in multiple Applicant records for the same ApplicationForm
- Root cause: No query for existing Applicant records before upserting

---

## Root Cause Analysis

### Issue #1: Context Not Passed to Apex
The LWC `daoWizardContainer` was passing `this.recordId` (the Opportunity/Account context) but the Apex method `upsertStep` had no parameter to receive it. The `createApplicationForm` method had no way to know which Opportunity or Account the wizard was launched from.

### Issue #2: Missing Upsert Logic
The `upsertApplicantStep` and `upsertBusinessStep` methods were creating new `Applicant` objects without first checking if one already existed for the given `ApplicationFormId` and `Type` combination.

---

## Solution Implemented

### Fix #1: Pass Context Record to Apex

#### Changes to `WizardPersistenceService.cls`

1. **Updated method signature** to accept `contextRecordId`:
```apex
@AuraEnabled(cacheable=false)
public static PersistenceResponse upsertStep(
    Id applicationId, 
    String stepDeveloperName, 
    Map<String, Object> payload, 
    Id contextRecordId  // NEW PARAMETER
)
```

2. **Updated `createApplicationForm` method** to set lookups based on context:
```apex
private static ApplicationForm createApplicationForm(
    Map<String, Object> payload, 
    Id contextRecordId  // NEW PARAMETER
) {
    ApplicationForm app = new ApplicationForm();
    
    // ... existing code ...
    
    // Set context lookups based on the record the wizard was launched from
    if (contextRecordId != null) {
        String objectType = contextRecordId.getSObjectType().getDescribe().getName();
        
        if (objectType == 'Opportunity') {
            app.OpportunityId = contextRecordId;
            
            // Also query and set AccountId from the Opportunity
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :contextRecordId WITH USER_MODE LIMIT 1];
            if (opp.AccountId != null) {
                app.AccountId = opp.AccountId;
            }
        } else if (objectType == 'Account') {
            app.AccountId = contextRecordId;
        }
    }
    
    return app;
}
```

#### Changes to `daoWizardContainer.js`

Updated both `handleNext()` and `handleSaveAndExit()` to pass `contextRecordId`:

```javascript
const persistenceResult = await upsertStep({
    applicationId: this.applicationFormId,
    stepDeveloperName: this.currentStep.developerName,
    payload: payload,
    contextRecordId: this.recordId  // NEW PARAMETER
});
```

### Fix #2: Query Existing Applicants Before Upserting

#### Changes to `upsertApplicantStep` method

Added query for existing Applicant records before creating new ones:

```apex
// Query for existing Applicant record (Type='Individual') for this ApplicationForm
Applicant applicant = null;
List<Applicant> existingApplicants = [
    SELECT Id, ApplicationFormId, Type
    FROM Applicant
    WHERE ApplicationFormId = :applicationId
    AND Type = 'Individual'
    WITH USER_MODE
    LIMIT 1
];

if (!existingApplicants.isEmpty()) {
    applicant = existingApplicants[0];
    System.debug('Found existing Applicant (Individual) with ID: ' + applicant.Id);
} else {
    applicant = new Applicant();
    applicant.ApplicationFormId = applicationId;
    applicant.Type = 'Individual';
    System.debug('Creating new Applicant (Individual)');
}
```

#### Changes to `upsertBusinessStep` method

Added similar query logic for Business Applicants:

```apex
// Query for existing Applicant record (Type='Business') for this ApplicationForm
Applicant applicant = null;
List<Applicant> existingApplicants = [
    SELECT Id, ApplicationFormId, Type
    FROM Applicant
    WHERE ApplicationFormId = :applicationId
    AND Type = 'Business'
    WITH USER_MODE
    LIMIT 1
];

if (!existingApplicants.isEmpty()) {
    applicant = existingApplicants[0];
    System.debug('Found existing Applicant (Business) with ID: ' + applicant.Id);
} else {
    applicant = new Applicant();
    applicant.ApplicationFormId = applicationId;
    applicant.Type = 'Business';
    System.debug('Creating new Applicant (Business)');
}
```

---

## Test Coverage

### New Test Methods Added to `WizardPersistenceServiceTest.cls`

1. **`testUpsertStep_WithOpportunityContext()`**
   - Verifies ApplicationForm.OpportunityId is set when wizard launched from Opportunity
   - Verifies ApplicationForm.AccountId is set from Opportunity.AccountId

2. **`testUpsertStep_WithAccountContext()`**
   - Verifies ApplicationForm.AccountId is set when wizard launched from Account

3. **`testUpsertApplicant_PreventsDuplicates()`**
   - Creates an Applicant on first step save
   - Updates the same Applicant on second step save
   - Verifies only ONE Applicant record exists (no duplicates)
   - Verifies the Applicant data is updated correctly

### Updated Existing Tests

All existing test methods updated to pass `null` for the new `contextRecordId` parameter to maintain backward compatibility.

---

## Files Modified

### Apex Classes
- `force-app/main/default/classes/WizardPersistenceService.cls`
- `force-app/main/default/classes/WizardPersistenceServiceTest.cls`

### LWC Components
- `force-app/main/default/lwc/daoWizardContainer/daoWizardContainer.js`

---

## Validation Steps

### Manual Testing Checklist

#### Issue #1: Context Record Lookups
- [ ] Launch wizard from Opportunity → verify ApplicationForm.OpportunityId is set
- [ ] Launch wizard from Opportunity → verify ApplicationForm.AccountId is set to Opportunity.AccountId
- [ ] Launch wizard from Account → verify ApplicationForm.AccountId is set
- [ ] Launch wizard from App (no context) → verify no errors, lookups remain null

#### Issue #2: Prevent Duplicate Applicants
- [ ] Complete Applicant Information step → verify 1 Applicant created
- [ ] Navigate back to Applicant Information step
- [ ] Update email address
- [ ] Click Next or Save & Exit
- [ ] Query Applicants for ApplicationForm → verify still only 1 Applicant
- [ ] Verify email was updated on existing Applicant

#### Business Step Testing
- [ ] Complete Business Information step → verify 1 Applicant (Type='Business') created
- [ ] Navigate back to Business Information step
- [ ] Update business name
- [ ] Click Next or Save & Exit
- [ ] Query Applicants for ApplicationForm → verify still only 1 Business Applicant
- [ ] Verify business name was updated

---

## Deployment Notes

### Breaking Change
The `upsertStep` method signature has changed. Any direct callers of this method must be updated to pass the new `contextRecordId` parameter.

### Backward Compatibility
Passing `null` for `contextRecordId` maintains backward compatibility - the ApplicationForm will be created without context lookups (same as before).

---

## Related Requirements

- **ST-002**: Persist Application Data (fixes duplicate Applicant issue)
- **ST-003**: Pre-populate Wizard Data from Entry Points (enables future pre-population based on context record)

---

## Next Steps

1. Deploy changes to sandbox
2. Execute manual validation checklist
3. Run Apex test suite to verify 100% coverage maintained
4. Deploy to production after validation

---

**Maintainer**: Main Street Bank Development Team

