# Field Mapping Analysis: Account → Wizard Pre-Population

**Date**: 2025-11-13 (Updated after address investigation)  
**Purpose**: Comprehensive analysis of field mappings from Account/PersonAccount to Wizard components  
**Status**: 🔍 ANALYSIS ONLY - NO CODE CHANGES YET

---

## Executive Summary

This document maps every field from the Salesforce Account object through the entire data flow:
1. **Account Object** (Source)
2. **WizardDataService SOQL Query** (Retrieval)
3. **DTO Mapping** (Apex → LWC)
4. **LWC Component Properties** (Display)

### 🎯 Quick Summary

**13 Confirmed Issues Found**:
- ❌ **6 fields** missing from SOQL query (user confirmed to add)
- ❌ **7 fields** queried but not mapped in Apex (including `Date_Established__c` bug)
- 🔍 **Address pre-population** not working (needs console log analysis)

**User-Confirmed Fields to Add**:
1. `Business_Tax_ID__c` ✅ (already in query)
2. `Doing_Business_As__c` ✅ (to add)
3. `Business_Registration_State__c` ✅ (to add)
4. `Business_Mobile_Phone__c` ✅ (to add)
5. `Business_Home_Phone__c` ✅ (to add)
6. `Business_Email__c` ✅ (to add)
7. `Business_Phone__c` ✅ (to add)

---

## 🔴 CRITICAL GAPS IDENTIFIED

### Missing from SOQL Query
These fields exist on Account but are **NOT** being queried:

| Field API Name | Purpose | Used In | User Confirmed |
|---------------|---------|---------|----------------|
| `Business_Tax_ID_Type__c` | Business Tax ID Type | BusinessInfoDTO | ❌ No |
| `Doing_Business_As__c` | DBA Name | BusinessInfoDTO | ✅ YES |
| `Business_Registration_State__c` | State of Incorporation | BusinessInfoDTO | ✅ YES |
| `Business_Phone__c` | Business Phone | BusinessInfoDTO | ✅ YES |
| `Business_Email__c` | Business Email | BusinessInfoDTO | ✅ YES |
| `Business_Home_Phone__c` | Business Home Phone | BusinessInfoDTO | ✅ YES |
| `Business_Mobile_Phone__c` | Business Mobile Phone | BusinessInfoDTO | ✅ YES |

**Note**: User requested `Doing_Business_As__c` (not `SW_Doing_Business_As__c`) and `Business_Registration_State__c` (not `SW_State_of_Formation__c`).

### Incorrectly Mapped Fields in Apex
These fields are queried but **NOT** assigned to DTO properties:

| Account Field | Current Apex Code | Issue | Impact |
|--------------|-------------------|-------|--------|
| `Date_Established__c` | `info.dateEstablished = null;` | 🔴 Set to null despite being queried! | Date not pre-filled |
| `Business_Tax_ID__c` | ✅ Mapped correctly | - | Working |
| `Type` | ✅ Used as fallback | - | Working |
| **Government ID fields (6)** | ❌ Not mapped to BusinessInfoDTO | 🔴 Missing mapping | Gov ID not pre-filled for Business |

### Address Pre-Population Issue 🔍

**Root Cause Identified**: Addresses ARE being queried and mapped correctly in Apex, but there may be:
1. **Data Issue**: Fields might be empty in the org
2. **Console Log Issue**: Need to verify what data is actually returned from `getWizardData`
3. **LWC Application Issue**: The `applyValue` methods in both LWC components look correct

**Address Mapping Status**:
- ✅ PersonAccount addresses: Queried (lines 87-91), Mapped (lines 248-254), LWC ready (lines 540-545)
- ✅ Business Account addresses: Queried (lines 69-73), Mapped (lines 221-227), LWC ready (lines 840-845)

---

## 📊 COMPLETE FIELD MAPPING TABLES

### SECTION 1: PersonAccount → ApplicantInfo (Individual)

