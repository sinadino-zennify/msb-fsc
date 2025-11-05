<!-- 
🔴 AI AGENTS: READ FIRST - /docs/01-foundation/data-model.md for correct object names
✅ Correct: ApplicationForm, Applicant, Account (Business), AccountContactRelation, Opportunity
❌ Wrong: Application__c, Applicant__c, Loan__c, Business_Relationship__c
-->

# ST-002: Populate Existing Data from Opportunity

**Story ID**: ST-002  
**Work Item**: SVC-002, LWC-002  
**Status**: Not Started  
**Created**: 2025-11-05  
**Last Updated**: 2025-11-05

---

## 📋 Story Overview

**As a** Salesforce user starting a Deposit Account Opening wizard from an Opportunity  
**I want** the wizard to automatically populate Business and Personal Information from the related Account and AccountContactRelations  
**So that** I don't have to re-enter data that already exists in Salesforce

---

## 🎯 Acceptance Criteria

- [ ] Wizard identifies the source object type (Opportunity or ApplicationForm) from `recordId`
- [ ] When source is Opportunity:
  - [ ] Query Business Account via `Opportunity.AccountId`
  - [ ] Populate all applicable fields in the Business Information step from Account data
- [ ] Query all AccountContactRelations (ACRs) tied to the Business Account
- [ ] Identify Primary Applicant from ACR where `Roles` field contains "Primary Applicant"
  - [ ] If no Primary Applicant found, skip primary applicant population
  - [ ] If Primary Applicant found, populate Personal Information step from the related PersonAccount
- [ ] Collect remaining ACRs (non-primary) and their PersonAccount records
- [ ] Prepare data structure for Additional Applicants step (Store in memory, do not persist. This will be used to populate the Additional Applicants step)
- [ ] All queries enforce CRUD/FLS and handle errors gracefully
- [ ] Service method returns structured DTO with Business, Primary Applicant, and Additional Applicants data
- [ ] Unit tests ≥85% coverage on new Apex service
- [ ] Deployed to `msb-sbox` and verified with test Opportunity records

---

## 🛠️ Tasks and Sub-Tasks

1. [ ] Design Data Transfer Objects (DTOs)
   - [ ] 1.1 Create `OpportunityDataDTO` with nested structures:
     - `BusinessInfoDTO` (Account fields)
     - `PrimaryApplicantDTO` (PersonAccount fields)
     - `List<AdditionalApplicantDTO>` (PersonAccount fields + ACR metadata)
   - [ ] 1.2 Map DTO fields to wizard step field names for easy binding
   - [ ] 1.3 Document field mappings in code comments

2. [ ] Implement Apex: `OpportunityDataService`
   - [ ] 2.1 Create `@AuraEnabled` method `getOpportunityData(Id recordId)`
   - [ ] 2.2 Determine object type from `recordId` (Opportunity vs ApplicationForm)
   - [ ] 2.3 If Opportunity:
     - [ ] 2.3.1 Query Opportunity with AccountId
     - [ ] 2.3.2 Query Business Account with all fields needed for Business Information step
     - [ ] 2.3.3 Query AccountContactRelations where `AccountId = Opportunity.AccountId`
     - [ ] 2.3.4 Identify Primary Applicant ACR (Roles contains 'Primary Applicant')
     - [ ] 2.3.5 Query PersonAccount for Primary Applicant Contact
     - [ ] 2.3.6 Query PersonAccounts for all remaining ACRs
   - [ ] 2.4 If ApplicationForm:
     - [ ] 2.4.1 Return empty DTO (we will handle this in a different story)
   - [ ] 2.5 Enforce CRUD/FLS on all queries with `WITH USER_MODE`
   - [ ] 2.6 Handle errors and return structured error messages

3. [ ] Implement field mapping logic
   - [ ] 3.1 Map Account fields to Business Information step fields
   - [ ] 3.2 Map PersonAccount fields to Personal Information step fields
   - [ ] 3.3 Map ACR metadata (Roles, IsPrimary, etc.) to Additional Applicants structure
   - [ ] 3.4 Document unmapped fields and reasons in code comments

