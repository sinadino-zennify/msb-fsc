# Applicant Object Field Mapping

**Source**: `/docs/01-foundation/field-mappings.csv`  
**Last Updated**: 2025-11-10  
**Object**: Applicant (FSC Standard Object)

---

## 📋 Overview

This document maps wizard UI fields to the **Applicant** object fields. The Applicant object stores individual applicant information and links to both ApplicationForm and PersonAccount records.

**Key Relationships**:
- `Applicant.ApplicationFormId` → ApplicationForm (Master-Detail or Lookup)
- `Applicant.AccountId` → Account (PersonAccount)

---

## 🧑 Person - Identity Fields

| UI Field Label | Applicant Field API | Field Status | Field Type | Required | Notes |
|----------------|---------------------|--------------|------------|----------|-------|
| Salutation | `Salutation` | Standard | Picklist | No | Values: Mr. Mrs. Ms. Dr. Prof. |
| First Name | `FirstName` | Standard | Text | **Yes** | Required field |
| Middle Name | `MiddleName` | Standard | Text | No | Optional |
| Last Name | `LastName` | Standard | Text | **Yes** | Required field |
| Suffix | `Suffix` | Standard | Picklist | No | Values: Jr. Sr. II III IV |
| Phonetic Name (Checkbox) | `Has_Phonetic_Name__c` | Custom | Checkbox | No | Indicates if phonetic spelling exists |
| Phonetic Name | `Phonetic_Name__c` | Custom | Text(120) | No | Displays when checkbox is true |
| Birth Date | `BirthDate` | Standard | Date | **Yes** | Required for CIP/KYC |
| Nickname | `Nickname__c` | Custom | Text(80) | No | Optional |
| Occupation | `Occupation__c` | Custom | Picklist | No | FSC field |
| Mother's Maiden Name | `Mothers_Maiden_Name__c` | Custom | Text(80) Encrypted | No | Security question - encrypted |
| Person Type | `Type` | Standard | Picklist | No | Values: Person, Organization |
| Tax ID (SSN/ITIN) | `Tax_ID__c` | Custom | Text(11) Encrypted | No | Masked display (XXX-XX-1234) |
| Tax ID Type | `Tax_ID_Type__c` | Custom | Picklist | No | Values: SSN, ITIN, Foreign Tax ID |

---

## 📍 Person - Address & Contact Fields

| UI Field Label | Applicant Field API | Field Status | Field Type | Required | Notes |
|----------------|---------------------|--------------|------------|----------|-------|
| Address Line 1 | `Mailing_Street_Line_1__c` | Custom | Text(255) | **Yes** | Required |
| Address Line 2 | `Mailing_Street_Line_2__c` | Custom | Text(255) | No | Optional |
| Country | `Mailing_Country__c` | Custom | Picklist | No | Default: USA |
| ZIP Code | `Mailing_Postal_Code__c` | Custom | Text(10) | No | Format: #####-#### |
| City | `Mailing_City__c` | Custom | Text(80) | No | Auto-populate from ZIP |
| State | `Mailing_State__c` | Custom | Picklist | No | US States + Territories |
| Phone - Home | `Home_Phone__c` | Custom | Phone | No | |
| Phone - Work | `Work_Phone__c` | Custom | Phone | No | Primary phone |
| Phone - Mobile | `Mobile_Phone__c` | Custom | Phone | No | |
| Email | `Email` | Standard | Email | No | |

---

## 🪪 Person - Government ID Fields

| UI Field Label | IdentityDocument Field API | Field Status | Field Type | Required | Notes |
|----------------|---------------------|--------------|------------|----------|-------|
| ID Type | `IdDocumentType` | Custom | Picklist | No | Driver's License, Passport, State ID, Military ID |
| ID Number | `Name` | Custom | Text(50)  | No |  |
| Issued By - Country | `IssuingAuthority` | Custom | Text | No | Default: USA |
| Issued By - State | `Issuing_Authority_State__c` | Custom | Text | No | Conditional on State=CA |
| Issue Date | `IssueDate` | Custom | Date | No | Not future date |
| Expiration Date | `ExpirationDate` | Custom | Date | No | After Issue Date |
| Applicant | `Applicant__c` | Custom | lookup(Applicant) | Yes | Applicant Id |