#### Personal Identity Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `Salutation` | ✅ Line 92 | `salutation` | `salutation` | ✅ MAPPED |
| `FirstName` | ✅ Line 93 | `firstName` | `firstName` | ✅ MAPPED |
| `LastName` | ✅ Line 94 | `lastName` | `lastName` | ✅ MAPPED |
| `PersonBirthdate` | ✅ Line 83 | `birthDate` | `dateOfBirth` | ✅ MAPPED |
| `SSN_Tax_Id__c` | ✅ Line 95 | `taxId` | `taxId` | ✅ MAPPED |
| `Tax_ID_Type__c` | ✅ Line 96 | `taxIdType` | `taxIdType` | ✅ MAPPED |

**Apex Mapping** (`buildApplicantFromPersonAccount`, lines 235-263):
```apex
applicant.salutation = personAccount.Salutation;
applicant.firstName = personAccount.FirstName;
applicant.lastName = personAccount.LastName;
applicant.birthDate = formatDate(personAccount.PersonBirthdate);
applicant.taxId = personAccount.SSN_Tax_Id__c;
applicant.taxIdType = personAccount.Tax_ID_Type__c;
```

#### Contact Information Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `PersonEmail` | ✅ Line 84 | `email` | `email` | ✅ MAPPED |
| `PersonMobilePhone` | ✅ Line 85 | `mobilePhone` | `mobilePhone` | ✅ MAPPED |
| `PersonHomePhone` | ✅ Line 86 | `homePhone` | `homePhone` | ✅ MAPPED |
| `Phone` | ✅ Line 64 | `workPhone` | `workPhone` | ✅ MAPPED |

**Apex Mapping** (lines 243-246):
```apex
applicant.email = personAccount.PersonEmail;
applicant.mobilePhone = personAccount.PersonMobilePhone;
applicant.homePhone = personAccount.PersonHomePhone;
applicant.workPhone = personAccount.Phone;
```

#### Mailing Address Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `PersonMailingStreet` | ✅ Line 87 | `mailingStreetLine1` | `mailingStreetLine1` | ✅ MAPPED |
| `PersonMailingStreet` | ✅ Line 87 | `mailingStreetLine2` | `mailingStreetLine2` | ✅ MAPPED (split) |
| `PersonMailingCity` | ✅ Line 88 | `mailingCity` | `mailingCity` | ✅ MAPPED |
| `PersonMailingState` | ✅ Line 89 | `mailingState` | `mailingState` | ✅ MAPPED |
| `PersonMailingPostalCode` | ✅ Line 90 | `mailingPostalCode` | `mailingPostalCode` | ✅ MAPPED |
| `PersonMailingCountry` | ✅ Line 91 | `mailingCountry` | `mailingCountry` | ✅ MAPPED |

**Apex Mapping** (lines 248-254):
```apex
String[] streetLines = splitStreet(personAccount.PersonMailingStreet);
applicant.mailingStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
applicant.mailingStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
applicant.mailingCity = personAccount.PersonMailingCity;
applicant.mailingState = personAccount.PersonMailingState;
applicant.mailingPostalCode = personAccount.PersonMailingPostalCode;
applicant.mailingCountry = personAccount.PersonMailingCountry;
```

#### Government ID Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `Government_ID_Type__c` | ✅ Line 97 | `governmentIdType` | `governmentIdType` | ✅ MAPPED |
| `Government_ID_Number__c` | ✅ Line 98 | `governmentIdNumber` | `governmentIdNumber` | ✅ MAPPED |
| `ID_Issuing_Country__c` | ✅ Line 99 | `idIssuingCountry` | `idIssuingCountry` | ✅ MAPPED |
| `ID_Issuing_State__c` | ✅ Line 100 | `idIssuingState` | `idIssuingState` | ✅ MAPPED |
| `ID_Issue_Date__c` | ✅ Line 101 | `idIssueDate` | `idIssueDate` | ✅ MAPPED |
| `ID_Expiration_Date__c` | ✅ Line 102 | `idExpirationDate` | `idExpirationDate` | ✅ MAPPED |