4. [ ] Update `WizardPersistenceService` (if needed)
   - [ ] 4.1 Review current persistence logic for Business and Personal Information steps
   - [ ] 4.2 Ensure compatibility with pre-populated data from Opportunity
   - [ ] 4.3 Add logic to handle partial updates vs. full creates

5. [ ] Update LWC: `daoWizardContainer`
   - [ ] 5.1 On component initialization, call `OpportunityDataService.getOpportunityData(recordId)`
   - [ ] 5.2 Store returned DTO in component state
   - [ ] 5.3 Pass Business data to Business Information step
   - [ ] 5.4 Pass Primary Applicant data to Personal Information step
   - [ ] 5.5 Pass Additional Applicants list to Additional Applicants step (display only)

6. [ ] Update step LWCs to accept pre-populated data
   - [ ] 6.1 Update `businessInformation` step to accept and bind pre-populated Account data
   - [ ] 6.2 Update `personalInformation` step to accept and bind pre-populated PersonAccount data
   - [ ] 6.3 Update `additionalApplicants` step to display list of available ACRs (no persistence yet)

7. [ ] Unit testing
   - [ ] 7.1 Test `OpportunityDataService` with Opportunity recordId
   - [ ] 7.2 Test with ApplicationForm recordId (should return empty DTO)
   - [ ] 7.3 Test Primary Applicant identification (with and without 'Primary Applicant' role)
   - [ ] 7.4 Test with multiple ACRs
   - [ ] 7.5 Test CRUD/FLS enforcement
   - [ ] 7.6 Test error handling (invalid recordId, no Account, no ACRs)
   - [ ] 7.7 Ensure ≥85% code coverage

8. [ ] Documentation
   - [ ] 8.1 Document field mapping decisions in session notes
   - [ ] 8.2 Update data model documentation if needed
   - [ ] 8.3 Add code comments explaining ACR role identification logic

9. [ ] Deployment & verification
   - [ ] 9.1 Update `package.xml` with new Apex classes
   - [ ] 9.2 Deploy to `msb-sbox`
   - [ ] 9.3 Create test Opportunity with Business Account and ACRs
   - [ ] 9.4 Verify wizard pre-populates data correctly
   - [ ] 9.5 Verify Additional Applicants list displays correctly

---

## 🔧 Technical Implementation

### Objects Involved
- **Opportunity** (Standard) – Source record for wizard launch
- **Account** (Business) – Business information source
- **AccountContactRelation** (Standard) – Links Contacts to Business Account
- **Account** (PersonAccount) – Personal information source for applicants
- **ApplicationForm** (FSC) – Target for wizard data (no changes in this story)

### Key Fields

#### Opportunity
- `Id`
- `AccountId` (lookup to Business Account)

#### Account (Business)
- All fields needed for Business Information step (TBD based on step design)
- Examples: `Name`, `BillingAddress`, `Phone`, `Industry`, `AnnualRevenue`

#### AccountContactRelation
- `Id`
- `AccountId` (Business Account)
- `ContactId` (PersonAccount)
- `Roles` (multi-select picklist, contains "Primary Applicant")
- `IsDirect`
- `IsActive`

#### Account (PersonAccount)
- All fields needed for Personal Information step (TBD based on step design)
- Examples: `FirstName`, `LastName`, `PersonEmail`, `PersonBirthdate`, `PersonMailingAddress`

### Apex Classes
- `OpportunityDataService.cls` (new)
- `OpportunityDataDTO.cls` (new - inner classes for nested structure)
- `OpportunityDataServiceTest.cls` (new)
- `WizardPersistenceService.cls` (potential updates)

### LWC Components
- `daoWizardContainer` (updates to fetch and pass data)
- `businessInformation` (updates to accept pre-populated data)
- `personalInformation` (updates to accept pre-populated data)
- `additionalApplicants` (updates to display ACR list)

### Query Strategy

