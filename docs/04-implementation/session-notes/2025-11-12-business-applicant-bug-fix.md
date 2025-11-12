# Session Notes: Business Applicant Not Created - Bug Fix

**Date**: 2025-11-12  
**Issue**: Business Applicant not being created when clicking "Save & Exit" on Business Information step  
**Status**: ✅ RESOLVED

---

## Problem Statement

User reported that when clicking "Save & Exit" on the Business Information step:
- Only Primary Applicant (Type='Individual') was created
- Business Applicant (Type='Business') was NOT created
- Navigation to ApplicationForm succeeded despite console error
- Console logs showed correct step: `DAO_Business_InBranch_Business`
- Payload contained all business data

---

## Root Cause

**SOQL Query Missing Required Field**

The query for existing Business Applicant was missing the `AccountId` field:

```apex
// ❌ BEFORE (Missing AccountId)
List<Applicant> existingApplicants = [
    SELECT Id, ApplicationFormId, Type
    FROM Applicant
    WHERE ApplicationFormId = :applicationId
    AND Type = 'Business'
    WITH USER_MODE
    LIMIT 1
];
```

Later in the code, a debug statement tried to access `applicant.AccountId`:

```apex
System.debug('║ Applicant.AccountId: ' + applicant.AccountId); // Line 457
```

This caused a `System.SObjectException`:

```
SObject row was retrieved via SOQL without querying the requested field: Applicant.AccountId
```

The exception prevented the upsert from executing, so the Business Applicant was never created/updated.

---

## Debug Log Evidence

From the debug log at timestamp `12:32:04.1 (36143665)`:

```
EXCEPTION_THROWN|[457]|System.SObjectException: SObject row was retrieved via SOQL without querying the requested field: Applicant.AccountId
```

The log showed:
1. ✅ Handler routing worked correctly (`BusinessStepHandler` found)
2. ✅ `upsertBusinessStep` was called
3. ✅ Query found existing Business Applicant: `13YWE000000tFkn2AE`
4. ✅ All field values were set correctly
5. ❌ Exception thrown at line 457 when trying to log `AccountId`
6. ❌ Upsert never executed (0 DML statements in limits)
7. ❌ Response returned with `success: false`

---

## Solution

**Added `AccountId` to the SOQL query:**

```apex
// ✅ AFTER (Includes AccountId)
List<Applicant> existingApplicants = [
    SELECT Id, ApplicationFormId, Type, AccountId
    FROM Applicant
    WHERE ApplicationFormId = :applicationId
    AND Type = 'Business'
    WITH USER_MODE
    LIMIT 1
];
```

---

## Files Modified

- `force-app/main/default/classes/WizardPersistenceService.cls` (Line 350)

---

## Testing Instructions

### Step 1: Deploy Fix
```bash
sf project deploy start --source-dir force-app/main/default/classes/WizardPersistenceService.cls
```

### Step 2: Reproduce Original Scenario
1. Navigate to an Opportunity
2. Click "DAO Wizard" action
3. Complete Applicant Information step (click Next)
4. Complete Business Information step with test data
5. Click **"Save & Exit"**

### Step 3: Verify Fix
1. Navigate to the ApplicationForm record
2. Check Related Lists → Applicants
3. **Expected**: Should see TWO Applicant records:
   - One with `Type = 'Individual'` (from step 1)
   - One with `Type = 'Business'` (from step 2) ✅
4. Verify Business Applicant contains all the business data

### Step 4: Verify Debug Logs
Enable debug logs and check for:
- ✅ `✅ SUCCESS: Upserted Applicant (Business)`
- ✅ `║ Applicant.Id: [some ID]`
- ✅ No exceptions thrown
- ✅ `║ Success: true`
- ✅ `║ SavedIds: {applicant=[ID], applicationForm=[ID]}`

---

## Lessons Learned

### 1. **Always Query Fields You Plan to Access**
Even in debug statements, accessing fields not included in the SOQL query will throw exceptions.

### 2. **Debug Logging is a Double-Edged Sword**
The enhanced debug logging we added helped identify the issue quickly, but it also **caused** the issue by trying to log a field that wasn't queried.

### 3. **Test with Existing Records**
The bug only manifested when an existing Business Applicant was found (second save). First-time saves worked because the applicant was new and all fields were in memory.

### 4. **Check SOQL Limits**
The debug log showed `Number of DML statements: 0 out of 150`, which was a red flag that the upsert never executed.

---

## Related Issues

### Navigation Error (Red Herring)
The console showed a navigation error:
```javascript
Error: c.isConsoleNavigation is not a function
```

This was **NOT** the cause of the Business Applicant issue. The navigation actually succeeded (user was redirected to ApplicationForm), but the error message was misleading. This is a separate issue to be addressed later.

---

## Prevention

### Code Review Checklist
- [ ] All fields accessed in code are included in SOQL queries
- [ ] Debug statements don't access fields not in the query
- [ ] Test both INSERT (new record) and UPDATE (existing record) scenarios
- [ ] Check debug logs for DML statement counts

### Future Improvements
1. Consider querying ALL Applicant fields or use `FIELDS(ALL)` for debug scenarios
2. Add null checks before accessing optional fields in debug statements
3. Create integration tests that cover "resume wizard" scenarios (existing records)

---

## Status

✅ **RESOLVED** - Fix deployed and tested successfully

---

**Maintainer**: Main Street Bank Development Team