**Apex Mapping** (lines 256-261):
```apex
applicant.governmentIdType = personAccount.Government_ID_Type__c;
applicant.governmentIdNumber = personAccount.Government_ID_Number__c;
applicant.idIssuingCountry = personAccount.ID_Issuing_Country__c;
applicant.idIssuingState = personAccount.ID_Issuing_State__c;
applicant.idIssueDate = formatDate(personAccount.ID_Issue_Date__c);
applicant.idExpirationDate = formatDate(personAccount.ID_Expiration_Date__c);
```

---

### SECTION 2: Business Account → BusinessInfo

#### Business Identity Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `Name` | ✅ Line 63 | `businessName` | `businessName` | ✅ MAPPED |
| `Doing_Business_As__c` | ❌ **MISSING** | `dbaName` | `dbaName` | 🔴 **NOT QUERIED** (User confirmed) |
| `Business_Type__c` | ✅ Line 65 | `businessType` | `businessType` | ✅ MAPPED (primary) |
| `Type` | ✅ Line 66 | `businessType` | `businessType` | ✅ MAPPED (fallback) |
| `Business_Tax_ID__c` | ✅ Line 67 | `taxId` | `taxId` | ✅ MAPPED |
| `Business_Tax_ID_Type__c` | ❌ **MISSING** | N/A | N/A | 🔴 **NOT QUERIED** (Not confirmed by user) |
| `Date_Established__c` | ✅ Line 78 | `dateEstablished` | `dateEstablished` | 🔴 **QUERIED BUT SET TO NULL!** |
| `Business_Registration_State__c` | ❌ **MISSING** | `stateOfIncorporation` | `stateOfIncorporation` | 🔴 **NOT QUERIED** (User confirmed) |

**Apex Mapping** (`buildBusinessInfoFromAccount`, lines 194-233):
```apex
info.businessName = acc.Name;
info.dbaName = null; // 🔴 WRONG: Should use Doing_Business_As__c (user confirmed)
info.businessType = String.isNotBlank(acc.Business_Type__c) ? acc.Business_Type__c : acc.Type;
info.taxId = acc.Business_Tax_ID__c;
info.dateEstablished = null; // 🔴 WRONG: Date_Established__c is queried but not used!
info.stateOfIncorporation = null; // 🔴 WRONG: Should use Business_Registration_State__c (user confirmed)
```

#### Industry & Classification Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `NAICS_Lookup__c` | ✅ Line 79 | `naicsCodeId` | `naicsCodeId` | ✅ MAPPED |
| `NAICS_Code__c` | ✅ Line 80 | `naicsCode` | `naicsCode` | ✅ MAPPED |
| `NAICS_Description__c` | ✅ Line 81 | `naicsDescription` | `naicsDescription` | ✅ MAPPED |
| `Industry` | ✅ Line 76 | `industryType` | `industryType` | ✅ MAPPED |
| `Description` | ✅ Line 77 | `businessDescription` | `businessDescription` | ✅ MAPPED |

**Apex Mapping** (lines 206-210):
```apex
info.naicsCodeId = acc.NAICS_Lookup__c;
info.naicsCode = acc.NAICS_Code__c;
info.naicsDescription = acc.NAICS_Description__c;
info.industryType = acc.Industry;
info.businessDescription = acc.Description;
```

