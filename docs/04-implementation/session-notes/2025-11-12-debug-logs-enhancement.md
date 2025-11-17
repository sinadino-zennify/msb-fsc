# Session Notes: Enhanced Debug Logging for Business Applicant Issue

**Date**: 2025-11-12  
**Issue**: Business Applicant not being created when clicking "Save & Exit" on Business Information step  
**Action**: Added comprehensive debug logging to troubleshoot

---

## Problem Statement

User reported that when clicking "Save & Exit" on the Business Information step:
- Only Primary Applicant (Type='Individual') was created
- Business Applicant (Type='Business') was NOT created
- Navigation to ApplicationForm succeeded despite console error
- Console logs showed correct step: `DAO_Business_InBranch_Business`
- Payload contained all business data

**Initial Hypothesis**: Backend persistence issue, not navigation issue

---

## Debug Logs Added

### 1. Handler Routing Section (Lines 142-174)

Added detailed logging to trace handler lookup and execution:

```apex
System.debug('╔════════════════════════════════════════════════════════════════════════════════');
System.debug('║ HANDLER ROUTING');
System.debug('╠════════════════════════════════════════════════════════════════════════════════');
System.debug('║ Looking up handler for step: "' + stepDeveloperName + '"');
System.debug('║ Available handlers: ' + stepHandlers.keySet());
System.debug('╚════════════════════════════════════════════════════════════════════════════════');
```

**What to look for:**
- Is `stepDeveloperName` = `DAO_Business_InBranch_Business`?
- Is the handler found (not NULL)?
- Which handler is being executed?

### 2. Business Step Entry (Lines 308-315)

Added detailed logging at the start of `upsertBusinessStep`:

```apex
System.debug('╔════════════════════════════════════════════════════════════════════════════════');
System.debug('║ upsertBusinessStep START');
System.debug('╠════════════════════════════════════════════════════════════════════════════════');
System.debug('║ ApplicationId: ' + applicationId);
System.debug('║ Payload keys: ' + payload.keySet());
System.debug('║ Payload size: ' + payload.size());
System.debug('║ Full Payload: ' + JSON.serializePretty(payload));
System.debug('╚════════════════════════════════════════════════════════════════════════════════');
```

**What to look for:**
- Is `upsertBusinessStep` being called at all?
- Is `applicationId` valid (not null)?
- Does payload contain business data?

### 3. Applicant Query Section (Lines 327-353)

Added logging to trace existing Applicant lookup:

```apex
System.debug('🔍 Querying for existing Business Applicant...');
System.debug('🔍 Query WHERE ApplicationFormId = ' + applicationId + ' AND Type = Business');
System.debug('🔍 Query returned ' + existingApplicants.size() + ' records');
```

**What to look for:**
- Is the query executing?
- How many existing Business Applicants found?
- Is a new Applicant being created or existing one updated?

### 4. Upsert Operation (Lines 433-451)

Added detailed logging before and after upsert:

```apex
System.debug('╔════════════════════════════════════════════════════════════════════════════════');
System.debug('║ ABOUT TO UPSERT APPLICANT (Business)');
System.debug('╠════════════════════════════════════════════════════════════════════════════════');
System.debug('║ Applicant.Id: ' + applicant.Id);
System.debug('║ Applicant.ApplicationFormId: ' + applicant.ApplicationFormId);
System.debug('║ Applicant.Type: ' + applicant.Type);
System.debug('║ Applicant.BusinessEntityName: ' + applicant.BusinessEntityName);
System.debug('║ Full Applicant: ' + JSON.serializePretty(applicant));
System.debug('╚════════════════════════════════════════════════════════════════════════════════');
```

**What to look for:**
- Is the upsert statement reached?
- What are the Applicant field values before upsert?
- Does the upsert succeed?
- What is the resulting Applicant.Id?

### 5. Error Handling (Lines 474-482)

Enhanced error logging with line numbers:

```apex
System.debug('╔════════════════════════════════════════════════════════════════════════════════');
System.debug('║ ❌ ERROR in upsertBusinessStep');
System.debug('╠════════════════════════════════════════════════════════════════════════════════');
System.debug('║ Error Message: ' + e.getMessage());
System.debug('║ Exception Type: ' + e.getTypeName());
System.debug('║ Line Number: ' + e.getLineNumber());
System.debug('║ Stack Trace:');
System.debug(e.getStackTraceString());
System.debug('╚════════════════════════════════════════════════════════════════════════════════');
```

**What to look for:**
- Is an exception being thrown?
- What is the error message?
- Which line is failing?

### 6. Final Return (Lines 491-497)

Added logging at method exit:

```apex
System.debug('╔════════════════════════════════════════════════════════════════════════════════');
System.debug('║ upsertBusinessStep FINAL RETURN');
System.debug('║ Success: ' + response.success);
System.debug('║ Messages: ' + response.messages.size());
System.debug('║ SavedIds: ' + response.savedIds);
System.debug('╚════════════════════════════════════════════════════════════════════════════════');
```

**What to look for:**
- Is the method returning success=true?
- Are savedIds populated with applicant ID?
- Are there any error messages?

---

## Debugging Instructions

### Step 1: Enable Debug Logs