```apex
// Pseudo-code for OpportunityDataService
public static OpportunityDataDTO getOpportunityData(Id recordId) {
    // 1. Determine object type
    String objectType = recordId.getSObjectType().getDescribe().getName();
    
    if (objectType == 'Opportunity') {
        // 2. Query Opportunity
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :recordId WITH USER_MODE];
        
        // 3. Query Business Account
        Account businessAccount = [SELECT Id, Name, ... FROM Account WHERE Id = :opp.AccountId WITH USER_MODE];
        
        // 4. Query ACRs
        List<AccountContactRelation> acrs = [
            SELECT Id, ContactId, Roles, Contact.FirstName, Contact.LastName, ...
            FROM AccountContactRelation 
            WHERE AccountId = :opp.AccountId AND IsActive = true
            WITH USER_MODE
        ];
        
        // 5. Identify Primary Applicant
        AccountContactRelation primaryACR = null;
        List<AccountContactRelation> additionalACRs = new List<AccountContactRelation>();
        
        for (AccountContactRelation acr : acrs) {
            if (acr.Roles != null && acr.Roles.contains('Primary Applicant')) {
                primaryACR = acr;
            } else {
                additionalACRs.add(acr);
            }
        }
        
        // 6. Build and return DTO
        return new OpportunityDataDTO(businessAccount, primaryACR, additionalACRs);
    }
    
    // ApplicationForm or other - return empty DTO
    return new OpportunityDataDTO();
}
```

### Notes
- Use `WITH USER_MODE` for all SOQL queries to enforce CRUD/FLS
- ACR `Roles` field is a multi-select picklist; use `.contains('Primary Applicant')`
- If multiple ACRs have "Primary Applicant" role, take the first one
- PersonAccount fields are accessed via `Contact` object (e.g., `Contact.FirstName`)
- Additional Applicants step will only display data in this story; persistence is deferred to ST-003

---

## 🧪 Testing Requirements

- [ ] Apex unit tests ≥85% coverage on `OpportunityDataService`
- [ ] Test scenarios:
  - Opportunity with Business Account and Primary Applicant ACR
  - Opportunity with Business Account but no Primary Applicant ACR
  - Opportunity with Business Account and multiple ACRs
  - ApplicationForm recordId (should return empty DTO)
  - Invalid recordId (error handling)
  - CRUD/FLS violations (error handling)
- [ ] LWC tests for data binding (smoke tests)

---

## 📦 Deployment

- [ ] Add new Apex classes to `package.xml`
- [ ] Deploy to `msb-sbox`
- [ ] Create test data:
  - Business Account with 3+ Contacts
  - AccountContactRelations with one marked as "Primary Applicant"
  - Opportunity linked to Business Account
- [ ] Verify wizard pre-populates correctly when launched from Opportunity

---

## 📝 Implementation Notes

- This story focuses on **data retrieval and population**, not persistence
- Additional Applicants step will display available ACRs but won't persist them to ApplicationForm yet
- Field mapping decisions should be documented in session notes
- Consider creating a field mapping matrix: `Account.FieldName → BusinessInfoStep.FieldName`
- Future story (ST-003) will handle Additional Applicants persistence and typeahead functionality

---

## 🔗 Dependencies

- **Depends on**: ST-001 (Wizard Foundation must be complete)
- **Blocks**: ST-003 (Additional Applicants Typeahead - will use the ACR data structure from this story)

---

## ✅ Definition of Done

- [ ] `OpportunityDataService` implemented and tested
- [ ] DTOs created with proper field mappings
- [ ] Wizard container fetches and passes data to steps
- [ ] Business Information step pre-populates from Account
- [ ] Personal Information step pre-populates from Primary Applicant PersonAccount
- [ ] Additional Applicants step displays list of available ACRs
- [ ] All queries enforce CRUD/FLS with `WITH USER_MODE`
- [ ] Unit tests ≥85% coverage
- [ ] Deployed to `msb-sbox` and verified with test Opportunity
- [ ] Session notes added documenting field mappings and design decisions

---

**Assigned To**: [Developer Name]  
**Related Stories**: ST-001 (Wizard Foundation), ST-003 (Additional Applicants Typeahead)