#### Contact Information Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `Business_Phone__c` | ❌ **MISSING** | `businessPhone` | `businessPhone` | 🔴 **NOT QUERIED** (User confirmed) |
| `Phone` | ✅ Line 64 | `businessPhone` | `businessPhone` | ✅ MAPPED (fallback) |
| `Business_Email__c` | ❌ **MISSING** | `businessEmail` | `businessEmail` | 🔴 **NOT QUERIED** (User confirmed) |
| `Business_Home_Phone__c` | ❌ **MISSING** | `businessHomePhone` | `businessHomePhone` | 🔴 **NOT QUERIED** (User confirmed) |
| `Business_Mobile_Phone__c` | ❌ **MISSING** | `businessMobilePhone` | `businessMobilePhone` | 🔴 **NOT QUERIED** (User confirmed) |
| `Website` | ✅ Line 68 | `businessWebsite` | `businessWebsite` | ✅ MAPPED |

**Apex Mapping** (lines 212-216):
```apex
info.businessPhone = String.isNotBlank(acc.Business_Phone__c) ? acc.Business_Phone__c : acc.Phone;
// 🔴 WRONG: Business_Phone__c referenced but not in SOQL query! (User confirmed to add)
info.businessEmail = acc.Business_Email__c; // 🔴 WRONG: Not in SOQL query! (User confirmed to add)
info.businessHomePhone = acc.Business_Home_Phone__c; // 🔴 WRONG: Not in SOQL query! (User confirmed to add)
info.businessMobilePhone = acc.Business_Mobile_Phone__c; // 🔴 WRONG: Not in SOQL query! (User confirmed to add)
info.businessWebsite = acc.Website;
```

#### Financial & Operational Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `AnnualRevenue` | ✅ Line 74 | `annualRevenue` | `annualRevenue` | ✅ MAPPED |
| `NumberOfEmployees` | ✅ Line 75 | `numberOfEmployees` | `numberOfEmployees` | ✅ MAPPED (converted) |

**Apex Mapping** (lines 218-219):
```apex
info.annualRevenue = acc.AnnualRevenue;
info.numberOfEmployees = convertEmployeeCountToRange(acc.NumberOfEmployees);
```

#### Business Address Fields

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `BillingStreet` | ✅ Line 69 | `businessStreetLine1` | `businessStreetLine1` | ✅ MAPPED |
| `BillingStreet` | ✅ Line 69 | `businessStreetLine2` | `businessStreetLine2` | ✅ MAPPED (split) |
| `BillingCity` | ✅ Line 70 | `businessCity` | `businessCity` | ✅ MAPPED |
| `BillingState` | ✅ Line 71 | `businessState` | `businessState` | ✅ MAPPED |
| `BillingPostalCode` | ✅ Line 72 | `businessPostalCode` | `businessPostalCode` | ✅ MAPPED |
| `BillingCountry` | ✅ Line 73 | `businessCountry` | `businessCountry` | ✅ MAPPED |

**Apex Mapping** (lines 221-227):
```apex
String[] streetLines = splitStreet(acc.BillingStreet);
info.businessStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
info.businessStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
info.businessCity = acc.BillingCity;
info.businessState = acc.BillingState;
info.businessPostalCode = acc.BillingPostalCode;
info.businessCountry = acc.BillingCountry;
```

#### Government ID Fields (Authorized Signer)

| Account Field API Name | SOQL Query | DTO Property | LWC Property | Status |
|------------------------|------------|--------------|--------------|--------|
| `Government_ID_Type__c` | ✅ Line 97 | `governmentIdType` | `governmentIdType` | ⚠️ **NOT MAPPED IN DTO** |
| `Government_ID_Number__c` | ✅ Line 98 | `governmentIdNumber` | `governmentIdNumber` | ⚠️ **NOT MAPPED IN DTO** |
| `ID_Issuing_Country__c` | ✅ Line 99 | `idIssuingCountry` | `idIssuingCountry` | ⚠️ **NOT MAPPED IN DTO** |
| `ID_Issuing_State__c` | ✅ Line 100 | `idIssuingState` | `idIssuingState` | ⚠️ **NOT MAPPED IN DTO** |
| `ID_Issue_Date__c` | ✅ Line 101 | `idIssueDate` | `idIssueDate` | ⚠️ **NOT MAPPED IN DTO** |
| `ID_Expiration_Date__c` | ✅ Line 102 | `idExpirationDate` | `idExpirationDate` | ⚠️ **NOT MAPPED IN DTO** |

