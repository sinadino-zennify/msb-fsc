# Wizard Field Delta Analysis

**Date**: 2025-11-05  
**Purpose**: Identify gaps between field-mappings-template.csv and current LWC implementation

---

## 📊 Personal Information Step (applicantDetails.html)

### ✅ Fields Currently in LWC (10 fields)
1. **First Name** - `FirstName` (Standard)
2. **Last Name** - `LastName` (Standard)
3. **Email** - `Email` (Standard)
4. **Phone** - `Phone` (Standard) - *Maps to Mobile Phone in template*
5. **Date of Birth** - `BirthDate` (Standard)
6. **Social Security Number** - `Tax_ID__c` (Custom) - *Encrypted*
7. **Street Address** - `MailingStreet` (Standard) - *Single field, not split*
8. **City** - `MailingCity` (Standard)
9. **State** - `MailingState` (Standard)
10. **ZIP Code** - `MailingPostalCode` (Standard)

---

### ❌ Missing from LWC - Person - Identity Section (9 fields)

| Field Label | Field API Name | Field Type | Status | Priority | Notes |
|-------------|----------------|------------|--------|----------|-------|
| **Salutation** | Salutation | Picklist | Standard | Medium | Values: Mr. Mrs. Ms. Dr. Prof. |
| **Middle Name** | MiddleName | Text | Standard | Low | Optional field |
| **Suffix** | Suffix | Picklist | Standard | Low | Values: Jr. Sr. II III IV |
| **Phonetic Name (Checkbox)** | Has_Phonetic_Name__c | Checkbox | Custom ✅ | Low | Indicates if phonetic spelling exists |
| **Phonetic Name** | Phonetic_Name__c | Text(120) | Custom ✅ | Low | Displays when checkbox is true |
| **Nickname** | Nickname__c | Text(80) | Custom ✅ | Low | Optional preferred name |
| **Occupation** | Occupation__c | Picklist | Custom ✅ | Medium | Employment status |
| **Mother's Maiden Name** | Mothers_Maiden_Name__c | EncryptedText(80) | Custom ✅ | Medium | Security question - encrypted |
| **Person Type** | Type | Picklist | Standard | Low | Values: Person, Organization |

**Custom Fields Status**: ✅ All custom fields created and deployed

---

### ❌ Missing from LWC - Person - Address & Contact Section (4 fields)

| Field Label | Field API Name | Field Type | Status | Priority | Notes |
|-------------|----------------|------------|--------|----------|-------|
| **Address Line 2** | Mailing_Street_Line_2__c | Text(255) | Custom ✅ | Medium | Optional second address line |
| **Country** | Mailing_Country__c | Picklist | Custom ✅ | Medium | Default: USA |
| **Phone - Home** | Home_Phone__c | Phone | Custom ✅ | Low | Home phone number |
| **Phone - Work** | Work_Phone__c | Phone | Custom ✅ | Low | Work phone number |

**Notes**:
- Current LWC has single "Phone" field (maps to standard `Phone` field)
- Template has 3 phone types: Home, Work, Mobile
- Current "Street Address" is single field; template splits into Line 1 and Line 2

**Custom Fields Status**: ✅ All custom fields created and deployed

---

### ❌ Missing from LWC - Person - Tax ID Section (1 field)

| Field Label | Field API Name | Field Type | Status | Priority | Notes |
|-------------|----------------|------------|--------|----------|-------|
| **Tax ID Type** | Tax_ID_Type__c | Picklist | Custom ✅ | High | Values: SSN, ITIN, Foreign Tax ID |

**Notes**:
- Current LWC has "Social Security Number" field but no type selector
- Should add Tax ID Type picklist to distinguish SSN vs ITIN vs Foreign Tax ID

**Custom Fields Status**: ✅ Field created and deployed

---

### ❌ Missing from LWC - Person - Government ID Section (6 fields)