---

## 🏢 Organization - Business Profile Fields

| UI Field Label | Applicant Field API | Field Status | Field Type | Required | Notes |
|----------------|---------------------|--------------|------------|----------|-------|
| Organization Name | `BusinessEntityName` | Standard | Text(255) | **Yes** | Required with search |
| Organization Type | `BusinessEntityType` | Standard | Picklist | No | LLC, Corp, Partnership, etc. |
| Address Line 1 | `Business_Street_Line_1__c` | Custom | Text(255) | **Yes** | Required |
| Address Line 2 | `Business_Street_Line_2__c` | Custom | Text(255) | No | Optional |
| Country | `Business_Country__c` | Custom | Picklist | No | Default: USA |
| ZIP Code | `Business_Postal_Code__c` | Custom | Text(10) | No | Format: #####-#### |
| City | `Business_City__c` | Custom | Text(80) | No | Auto-populate from ZIP |
| State | `Business_State__c` | Custom | Picklist | No | US States |
| Phone - Home | `Business_Home_Phone__c` | Custom | Phone | No | |
| Phone - Work | `Business_Work_Phone__c` | Custom | Phone | No | Primary phone |
| Phone - Mobile | `Business_Mobile_Phone__c` | Custom | Phone | No | |
| Email | `Business_Email__c` | Custom | Email | No | No standard business email field |
| Organization Role | `Organization_Role_c` | Custom | picklist | No | No |
| Organization Percentage | `Ownership_Percentage__c` | Custom | Percent(3, 2) | No | No  |
| Roles | `Roles__c` | Custom | Multi Picklist | No | No  |

---

## 💼 Organization - Tax & Classification Fields

| UI Field Label | Applicant Field API | Field Status | Field Type | Required | Notes |
|----------------|---------------------|--------------|------------|----------|-------|
| Tax ID (EIN) | `Business_Tax_ID__c` | Custom | Text(11) Encrypted | No | Format: XX-XXXXXXX |
| Tax ID Type | `Business_Tax_ID_Type__c` | Custom | Picklist | No | Federal Employer Tax ID (EIN), Foreign Tax ID |
| Tax Country | `Tax_Country__c` | Custom | Picklist | No | Default: USA |

---

## 📊 Organization - Industry & Risk Fields

| UI Field Label | Applicant Field API | Field Status | Field Type | Required | Notes |
|----------------|---------------------|--------------|------------|----------|-------|
| SIC Code | `SIC_Code__c` | Custom | Text(10) | No | Standard Industrial Classification |
| SIC Description | `SIC_Description__c` | Custom | Text(255) | No | Auto-populated from SIC lookup |
| NAICS Code | `NAICS_Code__c` | Custom | Text(10) | No | North American Industry Classification |
| NAICS Description | `NAICS_Description__c` | Custom | Text(255) | No | Auto-populated from NAICS lookup |
| BSA/CIP Rating | `BSA_CIP_Rating__c` | Custom | Picklist | No | Low, Medium, High, Prohibited |
| Rating Date | `BSA_Rating_Date__c` | Custom | Date | No | Date of last BSA/AML review |
| Next Rating Date | `Next_BSA_Rating_Date__c` | Custom | Date | No | Calculated: Rating Date + 12 months |

---

## 🔑 Key Applicant Fields Summary

### Standard Fields (FSC)
- `FirstName` (Text) - **Required**
- `LastName` (Text) - **Required**
- `MiddleName` (Text)
- `Salutation` (Picklist)
- `Suffix` (Picklist)
- `BirthDate` (Date) - **Required for CIP/KYC**
- `Email` (Email)
- `Type` (Picklist) - Person or Organization
- `BusinessEntityName` (Text)
- `BusinessEntityType` (Picklist)

