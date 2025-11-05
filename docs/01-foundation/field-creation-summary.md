# Field Creation Summary - ST-002 Preparation

**Date**: 2025-11-05  
**Org**: msb-sbox  
**Status**: ✅ Successfully Deployed

---

## 📊 Deployment Summary

**Total Fields Created**: 31 custom fields  
**Deployment Status**: Succeeded  
**Deployment ID**: 0AfWE00000Ep94P0AR

### Fields by Object

- **Applicant**: 24 custom fields
- **Account**: 6 custom fields  
- **Existing**: 1 field (DAOApplicantId__c, DAOBusinessId__c - already existed)

---

## ✅ Applicant Custom Fields Created (24 fields)

### Personal Identity Fields
1. **Has_Phonetic_Name__c** - Checkbox - Indicates if phonetic spelling exists
2. **Phonetic_Name__c** - Text(120) - Phonetic spelling of name
3. **Nickname__c** - Text(80) - Preferred nickname
4. **Occupation__c** - Picklist - Occupation status (Employed, Self-Employed, Retired, Student, Unemployed, Other)
5. **Mothers_Maiden_Name__c** - EncryptedText(80) - Mother's maiden name (security question)
6. **Tax_ID__c** - EncryptedText(11) - SSN/ITIN (masked display XXX-XX-1234)
7. **Tax_ID_Type__c** - Picklist - Tax ID type (SSN, ITIN, Foreign Tax ID)

### Contact Information Fields
8. **Home_Phone__c** - Phone - Home phone number
9. **Work_Phone__c** - Phone - Work phone number
10. **Mobile_Phone__c** - Phone - Mobile phone number