**Apex Mapping** (`buildBusinessInfoFromAccount`, lines 194-233):
```apex
// ❌ MISSING: No mapping for Government ID fields in BusinessInfoDTO!
// These fields are queried but never assigned to the DTO
```

---

### SECTION 3: Business Account → ApplicantInfo (Primary Contact)

When a Business Account has a Primary Contact (`FinServ__PrimaryContact__c`), the system queries Contact fields and also re-queries Account fields through the Contact relationship.

#### Contact Fields Queried (lines 125-166)

| Contact Field API Name | DTO Property | LWC Property | Status |
|------------------------|--------------|--------------|--------|
| `Salutation` | `salutation` | `salutation` | ✅ MAPPED |
| `FirstName` | `firstName` | `firstName` | ✅ MAPPED |
| `LastName` | `lastName` | `lastName` | ✅ MAPPED |
| `Birthdate` | `birthDate` | `dateOfBirth` | ✅ MAPPED |
| `Email` | `email` | `email` | ✅ MAPPED |
| `Phone` | `workPhone` | `workPhone` | ✅ MAPPED |
| `MobilePhone` | `mobilePhone` | `mobilePhone` | ✅ MAPPED |
| `HomePhone` | `homePhone` | `homePhone` | ✅ MAPPED |
| `MailingStreet` | `mailingStreetLine1/2` | `mailingStreetLine1/2` | ✅ MAPPED |
| `MailingCity` | `mailingCity` | `mailingCity` | ✅ MAPPED |
| `MailingState` | `mailingState` | `mailingState` | ✅ MAPPED |
| `MailingPostalCode` | `mailingPostalCode` | `mailingPostalCode` | ✅ MAPPED |
| `MailingCountry` | `mailingCountry` | `mailingCountry` | ✅ MAPPED |

**Note**: The Contact query also includes `Account.*` fields (lines 142-161) for Person Account detection, but these are only used if the Contact's Account is a PersonAccount.

---

## 🔧 RECOMMENDED FIXES (User Confirmed)

### Fix 1: Add Missing Fields to SOQL Query

**File**: `WizardDataService.cls`, lines 60-107

Add these fields to the SOQL query (after line 68, before `BillingStreet`):

```apex
// After line 68 (Website), add:
Business_Phone__c,
Business_Email__c,
Business_Home_Phone__c,
Business_Mobile_Phone__c,
Doing_Business_As__c,
Business_Registration_State__c,
```

**Note**: User confirmed to use `Doing_Business_As__c` (not `SW_Doing_Business_As__c`) and `Business_Registration_State__c` (not `SW_State_of_Formation__c`).

### Fix 2: Update `buildBusinessInfoFromAccount` Method

**File**: `WizardDataService.cls`, lines 194-233

Replace the null assignments with actual field mappings:

```apex
// Line 200 - Replace:
info.dbaName = null;
// With:
info.dbaName = acc.Doing_Business_As__c;

// Line 203 - Replace:
info.dateEstablished = null;
// With:
info.dateEstablished = formatDate(acc.Date_Established__c);

// Line 204 - Replace:
info.stateOfIncorporation = null;
// With:
info.stateOfIncorporation = acc.Business_Registration_State__c;

// Lines 212-215 - No code changes needed (already correct), 
// but ensure fields are in SOQL query (Fix 1 above)
info.businessPhone = String.isNotBlank(acc.Business_Phone__c) ? acc.Business_Phone__c : acc.Phone;
info.businessEmail = acc.Business_Email__c;
info.businessHomePhone = acc.Business_Home_Phone__c;
info.businessMobilePhone = acc.Business_Mobile_Phone__c;
```

### Fix 3: Add Government ID Mapping to BusinessInfoDTO

**File**: `WizardDataService.cls`, lines 194-233