### Custom Fields - Person Identity
- `Has_Phonetic_Name__c` (Checkbox)
- `Phonetic_Name__c` (Text 120)
- `Nickname__c` (Text 80)
- `Occupation__c` (Picklist)
- `Mothers_Maiden_Name__c` (Text 80, Encrypted)
- `Tax_ID__c` (Text 11, Encrypted)
- `Tax_ID_Type__c` (Picklist)
- `Is_US_Citizen__c` (Checkbox)
- `Is_US_Resident__c` (Checkbox) 
- `Country_Of_Residence__c` (Picklist)

### Custom Fields - Person Address & Contact
- `Mailing_Street_Line_1__c` (Text 255) - **Required**
- `Mailing_Street_Line_2__c` (Text 255)
- `Mailing_Country__c` (Picklist)
- `Mailing_Postal_Code__c` (Text 10)
- `Mailing_City__c` (Text 80)
- `Mailing_State__c` (Picklist)
- `Home_Phone__c` (Phone)
- `Work_Phone__c` (Phone)
- `Mobile_Phone__c` (Phone)

### Custom Fields - Government ID
- `Government_ID_Type__c` (Picklist)
- `Government_ID_Number__c` (Text 50, Encrypted)
- `ID_Issuing_Country__c` (Picklist)
- `ID_Issuing_State__c` (Picklist)
- `ID_Issue_Date__c` (Date)
- `ID_Expiration_Date__c` (Date)

### Custom Fields - Business/Organization
- `Business_Street_Line_1__c` (Text 255) - **Required for Business**
- `Business_Street_Line_2__c` (Text 255)
- `Business_Country__c` (Picklist)
- `Business_Postal_Code__c` (Text 10)
- `Business_City__c` (Text 80)
- `Business_State__c` (Picklist)
- `Business_Home_Phone__c` (Phone)
- `Business_Work_Phone__c` (Phone)
- `Business_Mobile_Phone__c` (Phone)
- `Business_Email__c` (Email)
- `Business_Tax_ID__c` (Text 11, Encrypted)
- `Business_Tax_ID_Type__c` (Picklist)
- `Tax_Country__c` (Picklist)
- `Employer__c` (Text)
- `Is_Control_Person__c` (picklist)

### Custom Fields - Industry & Risk
- `SIC_Code__c` (Text 10)
- `SIC_Description__c` (Text 255)
- `NAICS_Code__c` (Text 10)
- `NAICS_Description__c` (Text 255)
- `BSA_CIP_Rating__c` (Picklist)
- `BSA_Rating_Date__c` (Date)
- `Next_BSA_Rating_Date__c` (Date)

---

## 📝 Important Notes

### Encrypted Fields
The following fields are encrypted for security/compliance:
- `Mothers_Maiden_Name__c`
- `Tax_ID__c`
- `Government_ID_Number__c`
- `Business_Tax_ID__c`

### Required Fields (Minimum for Applicant Creation)
- `FirstName` (for Person)
- `LastName` (for Person)
- `BirthDate` (for CIP/KYC compliance)
- `Mailing_Street_Line_1__c`
- `BusinessEntityName` (for Organization)
- `Business_Street_Line_1__c` (for Organization)

### Relationship Fields
- `ApplicationFormId` - Links to ApplicationForm
- `AccountId` - Links to PersonAccount (for Person applicants)
- Additional relationship fields may exist (check object metadata)

### Field Dependencies
- `Phonetic_Name__c` displays when `Has_Phonetic_Name__c` = true
- `ID_Issuing_State__c` is conditional on `ID_Issuing_Country__c` = USA
- `Next_BSA_Rating_Date__c` is calculated from `BSA_Rating_Date__c` + 12 months

---

## 🔗 Related Documentation

- **Account Field Mapping**: `/docs/01-foundation/business-account-field-mapping.md`
- **PersonAccount Mapping**: `/docs/01-foundation/personaccount-address-mapping.md`
- **Data Model**: `/docs/01-foundation/data-model.md`
- **Source CSV**: `/docs/01-foundation/field-mappings.csv`

---

**Note**: This mapping is based on the source of truth CSV file. Always refer to the CSV for the most up-to-date field mappings.