| Field Label | Field API Name | Field Type | Status | Priority | Notes |
|-------------|----------------|------------|--------|----------|-------|
| **ID Type** | Government_ID_Type__c | Picklist | Custom ✅ | High | Driver's License, Passport, State ID, Military ID |
| **ID Number** | Government_ID_Number__c | EncryptedText(50) | Custom ✅ | High | Encrypted |
| **Issued By - Country** | ID_Issuing_Country__c | Picklist | Custom ✅ | Medium | Default: USA |
| **Issued By - State** | ID_Issuing_State__c | Text(255) | Custom ✅ | Medium | Conditional on Country=USA |
| **Issue Date** | ID_Issue_Date__c | Date | Custom ✅ | Medium | Not future date |
| **Expiration Date** | ID_Expiration_Date__c | Date | Custom ✅ | Medium | After Issue Date |

**Notes**:
- Entire Government ID section missing from current LWC
- Required for CIP/KYC compliance
- All fields created and ready to add to LWC

**Custom Fields Status**: ✅ All fields created and deployed

---

### ❌ Missing from LWC - Action Buttons (1 field)

| Field Label | Field Type | Priority | Notes |
|-------------|------------|----------|-------|
| **Scan ID & Signature** | Action Button | Low | Triggers file upload component |

**Notes**:
- Could integrate with Document Upload step
- Or add as inline file upload in Personal Information step

---

## 📈 Personal Information Step Summary

### Current State
- **Fields in LWC**: 10 fields
- **Fields in Template**: 30 fields
- **Coverage**: 33% (10/30)

### Missing Fields Breakdown
- **Person - Identity**: 9 fields missing (Salutation, Middle Name, Suffix, Phonetic Name fields, Nickname, Occupation, Mother's Maiden Name, Person Type)
- **Person - Address & Contact**: 4 fields missing (Address Line 2, Country, Phone - Home, Phone - Work)
- **Person - Tax ID**: 1 field missing (Tax ID Type)
- **Person - Government ID**: 6 fields missing (entire section)
- **Action Buttons**: 1 field missing (Scan ID & Signature)

### Priority Recommendations

**🔴 High Priority (Should Add)**:
1. **Tax ID Type** - Required to distinguish SSN vs ITIN vs Foreign Tax ID
2. **Government ID Type** - Required for CIP/KYC compliance
3. **Government ID Number** - Required for CIP/KYC compliance
4. **Address Line 2** - Common requirement for complete addresses

**🟡 Medium Priority (Consider Adding)**:
1. **Salutation** - Professional/formal addressing
2. **Occupation** - Employment verification
3. **Mother's Maiden Name** - Security question for account recovery
4. **Country** - International address support
5. **Phone - Home** and **Phone - Work** - Multiple contact methods
6. **Government ID Issuing Country/State** - Complete ID verification
7. **Government ID Issue/Expiration Dates** - ID validity verification

**🟢 Low Priority (Nice to Have)**:
1. **Middle Name** - Full legal name
2. **Suffix** - Name formatting
3. **Phonetic Name** fields - Pronunciation assistance
4. **Nickname** - Personalization
5. **Person Type** - Distinguish person vs organization (likely not needed for PersonAccount)

---

## 🎯 Recommendations for ST-002

For the **Populate Existing Data from Opportunity** story, focus on mapping these **currently implemented fields**:

### From PersonAccount → Personal Information Step
```
PersonAccount.FirstName → First Name
PersonAccount.LastName → Last Name
PersonAccount.PersonEmail → Email
PersonAccount.PersonMobilePhone → Phone
PersonAccount.PersonBirthdate → Date of Birth
PersonAccount.FinServ__TaxID__pc → Social Security Number
PersonAccount.PersonMailingStreet → Street Address
PersonAccount.PersonMailingCity → City
PersonAccount.PersonMailingState → State
PersonAccount.PersonMailingPostalCode → ZIP Code
```

### Additional Fields to Consider for Future Stories
If you want to enhance the Personal Information step with Government ID fields (high priority for banking compliance):
```
PersonAccount.Government_ID_Type__c → ID Type
PersonAccount.Government_ID_Number__c → ID Number
PersonAccount.ID_Issuing_Country__c → Issued By - Country
PersonAccount.ID_Issuing_State__c → Issued By - State
PersonAccount.ID_Issue_Date__c → Issue Date
PersonAccount.ID_Expiration_Date__c → Expiration Date
```

---

**Next**: Would you like me to analyze the **Business Information** step next?