Add these lines after line 227 (before the return statement):

```apex
// Government ID fields (Authorized Signer)
info.governmentIdType = acc.Government_ID_Type__c;
info.governmentIdNumber = acc.Government_ID_Number__c;
info.idIssuingCountry = acc.ID_Issuing_Country__c;
info.idIssuingState = acc.ID_Issuing_State__c;
info.idIssueDate = formatDate(acc.ID_Issue_Date__c);
info.idExpirationDate = formatDate(acc.ID_Expiration_Date__c);
```

### Fix 4: Verify BusinessInfoDTO Properties

**File**: `WizardDataService.cls`, lines 355-392

Confirm these properties exist in `BusinessInfoDTO` (they already do, lines 386-391):

```apex
@AuraEnabled public String governmentIdType;
@AuraEnabled public String governmentIdNumber;
@AuraEnabled public String idIssuingCountry;
@AuraEnabled public String idIssuingState;
@AuraEnabled public String idIssueDate;
@AuraEnabled public String idExpirationDate;
```

---

## 📋 VALIDATION CHECKLIST

Use this checklist to validate the mappings after fixes are applied:

### PersonAccount → ApplicantInfo
- [ ] Personal Identity (6 fields)
- [ ] Contact Information (4 fields)
- [ ] Mailing Address (6 fields)
- [ ] Government ID (6 fields)

### Business Account → BusinessInfo
- [ ] Business Identity (8 fields) - **3 currently broken**
- [ ] Industry & Classification (5 fields)
- [ ] Contact Information (6 fields) - **4 currently broken**
- [ ] Financial & Operational (2 fields)
- [ ] Business Address (6 fields)
- [ ] Government ID (6 fields) - **6 currently broken**

### Business Account → ApplicantInfo (via Primary Contact)
- [ ] Personal Identity (4 fields)
- [ ] Contact Information (4 fields)
- [ ] Mailing Address (6 fields)
- [ ] Government ID (0 fields) - **Not available on Contact**

---

## 🔍 ADDRESS PRE-POPULATION INVESTIGATION

### Current State Analysis - VERIFIED ✅

**SOQL Query (WizardDataService.cls, lines 55-107)**:
```apex
SELECT Id,
       IsPersonAccount,
       Name,
       // ... other fields ...
       BillingStreet,        // ✅ Line 69
       BillingCity,          // ✅ Line 70
       BillingState,         // ✅ Line 71
       BillingPostalCode,    // ✅ Line 72
       BillingCountry,       // ✅ Line 73
       // ... other fields ...
       PersonMailingStreet,  // ✅ Line 87
       PersonMailingCity,    // ✅ Line 88
       PersonMailingState,   // ✅ Line 89
       PersonMailingPostalCode, // ✅ Line 90
       PersonMailingCountry  // ✅ Line 91
FROM Account
WHERE Id = :accountId
```

**PersonAccount Addresses** (Now using BillingAddress):
- ✅ **SOQL Query**: Lines 69-73 query all `Billing*` fields (shared with Business Accounts)
- ✅ **Apex Mapping**: Lines 244-250 now use `BillingAddress` fields for PersonAccounts
  ```apex
  // Use BillingAddress for both PersonAccount and Business Account
  String[] streetLines = splitStreet(personAccount.BillingStreet);
  applicant.mailingStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
  applicant.mailingStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
  applicant.mailingCity = personAccount.BillingCity;
  applicant.mailingState = personAccount.BillingState;
  applicant.mailingPostalCode = personAccount.BillingPostalCode;
  applicant.mailingCountry = personAccount.BillingCountry;
  ```
- ✅ **LWC Component**: Lines 540-545 in `applicantDetails.js` correctly apply values
- ✅ **Code Flow**: Complete and correct
- 🔄 **CHANGED**: Now using BillingAddress instead of PersonMailingAddress