### Mailing Address Fields
11. **Mailing_Street_Line_1__c** - Text(255) - First line of mailing address
12. **Mailing_Street_Line_2__c** - Text(255) - Second line of mailing address
13. **Mailing_Country__c** - Picklist - Country (USA, Canada, Mexico, Other)
14. **Mailing_Postal_Code__c** - Text(10) - ZIP code (format: #####-####)
15. **Mailing_City__c** - Text(80) - City (can be auto-populated from ZIP)
16. **Mailing_State__c** - Text(255) - State

### Government ID Fields
17. **Government_ID_Type__c** - Picklist - ID type (Driver's License, Passport, State ID, Military ID)
18. **Government_ID_Number__c** - EncryptedText(50) - ID number (encrypted)
19. **ID_Issuing_Country__c** - Picklist - Issuing country (USA, Canada, Mexico, Other)
20. **ID_Issuing_State__c** - Text(255) - Issuing state
21. **ID_Issue_Date__c** - Date - Issue date (cannot be future)
22. **ID_Expiration_Date__c** - Date - Expiration date (must be after issue date)

### Application Role Fields
23. **Role__c** - Picklist - Applicant role (Primary Applicant, Co-Applicant, Authorized Signer, Beneficial Owner, Guarantor)
24. **Ownership_Percentage__c** - Percent(5,2) - Ownership percentage (0-100%)

---

## ✅ Account Custom Fields Created (6 fields)

### Business Contact Fields
1. **Business_Email__c** - Email - Business email address
2. **Business_Home_Phone__c** - Phone - Business home phone
3. **Business_Work_Phone__c** - Phone - Business work phone (primary)
4. **Business_Mobile_Phone__c** - Phone - Business mobile phone

### Business Tax Fields
5. **Business_Tax_ID__c** - EncryptedText(11) - Federal EIN (format: XX-XXXXXXX)
6. **Business_Tax_ID_Type__c** - Picklist - Tax ID type (Federal Employer Tax ID (EIN), Foreign Tax ID)

---

## 🗑️ Fields Deleted (Not Created)

### Account Address Fields (6 fields - using standard fields instead)
- ❌ Business_Street_Line_1__c → Use `BillingStreet`
- ❌ Business_Street_Line_2__c → Use `BillingStreet`
- ❌ Business_Country__c → Use `BillingCountry`
- ❌ Business_Postal_Code__c → Use `BillingPostalCode`
- ❌ Business_City__c → Use `BillingCity`
- ❌ Business_State__c → Use `BillingState`

**Rationale**: Salesforce provides standard compound address fields on Account (BillingAddress and ShippingAddress) which should be used instead of creating custom duplicates.

---

## 📋 Fields NOT Created (From Template - Not Needed)

### PersonAccount-Specific Fields
These fields from the template are for PersonAccount and already exist as standard FSC fields or are not needed:
- ❌ All PersonAccount fields (Salutation, FirstName, LastName, PersonBirthdate, PersonEmail, PersonMailingStreet, etc.) - **Standard FSC fields**
- ❌ FinServ__Occupation__pc - **Standard FSC field**
- ❌ FinServ__TaxID__pc - **Standard FSC field**
- ❌ FinServ__CompanyType__c - **Standard FSC field**

### Account Standard Fields Already Available
- ❌ Name, Type, Phone, Website, YearStarted, NumberOfEmployees, Description, Industry, Sic, SicDesc, NaicsCode, NaicsDesc - **Standard Account fields**

### Fields Not in Current LWC Implementation
These fields from the template are not currently displayed in any wizard step:
- SIC_Code__c, SIC_Description__c
- NAICS_Code__c, NAICS_Description__c
- BSA_CIP_Rating__c, BSA_Rating_Date__c, Next_BSA_Rating_Date__c
- Tax_Country__c (on Account)
- Person_Type__c, Nickname__c, Has_Phonetic_Name__c, Phonetic_Name__c (on Account/PersonAccount)
- Government ID fields (on Account/PersonAccount)
- Mothers_Maiden_Name__c (on Account/PersonAccount)

**Note**: These can be created later if needed for future wizard steps.

---

## 🔐 Security & Access

**System Administrator Profile**: ✅ Automatic access to all custom fields  
**Field-Level Security**: All fields are accessible to System Administrator profile by default  
**Encryption**: Sensitive fields use EncryptedText type:
- Tax_ID__c (SSN masking)
- Mothers_Maiden_Name__c
- Government_ID_Number__c
- Business_Tax_ID__c

---

## 📝 Field Mapping for ST-002

### From Account (Business) → Business Information Step
| Standard Field | UI Label | In LWC |
|----------------|----------|--------|
| Name | Business Name | ✅ |
| Type | Business Type | ✅ |
| FinServ__TaxID__c | Federal Tax ID (EIN) | ✅ |
| Industry | Industry Type | ✅ |
| Phone | Business Phone | ✅ |
| Website | Business Website | ✅ |
| YearStarted | Year Established | ✅ |
| NumberOfEmployees | Number of Employees | ✅ |
| Description | Business Description | ✅ |
| BillingStreet | Business Street Address | ✅ |
| BillingCity | City | ✅ |
| BillingState | State | ✅ |
| BillingPostalCode | ZIP Code | ✅ |
| **Business_Email__c** | Business Email | ✅ |

### From Applicant → Personal Information Step
| Field API Name | UI Label | In LWC | Status |
|----------------|----------|--------|--------|
| FirstName | First Name | ✅ | Standard |
| LastName | Last Name | ✅ | Standard |
| Email | Email | ✅ | Standard |
| Phone | Phone | ✅ | Standard |
| BirthDate | Date of Birth | ✅ | Standard |
| MailingStreet | Street Address | ✅ | Standard |
| MailingCity | City | ✅ | Standard |
| MailingState | State | ✅ | Standard |
| MailingPostalCode | ZIP Code | ✅ | Standard |
| **Tax_ID__c** | SSN | ✅ | **NEW** |

### From Applicant → Additional Applicants Step
| Field API Name | UI Label | In LWC | Status |
|----------------|----------|--------|--------|
| FirstName | First Name | ✅ | Standard |
| LastName | Last Name | ✅ | Standard |
| Email | Email | ✅ | Standard |
| Phone | Phone | ✅ | Standard |
| BirthDate | Date of Birth | ✅ | Standard |
| MailingStreet | Street Address | ✅ | Standard |
| MailingCity | City | ✅ | Standard |
| MailingState | State | ✅ | Standard |
| MailingPostalCode | ZIP Code | ✅ | Standard |
| **Tax_ID__c** | SSN | ✅ | **NEW** |
| **Role__c** | Role | ✅ | **NEW** |
| **Ownership_Percentage__c** | Ownership % | ✅ | **NEW** |

---

## 🎯 Next Steps for ST-002

1. ✅ **Fields Created** - All required custom fields deployed
2. ⏭️ **Update OpportunityDataService** - Map Account and PersonAccount fields to DTOs
3. ⏭️ **Update LWC Components** - Bind pre-populated data from Opportunity
4. ⏭️ **Update Field Mappings** - Document final field mappings in ST-002
5. ⏭️ **Test Data Creation** - Create test Opportunity with Business Account and ACRs

---

## 📌 Important Notes

1. **Standard vs Custom**: Prefer standard Salesforce fields over custom fields whenever possible
2. **PersonAccount**: PersonAccount fields are accessed via Contact object in SOQL (e.g., `Contact.FirstName`)
3. **Address Fields**: Use compound address fields (BillingAddress, ShippingAddress, MailingAddress) instead of individual custom fields
4. **Encryption**: All PII fields use EncryptedText with appropriate masking
5. **Field Accessibility**: System Administrator profile has automatic access to all custom fields

---

**Deployment completed successfully on 2025-11-05 at 16:55:30 UTC**