1. Go to **Setup** → **Debug Logs**
2. Click **New** to create a new trace flag
3. Set **Traced Entity Type** = User
4. Select your user
5. Set **Debug Level** = SFDC_DevConsole (or create custom with Apex Code = FINEST)
6. Set expiration to 1 hour from now
7. Click **Save**

### Step 2: Reproduce the Issue

1. Navigate to an Opportunity
2. Click "DAO Wizard" action
3. Complete Applicant Information step (click Next)
4. Complete Business Information step with test data:
   - Business Name: "Test Business"
   - DBA: "Test DBA"
   - Business Type: "Corporation"
   - Fill in other required fields
5. Click **"Save & Exit"** (not Next)

### Step 3: Retrieve Debug Log

1. Go to **Setup** → **Debug Logs**
2. Find the most recent log (should be within last few seconds)
3. Click **View**
4. Search for these key markers:

#### Key Search Terms:

1. **`HANDLER ROUTING`** - Verify correct handler is found
2. **`upsertBusinessStep START`** - Verify method is called
3. **`Querying for existing Business Applicant`** - Check query execution
4. **`ABOUT TO UPSERT APPLICANT (Business)`** - Check upsert attempt
5. **`SUCCESS: Upserted Applicant (Business)`** - Verify success
6. **`ERROR in upsertBusinessStep`** - Check for errors
7. **`upsertBusinessStep FINAL RETURN`** - Check final state

### Step 4: Analyze Results

#### Scenario A: Handler Not Found
```
║ Looking up handler for step: "DAO_Business_InBranch_Business"
🎯 Handler found: NULL
```
**Issue**: Handler mapping is broken
**Fix**: Check stepHandlers map in WizardPersistenceService

#### Scenario B: Wrong Step Name
```
║ Looking up handler for step: "DAO_Business_InBranch_Applicant"
```
**Issue**: LWC sending wrong step name
**Fix**: Check daoWizardContainer.js currentStep.developerName

#### Scenario C: Method Not Called
```
(No "upsertBusinessStep START" log found)
```
**Issue**: Handler routing failed or wrong handler called
**Fix**: Check handler.handle() execution

#### Scenario D: Upsert Failed
```
║ ABOUT TO UPSERT APPLICANT (Business)
❌ ERROR in upsertBusinessStep
║ Error Message: [error details]
```
**Issue**: DML error or validation failure
**Fix**: Check error message for specific issue

#### Scenario E: Success But No Record
```
✅ SUCCESS: Upserted Applicant (Business)
║ Applicant.Id: a0XWE000000XXXXX
```
**Issue**: Upsert succeeded, record should exist
**Fix**: Query Applicant object to verify record exists

---

## Expected Debug Log Flow (Success Case)

```
=== WizardPersistenceService.upsertStep START ===
Input stepDeveloperName: DAO_Business_InBranch_Business
Input applicationId: 13XWE000000a0EP2AY

╔════════════════════════════════════════════════════════════════════════════════
║ HANDLER ROUTING
╠════════════════════════════════════════════════════════════════════════════════
║ Looking up handler for step: "DAO_Business_InBranch_Business"
║ Available handlers: {DAO_Business_InBranch_Applicant, DAO_Business_InBranch_Business, ...}
╚════════════════════════════════════════════════════════════════════════════════
🎯 Handler found: WizardPersistenceService.BusinessStepHandler@...

╔════════════════════════════════════════════════════════════════════════════════
║ upsertBusinessStep START
╠════════════════════════════════════════════════════════════════════════════════
║ ApplicationId: 13XWE000000a0EP2AY
║ Payload keys: {businessName, dbaName, businessType, ...}
║ Payload size: 25
╚════════════════════════════════════════════════════════════════════════════════

🔍 Querying for existing Business Applicant...
🔍 Query returned 0 records
🆕 Creating new Applicant (Business)

╔════════════════════════════════════════════════════════════════════════════════
║ ABOUT TO UPSERT APPLICANT (Business)
╠════════════════════════════════════════════════════════════════════════════════
║ Applicant.ApplicationFormId: 13XWE000000a0EP2AY
║ Applicant.Type: Business
║ Applicant.BusinessEntityName: Test Business
╚════════════════════════════════════════════════════════════════════════════════

╔════════════════════════════════════════════════════════════════════════════════
║ ✅ SUCCESS: Upserted Applicant (Business)
╠════════════════════════════════════════════════════════════════════════════════
║ Applicant.Id: a0XWE000000XXXXX
║ Operation: INSERT
╚════════════════════════════════════════════════════════════════════════════════

╔════════════════════════════════════════════════════════════════════════════════
║ upsertBusinessStep FINAL RETURN
║ Success: true
║ SavedIds: {applicant=a0XWE000000XXXXX, applicationForm=13XWE000000a0EP2AY}
╚════════════════════════════════════════════════════════════════════════════════
```

---

## Files Modified

- `force-app/main/default/classes/WizardPersistenceService.cls`

---

## Next Steps

1. Deploy updated WizardPersistenceService to sandbox
2. Enable debug logs for your user
3. Reproduce the issue
4. Analyze debug logs using search terms above
5. Report findings to determine root cause

---

**Maintainer**: Main Street Bank Development Team

