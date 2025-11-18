<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md and docs/01-foundation/applicant-field-mapping.md for correct field names
✅ Correct: ApplicationForm, Applicant, Account (PersonAccount), IdentityDocument
❌ Wrong: Application__c, Applicant__c, Person__c
-->

# ST-005: Capture Individual (Person) Details

**Story ID**: ST-005  
**Work Item**: LWC-005, SVC-005  
**Status**: Ready for Dev  
**Created**: 2025-11-18  
**Last Updated**: 2025-11-18

## 🎫 JIRA Story Mapping

| JIRA Story | Title | Status | Link |
|------------|-------|--------|------|
| MSB-25 | Capture Individual (Person) Details in Guided Intake | In Progress | [View Story](https://zennify.atlassian.net/browse/MSB-25) |

> **Note**: This requirement covers capturing individual applicant information for both Primary Applicant and Additional Applicants in the DAO Wizard.

---

## 📋 Story Overview

**As a** Banker User completing a Deposit Account Opening application  
**I want** to capture and validate personal customer information  
**So that** all required CIP and identity verification fields are collected for individual applicants

**Notes from Discovery**:
- Capture person-level information for all signers and beneficial owners
- Compliance confirmed two identification methods required per CIP
- Virtual bankers will not have live scanning but need manual entry options

---

## 🎯 Acceptance Criteria

### Primary Applicant Details (applicantDetails Component)
- [ ] Primary Applicant screen renders with all required fields
- [ ] Pre-population works when existing customer is selected
- [ ] All fields validated for required inputs and correct formats
- [ ] Identity Documents table allows multiple IDs (minimum 1 required)
- [ ] Data saved to Applicant record (Type = 'Indiviudal', Role = 'Primary Applicant')
- [ ] Tax ID (SSN/ITIN) is encrypted in storage
- [ ] Citizenship status conditional fields display correctly
- [ ] Organization role fields display for business applications
- [ ] Inline error messages display before next step
- [ ] Step completion updates `ApplicationForm.StepKey__c`

### Additional Applicants Details (additionalApplicants Component)
- [ ] Additional Applicants screen allows adding multiple persons
- [ ] Each applicant can be existing customer or new entry
- [ ] All fields from Primary Applicant are available for each additional applicant
- [ ] Identity Documents table works for each applicant
- [ ] Applicants can be removed before submission
- [ ] Data saved to multiple Applicant records (Type = 'Person', Role = 'Additional')
- [ ] Each applicant creates PersonAccount + ACR on submission
- [ ] Beneficial ownership percentages tracked and cannot exceed 100%
- [ ] Validation ensures all applicants have required fields
- [ ] Step completion updates `ApplicationForm.StepKey__c`

---

## 🛠️ Tasks and Sub-Tasks

### Phase 1: Primary Applicant Details (applicantDetails Component)

#### 1. Create Primary Applicant Details LWC Component
- [ ] 1.1 Create `applicantDetails` LWC component
- [ ] 1.2 Implement form layout with all required sections:
  - Existing Customer Toggle
  - Personal Information (Name, DOB, Nickname, etc.)
  - Tax Information (SSN/ITIN, Tax ID Type)
  - Citizenship Status (US Citizen, US Resident, Country of Residence)
  - Employment Information (Employer, Occupation)
  - Organization Roles (for business applications)
  - Identity Documents (table with Add/Edit/Delete)
  - Address (using lightning-input-address)
  - Contact Information (Email, Phones, Preferred Contact Method)
- [ ] 1.3 Add "Existing Customer" toggle with PersonAccount lookup
- [ ] 1.4 Implement conditional rendering based on toggle state
- [ ] 1.5 Implement conditional rendering for citizenship fields
- [ ] 1.6 Implement conditional rendering for organization role fields
- [ ] 1.7 Style component with SLDS for consistent UI/UX

#### 2. Implement Identity Documents Table
- [x] 2.1 Create identity documents table UI, use the applicant-field-mapping.md file as source of truth
- [x] 2.2 Add "Add ID" button to create new row
- [x] 2.3 Implement inline editing for each row
- [x] 2.4 Add Edit (pencil icon) and Delete (trash icon) actions
- [x] 2.5 Validate minimum 1 ID required (CIP requirement)
- [x] 2.6 Store documents in component state
- [x] 2.7 Prepare documents for persistence to IdentityDocument object

#### 3. Implement Client-Side Validation
- [ ] 3.1 Add required field validation:
  - First Name (required)
  - Last Name (required)
  - Date of Birth (required for CIP/KYC)
  - Tax ID (required)
  - Tax ID Type (required)
  - US Citizen status (required)
  - Address Line 1 (required)
  - City (required)
  - State (required)
  - Postal Code (required)
  - Email (required)
  - Mobile Phone (required)
  - Preferred Contact Method (required)
  - At least 1 Identity Document (required)
- [ ] 3.2 Implement conditional validation:
  - If US Citizen = No → US Resident required
  - If US Resident = No → Country of Residence required
  - If Organization Role = Business Owner → Ownership Percent required
- [ ] 3.3 Add format validation:
  - Date of Birth (cannot be future, must be 18+)
  - Tax ID format (SSN: ###-##-####)
  - Email format
  - Phone number format
  - Postal Code format (#####-####)
- [ ] 3.4 Display inline error messages below each field
- [ ] 3.5 Show summary error message at top if validation fails
- [ ] 3.6 Display CIP prompt: "⚠️ CIP Requirement: At least one government-issued ID must be provided"
- [ ] 3.7 Implement `@api validate()` method for container integration

#### 4. Implement Existing Customer Toggle Logic ( HOLD on This Task)
- [ ] 4.1 Add toggle UI element
- [ ] 4.2 Show PersonAccount lookup when toggle is ON
- [ ] 4.3 Query PersonAccounts (IsPersonAccount = true)
- [ ] 4.4 Pre-populate all fields from selected PersonAccount
- [ ] 4.5 Query and display existing IdentityDocuments
- [ ] 4.6 Store PersonAccount ID for ApplicationForm linkage
- [ ] 4.7 Show manual entry form when toggle is OFF

#### 5. Implement Address Autocomplete
- [ ] 5.1 Use `<lightning-input-address>` component
- [ ] 5.2 Enable Google Maps autocomplete
- [ ] 5.3 Add separate Address Line 2 field below component
- [ ] 5.4 Auto-populate City, State, Country, Postal Code from search
- [ ] 5.5 Allow manual override of auto-populated fields
- [ ] 5.6 Verify Maps & Location Services enabled in Setup

#### 6. Update WizardPersistenceService for Primary Applicant
- [ ] 6.1 Create or update `upsertPrimaryApplicantStep()` method
- [ ] 6.2 Map wizard payload to Applicant fields (see Field Mappings section)
- [ ] 6.3 Handle existing PersonAccount linkage:
  - Set `ApplicationForm.AccountId` = selectedAccountId
  - Set `Applicant.AccountId` = selectedAccountId
- [ ] 6.4 Handle new customer scenario:
  - Flag for PersonAccount creation on submission
  - Store person data in Applicant record
- [ ] 6.5 Create/Update IdentityDocument records:
  - Link to Applicant via `Applicant__c` lookup
  - Set all required fields
  - Delete removed IDs from previous saves
- [ ] 6.6 Encrypt Tax ID before storage
- [ ] 6.7 Update `ApplicationForm.StepKey__c` = 'DAO_Business_InBranch_Applicant'
- [ ] 6.8 Enforce CRUD/FLS with `WITH USER_MODE`
- [ ] 6.9 Return structured response with saved IDs and any errors


#### 7. Unit Testing - Primary Applicant
- [ ] 7.1 Test `upsertPrimaryApplicantStep()` with new customer data
- [ ] 7.2 Test `upsertPrimaryApplicantStep()` with existing PersonAccount linkage
- [ ] 7.3 Test Tax ID encryption/decryption
- [ ] 7.4 Test IdentityDocument creation/update/delete
- [ ] 7.5 Test all validation rules (all scenarios)
- [ ] 7.6 Test conditional field display logic
- [ ] 7.7 Test ApplicationForm.AccountId linkage
- [ ] 7.8 Test StepKey__c update
- [ ] 7.9 Test CRUD/FLS enforcement
- [ ] 7.10 Ensure ≥85% code coverage



---

### Phase 2: Additional Applicants Details (additionalApplicants Component)

#### 10. Create Additional Applicants LWC Component
- [ ] 10.1 Create `additionalApplicants` LWC component
- [ ] 10.2 Implement dynamic applicant list UI
- [ ] 10.3 Add "Add Applicant" button
- [ ] 10.4 Implement applicant card/accordion for each person
- [ ] 10.5 Include all fields from Primary Applicant for each additional applicant:
  - Existing Customer Toggle
  - Personal Information
  - Tax Information
  - Citizenship Status
  - Employment Information
  - Organization Roles
  - Identity Documents table
  - Address
  - Contact Information
- [ ] 10.6 Add "Remove Applicant" button for each card
- [ ] 10.7 Implement typeahead search for existing PersonAccounts
- [ ] 10.8 Style component with SLDS

#### 11. Implement Additional Applicants Validation
- [ ] 11.1 Validate required fields for each applicant (same as Primary)
- [ ] 11.2 Validate at least 1 Identity Document per applicant
- [ ] 11.3 Validate conditional fields for each applicant
- [ ] 11.4 Validate ownership percentages (if applicable)
- [ ] 11.5 Prevent duplicate applicants (same person added twice)
- [ ] 11.6 Display validation errors per applicant
- [ ] 11.7 Implement `@api validate()` method

#### 12. Update WizardPersistenceService for Additional Applicants
- [ ] 12.1 Create or update `upsertAdditionalApplicantsStep()` method
- [ ] 12.2 Handle list of applicants in payload
- [ ] 12.3 For each applicant:
  - Create/Update Applicant record (Type = 'Person', Role = 'Additional')
  - Map all fields (same as Primary Applicant)
  - Create/Update IdentityDocument records
  - Link to ApplicationForm
  - Flag for PersonAccount + ACR creation on submission
- [ ] 12.4 Handle existing PersonAccount linkage for each applicant
- [ ] 12.5 Handle bulk DML efficiently
- [ ] 12.6 Update `ApplicationForm.StepKey__c` = 'DAO_Business_InBranch_AdditionalApplicants'
- [ ] 12.7 Return list of created/updated IDs
- [ ] 12.8 Enforce CRUD/FLS with `WITH USER_MODE`

#### 13. Wire Additional Applicants Component to Container
- [ ] 13.1 Add `additionalApplicants` to `daoWizardStepRouter`
- [ ] 13.2 Update Wizard_Step__mdt with Additional Applicants step record
- [ ] 13.3 Set correct `Order__c` and `ComponentBundle__c`
- [ ] 13.4 Test navigation to/from Additional Applicants step

#### 14. Unit Testing - Additional Applicants
- [ ] 14.1 Test `upsertAdditionalApplicantsStep()` with multiple applicants
- [ ] 14.2 Test with mix of existing and new customers
- [ ] 14.3 Test IdentityDocument creation for each applicant
- [ ] 14.4 Test applicant removal
- [ ] 14.5 Test validation rules for all applicants
- [ ] 14.6 Test bulk DML operations
- [ ] 14.7 Test CRUD/FLS enforcement
- [ ] 14.8 Ensure ≥85% code coverage

#### 15. Integration Testing - Additional Applicants
- [ ] 15.1 Test full wizard flow with Additional Applicants step
- [ ] 15.2 Test adding multiple applicants
- [ ] 15.3 Test removing applicants
- [ ] 15.4 Test typeahead search
- [ ] 15.5 Test Save & Exit and resume
- [ ] 15.6 Verify all Applicant records created
- [ ] 15.7 Verify all IdentityDocument records created
- [ ] 15.8 Test error handling and display

---

### Phase 3: Deployment & Verification

#### 16. Deployment Preparation
- [ ] 16.1 Update `package.xml` with all new components
- [ ] 16.2 Update Wizard_Step__mdt records
- [ ] 16.3 Verify Applicant custom fields exist in target org
- [ ] 16.4 Verify IdentityDocument object and custom lookup field exist
- [ ] 16.5 Verify encryption configuration for Tax ID field
- [ ] 16.6 Verify Maps & Location Services enabled
- [ ] 16.7 Create deployment checklist

#### 17. Deployment & Verification
- [ ] 17.1 Deploy to `msb-sbox`
- [ ] 17.2 Verify Primary Applicant step renders correctly
- [ ] 17.3 Verify Additional Applicants step renders correctly
- [ ] 17.4 Test all validation rules in org
- [ ] 17.5 Test existing customer toggle for both steps
- [ ] 17.6 Test new customer entry for both steps
- [ ] 17.7 Verify Applicant record creation
- [ ] 17.8 Verify IdentityDocument record creation
- [ ] 17.9 Verify ApplicationForm linkage
- [ ] 17.10 Test Save & Exit and resume
- [ ] 17.11 Verify Tax ID encryption
- [ ] 17.12 Test address autocomplete

#### 18. Documentation
- [ ] 18.1 Document field mapping decisions
- [ ] 18.2 Update data model documentation
- [ ] 18.3 Document encryption approach
- [ ] 18.4 Document IdentityDocument integration
- [ ] 18.5 Add code comments
- [ ] 18.6 Update session notes

---

## 🔧 Technical Implementation

### Objects Involved
- **ApplicationForm** (FSC) – Primary application record
- **Applicant** (FSC) – Individual applicant records (Type = 'Person')
- **Account** (PersonAccount) – Individual customer accounts (IsPersonAccount = true)
- **IdentityDocument** (Standard) – Government-issued IDs
- **AccountContactRelation** (Standard) – Links additional applicants to business (future)

### Key Relationships

```
ApplicationForm
    ↓ (AccountId lookup - optional, set if existing customer)
Account (PersonAccount)
    ↓ (Applicant.AccountId reference)
Applicant (Type = 'Person', Role = 'Primary')
    ↑ (ApplicationFormId lookup)
ApplicationForm

Identity Documents:
Applicant
    ↓ (IdentityDocument.Applicant__c custom lookup)
IdentityDocument (multiple records)

Additional Applicants Flow:
ApplicationForm
    ↓ (ApplicationFormId lookup)
Applicant (Type = 'Person', Role = 'Additional') [multiple]
    ↓ (Applicant.AccountId reference)
Account (PersonAccount) [multiple]
    ↓ (AccountContactRelation - created on submission)
Account (Business)
```

### Field Mappings

#### Primary Applicant Details → Applicant (Type = 'Person', Role = 'Primary')

**Source of Truth**: `/docs/01-foundation/applicant-field-mapping.md`

| Wizard Field | Applicant Field | Type | Required | Notes |
|--------------|-----------------|------|----------|-------|
| **Toggle & Lookup** |
| isExistingCustomer | N/A (component state) | Boolean | No | Toggle state |
| selectedAccountId | AccountId | Lookup(Account) | No | If existing customer |
| **Personal Information** |
| salutation | Salutation | Picklist | No | Mr., Mrs., Ms., Dr., Prof. |
| firstName | FirstName | Text | **Yes** | Required |
| middleName | MiddleName | Text | No | Optional |
| lastName | LastName | Text | **Yes** | Required |
| suffix | Suffix | Picklist | No | Jr., Sr., II, III, IV |
| nickname | Nickname__c | Text(80) | No | Optional |
| hasPhoneticName | Has_Phonetic_Name__c | Checkbox | No | Indicates phonetic spelling |
| phoneticName | Phonetic_Name__c | Text(120) | No | Conditional on checkbox |
| dateOfBirth | BirthDate | Date | **Yes** | Required for CIP/KYC |
| mothersMaidenName | Mothers_Maiden_Name__c | Text(80) Encrypted | No | Security question |
| **Tax Information** |
| taxId | Tax_ID__c | Text(11) Encrypted | **Yes** | SSN/ITIN, masked display |
| taxIdType | Tax_ID_Type__c | Picklist | **Yes** | SSN, ITIN, Foreign Tax ID |
| **Citizenship Status** |
| isUSCitizen | Is_US_Citizen__c | Picklist | **Yes** | Yes, No |
| isUSResident | Is_US_Resident__c | Picklist | Conditional | Required if not US Citizen |
| countryOfResidence | Country_Of_Residence__c | Picklist | Conditional | Required if not US Resident |
| **Employment Information** |
| employer | Employer__c | Text | No | Employer name |
| occupation | Occupation__c | Picklist | No | Optional |
| **Organization Roles** (For Business Applications) |
| organizationRole | Organization_Role__c | Picklist | No | Business Owner, Authorized Signer |
| ownershipPercent | Ownership_Percentage__c | Percent(3,2) | Conditional | Required if Business Owner |
| roles | Roles__c | Multi-Select Picklist | No | ATM Holder, Administrator, etc. |
| controlPerson | Is_Control_Person__c | Picklist | No | Yes, No (displayed as toggle) |
| **Address** (Using lightning-input-address) |
| mailingStreet | Mailing_Street_Line_1__c | Text(255) | **Yes** | Address Line 1 |
| mailingStreet2 | Mailing_Street_Line_2__c | Text(255) | No | Address Line 2 |
| mailingCity | Mailing_City__c | Text(80) | **Yes** | Auto-populated |
| mailingState | Mailing_State__c | Picklist | **Yes** | US States + Territories |
| mailingCountry | Mailing_Country__c | Picklist | **Yes** | Default: USA |
| mailingPostalCode | Mailing_Postal_Code__c | Text(10) | **Yes** | Format: #####-#### |
| **Contact Information** |
| email | Email | Email | **Yes** | Required |
| homePhone | Home_Phone__c | Phone | No | Optional |
| workPhone | Work_Phone__c | Phone | No | Optional |
| mobilePhone | Mobile_Phone__c | Phone | **Yes** | Required |
| preferredContactMethod | Preferred_Contact_Method__c | Picklist | **Yes** | Email, Phone |

#### Identity Documents → IdentityDocument Object

| Wizard Field | IdentityDocument Field | Type | Required | Notes |
|--------------|------------------------|------|----------|-------|
| applicantId | Applicant__c | Lookup(Applicant) | **Yes** | Custom lookup field |
| idType | IdentityDocumentType | Picklist | **Yes** | Driver's License, Passport, etc. |
| idNumber | DocumentNumber | Text Encrypted | **Yes** | Encrypted |
| issuedBy | IssuingAuthority | Text | **Yes** | Format: "State, Country" |
| issueDate | IssueDate | Date | **Yes** | Cannot be future |
| expirationDate | ExpirationDate | Date | **Yes** | After issue date |
| isActive | IsActive | Checkbox | **Yes** | Default: true |

> **Note**: The IdentityDocument object requires a custom lookup field `Applicant__c` to link to the Applicant record.

---

## 🎨 UI/UX Design

### Primary Applicant Details (applicantDetails Component)

#### Section 1: Existing Customer Toggle
```
┌─────────────────────────────────────────────────┐
│ Is this an existing customer?                   │
│ ○ New Customer  ○ Existing Customer             │
│                                                  │
│ [If Existing Customer selected]                 │
│ Search for Customer: [___________________] 🔍   │
└─────────────────────────────────────────────────┘
```

#### Section 2: Personal Information
```
┌─────────────────────────────────────────────────┐
│ Personal Information                             │
│                                                  │
│ Salutation: [Mr. ▼]                             │
│ First Name: [___________________] *              │
│ Middle Name: [___________________]               │
│ Last Name: [___________________] *               │
│ Suffix: [Jr. ▼]                                 │
│ Nickname: [___________________]                  │
│                                                  │
│ ☐ Has Phonetic Name                             │
│ [If checked] Phonetic Name: [_______________]   │
│                                                  │
│ Date of Birth: [MM/DD/YYYY] *                   │
│ Mother's Maiden Name: [___________________]      │
└─────────────────────────────────────────────────┘
```

#### Section 3: Tax Information
```
┌─────────────────────────────────────────────────┐
│ Tax Information                                  │
│                                                  │
│ Tax ID (SSN/ITIN): [___-__-____] * 🔒          │
│ Tax ID Type: [SSN ▼] *                          │
└─────────────────────────────────────────────────┘
```

#### Section 4: Citizenship Status
```
┌─────────────────────────────────────────────────┐
│ Citizenship Status                               │
│                                                  │
│ Are you a US Citizen?: [Yes ▼] *               │
│                                                  │
│ [If No] Are you a US Resident?: [Yes ▼] *      │
│ [If No] Country of Residence: [_______ ▼] *    │
└─────────────────────────────────────────────────┘
```

#### Section 5: Employment Information
```
┌─────────────────────────────────────────────────┐
│ Employment Information (Optional)                │
│                                                  │
│ Employer: [___________________]                  │
│ Occupation: [Select... ▼]                       │
└─────────────────────────────────────────────────┘
```

#### Section 6: Organization Roles (For Business Applications)
```
┌─────────────────────────────────────────────────┐
│ Organization Roles                               │
│                                                  │
│ Organization Role: [Business Owner ▼]           │
│ [If Business Owner] Ownership %: [___.__] %     │
│                                                  │
│ Roles: [☐ CEO  ☐ CFO  ☐ Treasurer  ☐ Other]   │
│                                                  │
│ Control Person?: ○ Yes  ○ No                    │
└─────────────────────────────────────────────────┘
```

#### Section 7: Identity Documents
```
┌─────────────────────────────────────────────────┐
│ Identity Documents * (CIP Requirement)           │
│ ⚠️ At least one government-issued ID required   │
│                                                  │
│ [+ Add ID]                                      │
│                                                  │
│ ┌───────────────────────────────────────────┐  │
│ │ ID Type: Driver's License                 │  │
│ │ ID Number: DL123456789 🔒                 │  │
│ │ Issued By: CT, USA                        │  │
│ │ Issue Date: 01/15/2020                    │  │
│ │ Expiration: 01/15/2028                    │  │
│ │ [✏️ Edit] [🗑️ Delete]                     │  │
│ └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

#### Section 8: Address
```
┌─────────────────────────────────────────────────┐
│ Mailing Address                                  │
│                                                  │
│ [🔍 Search for address...] (Google Maps)        │
│                                                  │
│ Address Line 1: [___________________] *          │
│ Address Line 2: [___________________]            │
│ City: [___________________] *                    │
│ State: [Connecticut ▼] *                        │
│ ZIP Code: [_____-____] *                        │
│ Country: [USA ▼] *                              │
└─────────────────────────────────────────────────┘
```

#### Section 9: Contact Information
```
┌─────────────────────────────────────────────────┐
│ Contact Information                              │
│                                                  │
│ Email: [___________________] *                   │
│ Home Phone: [(___) ___-____]                    │
│ Work Phone: [(___) ___-____]                    │
│ Mobile Phone: [(___) ___-____] *                │
│                                                  │
│ Preferred Contact Method: [Email ▼] *           │
└─────────────────────────────────────────────────┘
```

#### Footer Actions
```
┌─────────────────────────────────────────────────┐
│                    [Save & Exit]  [← Back] [Next →] │
└─────────────────────────────────────────────────┘
```

---

### Additional Applicants Details (additionalApplicants Component)

#### Main Screen
```
┌─────────────────────────────────────────────────┐
│ Additional Applicants                            │
│                                                  │
│ [+ Add Applicant]                               │
│                                                  │
│ ┌───────────────────────────────────────────┐  │
│ │ ▼ Applicant 1: John Smith                │  │
│ │   [All fields from Primary Applicant]     │  │
│ │   [Remove Applicant]                      │  │
│ └───────────────────────────────────────────┘  │
│                                                  │
│ ┌───────────────────────────────────────────┐  │
│ │ ▼ Applicant 2: Jane Doe                  │  │
│ │   [All fields from Primary Applicant]     │  │
│ │   [Remove Applicant]                      │  │
│ └───────────────────────────────────────────┘  │
│                                                  │
│                    [Save & Exit]  [← Back] [Next →] │
└─────────────────────────────────────────────────┘
```

---

## 🧪 Testing Requirements

### Unit Tests (≥85% coverage)
- [ ] Primary Applicant persistence (new customer)
- [ ] Primary Applicant persistence (existing customer)
- [ ] Additional Applicants persistence (multiple)
- [ ] Tax ID encryption/decryption
- [ ] IdentityDocument creation/update/delete
- [ ] All validation rules (all scenarios)
- [ ] Conditional field display logic
- [ ] ApplicationForm.AccountId linkage
- [ ] StepKey__c updates
- [ ] CRUD/FLS enforcement
- [ ] Error handling

### Integration Tests
- [ ] Full wizard flow with Primary Applicant
- [ ] Full wizard flow with Additional Applicants
- [ ] Existing customer selection and pre-population
- [ ] New customer entry and Applicant creation
- [ ] Multiple applicants with mix of existing/new
- [ ] Identity Documents table functionality
- [ ] Save & Exit and resume
- [ ] Navigation between steps
- [ ] Error display and recovery

### Manual Testing Checklist
- [ ] UI renders correctly in all browsers
- [ ] Validation messages display inline
- [ ] Toggle behavior works correctly
- [ ] PersonAccount lookup searches correctly
- [ ] Identity Documents table Add/Edit/Delete works
- [ ] Address autocomplete works
- [ ] Tax ID masking displays correctly
- [ ] Conditional fields display correctly
- [ ] Save & Exit preserves data
- [ ] Next button progresses to next step
- [ ] Additional Applicants can be added/removed

---

## 📦 Deployment

### Prerequisites
- [ ] Verify Applicant custom fields exist in target org
- [ ] Verify IdentityDocument object exists
- [ ] Verify IdentityDocument.Applicant__c custom lookup field exists
- [ ] Verify encryption configuration for Tax ID field
- [ ] Verify Maps & Location Services enabled in Setup
- [ ] Verify ApplicationForm.AccountId lookup field exists
- [ ] Verify Wizard_Step__mdt records are configured

### Deployment Steps
1. [ ] Update `package.xml` with new components
2. [ ] Deploy Apex classes (WizardPersistenceService updates)
3. [ ] Deploy LWC components (applicantDetails, additionalApplicants)
4. [ ] Deploy Wizard_Step__mdt records
5. [ ] Verify in `msb-sbox`
6. [ ] Run smoke tests
7. [ ] Update documentation

---

## 📝 Implementation Notes

### Important Implementation Details

#### 1. Existing Customer Flow
- User toggles "Existing Customer"
- PersonAccount lookup appears (filtered to `IsPersonAccount = true`)
- Fields pre-populate from selected PersonAccount
- Query and display existing IdentityDocuments
- ApplicationForm.AccountId is set immediately
- Applicant.AccountId references the PersonAccount

#### 2. New Customer Flow
- User enters person data manually
- Data stored in Applicant record (Type = 'Person')
- ApplicationForm.AccountId remains null during wizard
- PersonAccount created automatically on submission
- IdentityDocuments created and linked to Applicant

#### 3. Tax ID Encryption
- Use platform Shield encryption OR custom encryption
- Display format: XXX-XX-1234 (masked)
- Store encrypted value in Tax_ID__c

#### 4. Identity Documents
- Minimum 1 ID required (CIP requirement)
- Stored in IdentityDocument standard object
- Linked to Applicant via custom lookup field `Applicant__c`
- Support Add/Edit/Delete operations
- Each row contains: ID Type, ID Number, Issued By, Issue Date, Expiration Date

#### 5. Address Autocomplete
- Use `<lightning-input-address>` component
- Requires Maps & Location Services enabled in Setup
- Google Maps autocomplete for address search
- Auto-populate City, State, Country, Postal Code
- Separate Address Line 2 field below component

#### 6. Conditional Fields
- **Citizenship**: If US Citizen = No → Show US Resident field
- **Citizenship**: If US Resident = No → Show Country of Residence field
- **Organization Role**: If Business Owner → Show Ownership Percent field
- **Phonetic Name**: If Has Phonetic Name = true → Show Phonetic Name field

#### 7. Additional Applicants
- Each applicant is a separate Applicant record
- Role = 'Additional' (vs 'Primary')
- All fields from Primary Applicant available
- Each applicant can be existing or new customer
- Each applicant has own Identity Documents table
- On submission: Create PersonAccount + ACR for each new applicant

#### 8. Persistence Logic
**Primary Applicant (on Next)**:
1. Create/Update ApplicationForm (if doesn't exist)
2. Create/Update Applicant record (Type = 'Person', Role = 'Primary')
3. Create/Update IdentityDocument records
4. Update ApplicationForm.StepKey__c
5. If existing customer: Set ApplicationForm.AccountId and Applicant.AccountId
6. If new customer: Flag for PersonAccount creation on submission

**Additional Applicants (on Next)**:
1. For each applicant in list:
   - Create/Update Applicant record (Type = 'Person', Role = 'Additional')
   - Create/Update IdentityDocument records
   - If existing customer: Set Applicant.AccountId
   - If new customer: Flag for PersonAccount + ACR creation on submission
2. Update ApplicationForm.StepKey__c
3. Handle bulk DML efficiently

---

## 🔗 Dependencies

- **Depends on**: 
  - ST-001 (Wizard Foundation - must be complete)
  - ST-002 (Persist Application Data - persistence service must exist)
  - ST-004 (Capture Business Details - for business applications)
- **Blocks**: 
  - Future stories for Review & Submit
- **Related**: 
  - ST-003 (Pre-populate Wizard Data - will use applicant data)

---

## ✅ Definition of Done

### Phase 1: Primary Applicant Details
- [ ] Primary Applicant LWC component created and functional
- [ ] All required fields render correctly
- [ ] Client-side validation implemented for all rules
- [ ] Existing customer toggle works with PersonAccount lookup
- [ ] New customer entry creates Applicant record
- [ ] Identity Documents table works (Add/Edit/Delete)
- [ ] Tax ID encryption implemented and tested
- [ ] Address autocomplete works
- [ ] Conditional fields display correctly
- [ ] WizardPersistenceService.upsertPrimaryApplicantStep() implemented
- [ ] IdentityDocument records created/updated correctly
- [ ] ApplicationForm.AccountId linkage works correctly
- [ ] StepKey__c updates correctly
- [ ] CRUD/FLS enforced with WITH USER_MODE
- [ ] Unit tests ≥85% coverage
- [ ] Integration tests pass
- [ ] Deployed to `msb-sbox` and verified
- [ ] Session notes added documenting implementation

### Phase 2: Additional Applicants Details
- [ ] Additional Applicants LWC component created and functional
- [ ] Dynamic applicant list works (Add/Remove)
- [ ] All fields from Primary Applicant available for each additional applicant
- [ ] Identity Documents table works for each applicant
- [ ] Typeahead search for existing PersonAccounts works
- [ ] Validation works for all applicants
- [ ] WizardPersistenceService.upsertAdditionalApplicantsStep() implemented
- [ ] Multiple Applicant records created correctly
- [ ] Multiple IdentityDocument records created correctly
- [ ] Bulk DML handled efficiently
- [ ] Unit tests ≥85% coverage
- [ ] Integration tests pass
- [ ] Deployed to `msb-sbox` and verified
- [ ] Session notes added documenting implementation

---

**Assigned To**: Cristiano Sinadino  
**Related Stories**: ST-001 (Wizard Foundation), ST-002 (Persist Application Data), ST-003 (Pre-populate Wizard Data), ST-004 (Capture Business Details)