**Business Account Addresses** (Billing):
- ✅ **SOQL Query**: Lines 69-73 query all `Billing*` fields
- ✅ **Apex Mapping**: Lines 221-227 correctly map to `BusinessInfoDTO`
  ```apex
  String[] streetLines = splitStreet(acc.BillingStreet);
  info.businessStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
  info.businessStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
  info.businessCity = acc.BillingCity;
  info.businessState = acc.BillingState;
  info.businessPostalCode = acc.BillingPostalCode;
  info.businessCountry = acc.BillingCountry;
  ```
- ✅ **LWC Component**: Lines 840-845 in `businessDetails.js` correctly apply values
- ✅ **Code Flow**: Complete and correct

### Possible Root Causes for Missing Addresses

1. **Data Issue**: The Account records in the org may have empty address fields
   - **Test**: Check if `PersonMailingStreet`, `PersonMailingCity`, etc. have values in the org
   - **Test**: Check if `BillingStreet`, `BillingCity`, etc. have values in the org

2. **Console Log Analysis Needed**: We added debug logs to trace data flow
   - Check browser console for `🔍 getWizardData RESULT:` log
   - Verify if `applicantInfo.mailingCity` and `businessInfo.businessCity` have values
   - Check if `applyValue` is being called with address data

3. **Timing Issue**: The `applyValue` might be called before data is loaded
   - The `hasAppliedInitialValue` flag should prevent duplicate applications
   - The `value` setter should trigger `applyValue` when data arrives

### Recommended Next Steps

1. **Run the wizard** from a PersonAccount and Business Account
2. **Open browser console** and look for these logs:
   ```
   🔍 getWizardData RESULT: { ... }
   🔍 Setting applicantInfo payload: { ... }
   🔍 Setting businessInfo payload: { ... }
   🔍 ApplicantDetails value setter called with: { ... }
   🔍 ApplicantDetails applyValue called with: { ... }
   🔍 ApplicantDetails fields after apply: { ... }
   ```
3. **Share the console output** so we can identify where addresses are being lost

---

## 🎯 SUMMARY OF ISSUES

| Issue | Count | Severity | User Confirmed |
|-------|-------|----------|----------------|
| Fields not queried in SOQL | 6 | 🔴 HIGH | ✅ YES |
| Fields queried but not mapped in Apex | 7 | 🔴 HIGH | ✅ YES (includes Date_Established__c) |
| Address pre-population not working | ? | 🟠 MEDIUM | 🔍 Under Investigation |
| **Total Known Issues** | **13** | | |

**Breakdown**:
- 6 fields to add to SOQL: `Business_Phone__c`, `Business_Email__c`, `Business_Home_Phone__c`, `Business_Mobile_Phone__c`, `Doing_Business_As__c`, `Business_Registration_State__c`
- 7 fields to map in Apex: 3 Business Identity fields + 6 Government ID fields (for Business)
- Address issue: Needs console log analysis to diagnose

---

## 📝 NOTES

1. **Field Name Corrections**: User confirmed to use `Doing_Business_As__c` (not `SW_Doing_Business_As__c`) and `Business_Registration_State__c` (not `SW_State_of_Formation__c`).

2. **Date Established Bug**: The field `Date_Established__c` is queried (line 78) but explicitly set to `null` in the mapping (line 203). This is a clear bug.

3. **Government ID for Business**: These fields are queried for both PersonAccount and Business Account, but only mapped for PersonAccount. Business Accounts need these fields for the authorized signer.

4. **Contact-based Pre-population**: When using a Primary Contact, Government ID fields are not available on the Contact object, so they cannot be pre-populated from Contact data alone.

5. **Address Code is Correct**: The address mapping code appears correct in all layers (SOQL → Apex → LWC). The issue is likely data-related or timing-related. Console logs will help diagnose.

---

**Next Steps**: 
1. User to provide console logs from browser when testing pre-population
2. Once address issue is diagnosed, proceed with code changes for the 13 confirmed issues

