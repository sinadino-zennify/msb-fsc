public with sharing class WizardDataService {

    @AuraEnabled(cacheable=true)
    public static WizardDataDTO getWizardData(Id recordId, String wizardApiName) {
        WizardDataDTO dto = new WizardDataDTO();
        dto.wizardApiName = wizardApiName;

        if (recordId == null) {
            dto.message = 'No context record provided.';
            return dto;
        }

        try {
            String objectApiName = recordId.getSObjectType().getDescribe().getName();
            dto.entryPointType = objectApiName;

            if (objectApiName == 'Opportunity') {
                handleOpportunity(recordId, dto);
            } else if (objectApiName == 'Account') {
                handleAccount(recordId, dto);
            } else if (objectApiName == 'ApplicationForm') {
                handleApplicationForm(recordId, dto);
            } else {
                dto.message = 'Unsupported entry point type: ' + objectApiName;
                dto.accountType = 'Unknown';
            }
        } catch (Exception e) {
            dto.message = 'Failed to load wizard data: ' + e.getMessage();
        }

        return dto;
    }

    private static void handleOpportunity(Id opportunityId, WizardDataDTO dto) {
        Opportunity opp = [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id = :opportunityId
            WITH USER_MODE
            LIMIT 1
        ];

        if (opp.AccountId == null) {
            dto.message = 'Opportunity is not related to an Account. Wizard data will start blank.';
            dto.accountType = 'None';
            return;
        }

        dto.contextAccountId = opp.AccountId;
        handleAccount(opp.AccountId, dto);
    }

    private static void handleAccount(Id accountId, WizardDataDTO dto) {
        Account acc = [
            SELECT Id,
                   IsPersonAccount,
                   Name,
                   Type,
                   Business_Type__c,
                   Business_Tax_ID__c,
                   Business_Tax_ID_Type__c,
                   Phone,
                   Business_Phone__c,
                   Business_Email__c,
                   Business_Home_Phone__c,
                   Business_Mobile_Phone__c,
                   Business_Work_Phone__c,
                   Website,
                   BillingStreet,
                   BillingCity,
                   BillingState,
                   BillingPostalCode,
                   BillingCountry,
                   AnnualRevenue,
                   NumberOfEmployees,
                   Industry,
                   Description,
                   SW_Doing_Business_As__c,
                   SW_Date_Business_Established__c,
                   SW_Business_Registration_State__c,
                   Date_Established__c,
                   NAICS_Lookup__c,
                   NAICS_Code__c,
                   NAICS_Description__c,
                   FinServ__PrimaryContact__c,
                   PersonBirthdate,
                   PersonEmail,
                   PersonMobilePhone,
                   PersonHomePhone,
                   Salutation,
                   FirstName,
                   LastName,
                   SSN_Tax_Id__c,
                   Tax_ID_Type__c,
                   Government_ID_Type__c,
                   Government_ID_Number__c,
                   ID_Issuing_Country__c,
                   ID_Issuing_State__c,
                   ID_Issue_Date__c,
                   ID_Expiration_Date__c
            FROM Account
            WHERE Id = :accountId
            WITH USER_MODE
            LIMIT 1
        ];

        dto.contextAccountId = acc.Id;

        if (acc.IsPersonAccount) {
            dto.accountType = 'Person';
            dto.hideBusinessStep = false;
            dto.applicantInfo = buildApplicantFromPersonAccount(acc);
            dto.hasApplicantInfo = dto.applicantInfo != null;
            dto.hasPrimaryContact = dto.hasApplicantInfo;

            // Initialize an empty business info structure so the Business step renders
            dto.businessInfo = new BusinessInfoDTO();
            dto.businessInfo.businessAccountType = 'new';
            dto.businessInfo.primaryContactType = 'new';
            dto.hasBusinessInfo = false;

            dto.message = 'Pre-populated personal information from Person Account.';
        } else {
            dto.accountType = 'Business';
            dto.hideBusinessStep = false;
            dto.businessInfo = buildBusinessInfoFromAccount(acc);
            dto.hasBusinessInfo = dto.businessInfo != null;

            if (acc.FinServ__PrimaryContact__c != null) {
                Contact primaryContact = [
                    SELECT Id,
                           Salutation,
                           FirstName,
                           LastName,
                           Title,
                           Email,
                           Phone,
                           MobilePhone,
                           HomePhone,
                           Birthdate,
                           MailingStreet,
                           MailingCity,
                           MailingState,
                           MailingPostalCode,
                           MailingCountry,
                           AccountId,
                           Account.PersonBirthdate,
                           Account.PersonEmail,
                           Account.PersonMobilePhone,
                           Account.PersonHomePhone,
                           Account.PersonMailingStreet,
                           Account.PersonMailingCity,
                           Account.PersonMailingState,
                           Account.PersonMailingPostalCode,
                           Account.PersonMailingCountry,
                           Account.BillingStreet,
                           Account.BillingCity,
                           Account.BillingState,
                           Account.BillingPostalCode,
                           Account.BillingCountry,
                           Account.Business_Email__c,
                           Account.Business_Home_Phone__c,
                           Account.Business_Mobile_Phone__c,
                           Account.Business_Work_Phone__c,
                           Account.Salutation,
                           Account.FirstName,
                           Account.LastName,
                           Account.SSN_Tax_Id__c,
                           Account.Tax_ID_Type__c,
                           Account.Government_ID_Type__c,
                           Account.Government_ID_Number__c,
                           Account.ID_Issuing_Country__c,
                           Account.ID_Issuing_State__c,
                           Account.ID_Issue_Date__c,
                           Account.ID_Expiration_Date__c,
                           Account.IsPersonAccount
                    FROM Contact
                    WHERE Id = :acc.FinServ__PrimaryContact__c
                    WITH USER_MODE
                    LIMIT 1
                ];

                System.debug('🔎 WizardDataService: Primary contact loaded -> ' + JSON.serializePretty(primaryContact));
                System.debug('🔎 WizardDataService: Primary contact related Account -> ' + JSON.serializePretty(primaryContact.Account));

                dto.applicantInfo = buildApplicantFromPrimaryContact(primaryContact);
                dto.hasApplicantInfo = dto.applicantInfo != null;
                dto.hasPrimaryContact = dto.hasApplicantInfo;

                if (dto.businessInfo == null) {
                    dto.businessInfo = new BusinessInfoDTO();
                }

                if (primaryContact.AccountId != null && primaryContact.AccountId != acc.Id) {
                    // Primary contact is a Person Account; allow selection in the lookup
                    dto.businessInfo.primaryContactType = 'existing';
                    dto.businessInfo.selectedContactId = primaryContact.AccountId;
                } else {
                    dto.businessInfo.primaryContactType = 'new';
                }

                dto.businessInfo.primaryContactName = buildFullName(primaryContact.Salutation, primaryContact.FirstName, primaryContact.LastName);
                dto.businessInfo.primaryContactTitle = primaryContact.Title;
            } else {
                dto.businessInfo.primaryContactType = 'new';
                dto.businessInfo.primaryContactName = null;
                dto.businessInfo.primaryContactTitle = null;
                dto.hasPrimaryContact = false;
            }

            dto.message = 'Pre-populated business information from Account.';
        }
    }

    private static BusinessInfoDTO buildBusinessInfoFromAccount(Account acc) {
        BusinessInfoDTO info = new BusinessInfoDTO();
        info.businessAccountType = 'existing';
        info.selectedAccountId = acc.Id;

        info.businessName = acc.Name;
        info.dbaName = String.isNotBlank(acc.SW_Doing_Business_As__c) ? acc.SW_Doing_Business_As__c : null;
        // Use Business_Type__c only - do NOT fall back to Account.Type as it has different values
        info.businessType = acc.Business_Type__c;
        info.taxId = acc.Business_Tax_ID__c; // Use custom field, FinServ__TaxID__c not available

        Date derivedEstablishedDate = acc.SW_Date_Business_Established__c != null
            ? acc.SW_Date_Business_Established__c
            : acc.Date_Established__c;
        info.dateEstablished = formatDate(derivedEstablishedDate);

        info.stateOfIncorporation = normalizeStateName(acc.SW_Business_Registration_State__c);

        info.naicsCodeId = acc.NAICS_Lookup__c;
        info.naicsCode = acc.NAICS_Code__c;
        info.naicsDescription = acc.NAICS_Description__c;
        info.industryType = normalizeIndustry(acc.Industry);
        info.businessDescription = acc.Description;

        info.businessPhone = String.isNotBlank(acc.Business_Phone__c) ? acc.Business_Phone__c : acc.Phone;
        info.businessEmail = acc.Business_Email__c;
        info.businessHomePhone = acc.Business_Home_Phone__c;
        info.businessMobilePhone = acc.Business_Mobile_Phone__c;
        info.businessWebsite = acc.Website;

        info.annualRevenue = acc.AnnualRevenue;
        info.numberOfEmployees = convertEmployeeCountToRange(acc.NumberOfEmployees);

        String[] streetLines = splitStreet(acc.BillingStreet);
        info.businessStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
        info.businessStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
        info.businessCity = acc.BillingCity;
        info.businessState = normalizeStateName(acc.BillingState);
        info.businessPostalCode = acc.BillingPostalCode;
        info.businessCountry = normalizeCountryName(acc.BillingCountry);

        info.primaryContactType = 'new';
        info.selectedContactId = null;

        return info;
    }

    private static ApplicantInfoDTO buildApplicantFromPersonAccount(Account personAccount) {
        ApplicantInfoDTO applicant = new ApplicantInfoDTO();
        applicant.salutation = normalizeSalutation(personAccount.Salutation);
        applicant.firstName = personAccount.FirstName;
        applicant.lastName = personAccount.LastName;
        applicant.birthDate = formatDate(personAccount.PersonBirthdate);
        applicant.taxId = personAccount.SSN_Tax_Id__c;
        applicant.taxIdType = personAccount.Tax_ID_Type__c;
        applicant.email = personAccount.PersonEmail;
        applicant.mobilePhone = personAccount.Business_Mobile_Phone__c;
        applicant.homePhone = personAccount.Business_Home_Phone__c;
        applicant.workPhone = personAccount.Business_Work_Phone__c;

        // Use BillingAddress for both PersonAccount and Business Account
        String[] streetLines = splitStreet(personAccount.BillingStreet);
        applicant.mailingStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
        applicant.mailingStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
        applicant.mailingCity = personAccount.BillingCity;
        applicant.mailingState = normalizeStateName(personAccount.BillingState);
        applicant.mailingPostalCode = personAccount.BillingPostalCode;
        applicant.mailingCountry = normalizeCountryName(personAccount.BillingCountry);

        applicant.governmentIdType = personAccount.Government_ID_Type__c;
        applicant.governmentIdNumber = personAccount.Government_ID_Number__c;
        applicant.idIssuingCountry = personAccount.ID_Issuing_Country__c;
        applicant.idIssuingState = personAccount.ID_Issuing_State__c;
        applicant.idIssueDate = formatDate(personAccount.ID_Issue_Date__c);
        applicant.idExpirationDate = formatDate(personAccount.ID_Expiration_Date__c);

        return applicant;
    }

    private static ApplicantInfoDTO buildApplicantFromPrimaryContact(Contact contact) {
        if (contact == null) {
            return null;
        }

        // Prefer Person Account fields when available
        if (contact.AccountId != null && contact.Account != null && contact.Account.IsPersonAccount) {
            return buildApplicantFromPersonAccount(contact.Account);
        }

        Account relatedAccount = contact.Account;

        ApplicantInfoDTO applicant = new ApplicantInfoDTO();
        applicant.salutation = contact.Salutation;
        applicant.firstName = contact.FirstName;
        applicant.lastName = contact.LastName;
        applicant.birthDate = formatDate(contact.Birthdate);

        // Prefer contact fields, fall back to Account fields when available
        applicant.email = String.isNotBlank(contact.Email) ? contact.Email : relatedAccount != null ? relatedAccount.Business_Email__c : null;
        applicant.mobilePhone = String.isNotBlank(contact.MobilePhone)
            ? contact.MobilePhone
            : relatedAccount != null ? relatedAccount.Business_Mobile_Phone__c : null;
        applicant.homePhone = String.isNotBlank(contact.HomePhone)
            ? contact.HomePhone
            : relatedAccount != null ? relatedAccount.Business_Home_Phone__c : null;
        applicant.workPhone = String.isNotBlank(contact.Phone)
            ? contact.Phone
            : relatedAccount != null ? relatedAccount.Business_Work_Phone__c : null;

        // Address – use Account Billing address if present, otherwise contact mailing
        String billingStreet = relatedAccount != null ? relatedAccount.BillingStreet : null;
        String[] streetLines = splitStreet(String.isNotBlank(billingStreet) ? billingStreet : contact.MailingStreet);
        applicant.mailingStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
        applicant.mailingStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
        String accountBillingCity = relatedAccount != null ? relatedAccount.BillingCity : null;
        applicant.mailingCity = String.isNotBlank(accountBillingCity)
            ? accountBillingCity
            : contact.MailingCity;
        String accountBillingState = relatedAccount != null ? relatedAccount.BillingState : null;
        applicant.mailingState = normalizeStateName(String.isNotBlank(accountBillingState) ? accountBillingState : contact.MailingState);
        String accountBillingPostalCode = relatedAccount != null ? relatedAccount.BillingPostalCode : null;
        applicant.mailingPostalCode = String.isNotBlank(accountBillingPostalCode) ? accountBillingPostalCode : contact.MailingPostalCode;
        String accountBillingCountry = relatedAccount != null ? relatedAccount.BillingCountry : null;
        applicant.mailingCountry = normalizeCountryName(String.isNotBlank(accountBillingCountry) ? accountBillingCountry : contact.MailingCountry);

        return applicant;
    }

    private static String formatDate(Date dateValue) {
        return dateValue == null ? null : String.valueOf(dateValue);
    }

    private static String convertEmployeeCountToRange(Integer employees) {
        if (employees == null) {
            return null;
        }
        if (employees <= 10) {
            return '1-10';
        }
        if (employees <= 50) {
            return '11-50';
        }
        if (employees <= 100) {
            return '51-100';
        }
        if (employees <= 500) {
            return '101-500';
        }
        return '500+';
    }

    private static String normalizeIndustry(String industryValue) {
        if (String.isBlank(industryValue)) {
            return null;
        }

        String normalized = industryValue.trim().toLowerCase();
        Map<String, String> supported = new Map<String, String>{
            'agriculture' => 'Agriculture',
            'construction' => 'Construction',
            'education' => 'Education',
            'finance' => 'Finance',
            'financial services' => 'Finance',
            'healthcare' => 'Healthcare',
            'hospitality' => 'Hospitality',
            'consulting' => 'Professional Services',
            'manufacturing' => 'Manufacturing',
            'professional services' => 'Professional Services',
            'real estate' => 'Real Estate',
            'retail' => 'Retail',
            'technology' => 'Technology',
            'transportation' => 'Transportation'
        };

        if (supported.containsKey(normalized)) {
            return supported.get(normalized);
        }

        return 'Other';
    }

    private static String[] splitStreet(String street) {
        if (String.isBlank(street)) {
            return null;
        }
        return street.split('\n');
    }

    private static String buildFullName(String salutation, String firstName, String lastName) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(salutation)) {
            parts.add(salutation);
        }
        if (String.isNotBlank(firstName)) {
            parts.add(firstName);
        }
        if (String.isNotBlank(lastName)) {
            parts.add(lastName);
        }
        return parts.isEmpty() ? null : String.join(parts, ' ');
    }

    public class WizardDataDTO {
        @AuraEnabled public String wizardApiName;
        @AuraEnabled public String entryPointType;
        @AuraEnabled public String accountType;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean hideBusinessStep = false;
        @AuraEnabled public Boolean hasBusinessInfo = false;
        @AuraEnabled public Boolean hasApplicantInfo = false;
        @AuraEnabled public Boolean hasPrimaryContact = false;
        @AuraEnabled public Id contextAccountId;
        @AuraEnabled public BusinessInfoDTO businessInfo;
        @AuraEnabled public ApplicantInfoDTO applicantInfo;
        @AuraEnabled public List<ApplicantInfoDTO> additionalApplicants;
        @AuraEnabled public ProductSelectionDTO productSelection;
        @AuraEnabled public DocumentsDTO documents;
        @AuraEnabled public ServicesDTO services;
        @AuraEnabled public RelationshipDTO relationship;
        @AuraEnabled public String resumeAtStep; // StepKey__c from ApplicationForm
    }

    public class BusinessInfoDTO {
        @AuraEnabled public String businessAccountType;
        @AuraEnabled public Id selectedAccountId;
        @AuraEnabled public String primaryContactType;
        @AuraEnabled public Id selectedContactId;
        @AuraEnabled public String businessName;
        @AuraEnabled public String dbaName;
        @AuraEnabled public String businessType;
        @AuraEnabled public String taxId;
        @AuraEnabled public String dateEstablished;
        @AuraEnabled public String stateOfIncorporation;
        @AuraEnabled public Id naicsCodeId;
        @AuraEnabled public String naicsCode;
        @AuraEnabled public String naicsDescription;
        @AuraEnabled public String industryType;
        @AuraEnabled public String businessDescription;
        @AuraEnabled public String businessPhone;
        @AuraEnabled public String businessEmail;
        @AuraEnabled public String businessHomePhone;
        @AuraEnabled public String businessMobilePhone;
        @AuraEnabled public String businessWebsite;
        @AuraEnabled public String primaryContactName;
        @AuraEnabled public String primaryContactTitle;
        @AuraEnabled public Decimal annualRevenue;
        @AuraEnabled public String numberOfEmployees;
        @AuraEnabled public String businessStreetLine1;
        @AuraEnabled public String businessStreetLine2;
        @AuraEnabled public String businessCity;
        @AuraEnabled public String businessState;
        @AuraEnabled public String businessPostalCode;
        @AuraEnabled public String businessCountry;
        @AuraEnabled public String governmentIdType;
        @AuraEnabled public String governmentIdNumber;
        @AuraEnabled public String idIssuingCountry;
        @AuraEnabled public String idIssuingState;
        @AuraEnabled public String idIssueDate;
        @AuraEnabled public String idExpirationDate;
    }

    public class ApplicantInfoDTO {
        @AuraEnabled public String salutation;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String birthDate;
        @AuraEnabled public String taxIdType;
        @AuraEnabled public String taxId;
        @AuraEnabled public String email;
        @AuraEnabled public String mobilePhone;
        @AuraEnabled public String homePhone;
        @AuraEnabled public String workPhone;
        @AuraEnabled public String mailingStreetLine1;
        @AuraEnabled public String mailingStreetLine2;
        @AuraEnabled public String mailingCity;
        @AuraEnabled public String mailingState;
        @AuraEnabled public String mailingPostalCode;
        @AuraEnabled public String mailingCountry;
        @AuraEnabled public String governmentIdType;
        @AuraEnabled public String governmentIdNumber;
        @AuraEnabled public String idIssuingCountry;
        @AuraEnabled public String idIssuingState;
        @AuraEnabled public String idIssueDate;
        @AuraEnabled public String idExpirationDate;
    }

    /**
     * Normalize country code/name to match LWC picklist values
     * LWC expects: 'USA', 'Canada', 'Mexico', 'Other'
     */
    private static String normalizeCountryName(String countryValue) {
        if (String.isBlank(countryValue)) {
            return null;
        }

        String normalized = countryValue.trim().toUpperCase();

        // Map common US variations to 'USA'
        if (normalized == 'US' || normalized == 'USA' || 
            normalized == 'UNITED STATES' || normalized == 'UNITED STATES OF AMERICA') {
            return 'USA';
        }

        // Map Canada variations
        if (normalized == 'CA' || normalized == 'CANADA' || normalized == 'CAN') {
            return 'Canada';
        }

        // Map Mexico variations
        if (normalized == 'MX' || normalized == 'MEXICO' || normalized == 'MEX') {
            return 'Mexico';
        }

        // Everything else maps to 'Other'
        return 'Other';
    }

    /**
     * Normalize state abbreviation/name to full state name
     * LWC expects full state names like 'California', 'New York', etc.
     * Account typically stores abbreviations like 'CA', 'NY', etc.
     */
    private static String normalizeStateName(String stateValue) {
        if (String.isBlank(stateValue)) {
            return null;
        }

        // If it's already a full state name (length > 2), return as-is
        String trimmed = stateValue.trim();
        if (trimmed.length() > 2) {
            return trimmed;
        }

        // Map common state abbreviations to full names
        Map<String, String> stateMap = new Map<String, String>{
            'AL' => 'Alabama', 'AK' => 'Alaska', 'AZ' => 'Arizona', 'AR' => 'Arkansas',
            'CA' => 'California', 'CO' => 'Colorado', 'CT' => 'Connecticut', 'DE' => 'Delaware',
            'FL' => 'Florida', 'GA' => 'Georgia', 'HI' => 'Hawaii', 'ID' => 'Idaho',
            'IL' => 'Illinois', 'IN' => 'Indiana', 'IA' => 'Iowa', 'KS' => 'Kansas',
            'KY' => 'Kentucky', 'LA' => 'Louisiana', 'ME' => 'Maine', 'MD' => 'Maryland',
            'MA' => 'Massachusetts', 'MI' => 'Michigan', 'MN' => 'Minnesota', 'MS' => 'Mississippi',
            'MO' => 'Missouri', 'MT' => 'Montana', 'NE' => 'Nebraska', 'NV' => 'Nevada',
            'NH' => 'New Hampshire', 'NJ' => 'New Jersey', 'NM' => 'New Mexico', 'NY' => 'New York',
            'NC' => 'North Carolina', 'ND' => 'North Dakota', 'OH' => 'Ohio', 'OK' => 'Oklahoma',
            'OR' => 'Oregon', 'PA' => 'Pennsylvania', 'RI' => 'Rhode Island', 'SC' => 'South Carolina',
            'SD' => 'South Dakota', 'TN' => 'Tennessee', 'TX' => 'Texas', 'UT' => 'Utah',
            'VT' => 'Vermont', 'VA' => 'Virginia', 'WA' => 'Washington', 'WV' => 'West Virginia',
            'WI' => 'Wisconsin', 'WY' => 'Wyoming', 'DC' => 'District of Columbia',
            'PR' => 'Puerto Rico', 'VI' => 'U.S. Virgin Islands', 'GU' => 'Guam',
            'AS' => 'American Samoa', 'MP' => 'Northern Mariana Islands'
        };

        String upperState = trimmed.toUpperCase();
        return stateMap.containsKey(upperState) ? stateMap.get(upperState) : trimmed;
    }

    /**
     * Normalize salutation to match LWC picklist values where we include a trailing period.
     */
    private static String normalizeSalutation(String salutationValue) {
        if (String.isBlank(salutationValue)) {
            return null;
        }

        String trimmed = salutationValue.trim();
        String upperNoPunctuation = trimmed.replace('.', '').toUpperCase();

        Map<String, String> salutationMap = new Map<String, String>{
            'MR' => 'Mr.',
            'MRS' => 'Mrs.',
            'MS' => 'Ms.',
            'DR' => 'Dr.',
            'PROF' => 'Prof.'
        };

        if (salutationMap.containsKey(upperNoPunctuation)) {
            return salutationMap.get(upperNoPunctuation);
        }

        return trimmed;
    }

    public class ProductSelectionDTO {
        @AuraEnabled public String productCode;
    }

    public class DocumentsDTO {
        @AuraEnabled public List<DocumentDTO> documents;
    }

    public class DocumentDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String description;
        @AuraEnabled public String fileName;
        @AuraEnabled public String contentVersionId;
    }

    public class ServicesDTO {
        @AuraEnabled public List<String> selectedServices;
    }

    public class RelationshipDTO {
        @AuraEnabled public List<RoleAssignmentDTO> assignments;
    }

    public class RoleAssignmentDTO {
        @AuraEnabled public Id productId;
        @AuraEnabled public Id applicantId;
        @AuraEnabled public List<String> roles;
    }

    /**
     * Handle ApplicationForm entry point - Resume existing application
     * Query all data from Applicants, Products, Documents, Services, and Relationships
     * to pre-populate all wizard steps for resume functionality
     */
    private static void handleApplicationForm(Id applicationFormId, WizardDataDTO dto) {
        System.debug('🔄 handleApplicationForm START - ApplicationFormId: ' + applicationFormId);
        
        try {
            // Query ApplicationForm to get StepKey__c and AccountId
            ApplicationForm appForm = [
                SELECT Id, StepKey__c, AccountId, OpportunityId
                FROM ApplicationForm
                WHERE Id = :applicationFormId
                WITH USER_MODE
                LIMIT 1
            ];
            
            dto.resumeAtStep = appForm.StepKey__c;
            dto.contextAccountId = appForm.AccountId;
            System.debug('📍 Resume at step: ' + dto.resumeAtStep);
            System.debug('📍 Context AccountId: ' + dto.contextAccountId);
            
            // Query all Applicants for this ApplicationForm
            // Query fields that WizardPersistenceService actually writes to
            List<Applicant> applicants = [
                SELECT Id, ApplicationFormId, Type, Role__c,
                       Salutation, FirstName, MiddleName, LastName, Suffix, Nickname__c,
                       BirthDate, Mothers_Maiden_Name__c,
                       Tax_ID__c, Tax_ID_Type__c,
                       Is_US_Citizen__c, Is_US_Resident__c, Country_Of_Residence__c,
                       Employer__c, Occupation__c,
                       Organization_Role__c, Is_Control_Person__c, Ownership_Percentage__c,
                       Email, Mobile_Phone__c, Home_Phone__c, Work_Phone__c,
                       Mailing_Street_Line_1__c, Mailing_Street_Line_2__c,
                       Mailing_City__c, Mailing_State__c, Mailing_Postal_Code__c, Mailing_Country__c,
                       Government_ID_Type__c, Government_ID_Number__c,
                       ID_Issuing_Country__c, ID_Issuing_State__c,
                       ID_Issue_Date__c, ID_Expiration_Date__c,
                       BusinessEntityName, BusinessEntityType, Doing_Business_As__c,
                       AccountId, Business_Tax_ID__c,
                       Date_Established__c, Business_Registration_State__c,
                       NAICS_Code__c, Industry_Type__c, Business_Description__c,
                       Business_Phone__c, Business_Email__c, Business_Home_Phone__c,
                       Business_Mobile_Phone__c, Business_Website__c,
                       Annual_Revenue__c, Number_of_Employees__c,
                       Business_Street_Line_1__c, Business_Street_Line_2__c,
                       Business_City__c, Business_State__c, Business_Postal_Code__c, Business_Country__c,
                       Primary_Contact_PersonAccount__c,
                       Primary_Contact_Name__c, Primary_Contact_Title__c
                FROM Applicant
                WHERE ApplicationFormId = :applicationFormId
                WITH USER_MODE
            ];
            
            System.debug('📊 Found ' + applicants.size() + ' Applicant(s)');
            
            // Separate applicants by type
            Applicant businessApplicant = null;
            Applicant primaryApplicant = null;
            List<Applicant> additionalApplicantsList = new List<Applicant>();
            
            for (Applicant app : applicants) {
                if (app.Type == 'Business') {
                    businessApplicant = app;
                    System.debug('✅ Found Business Applicant: ' + app.Id);
                } else if (app.Type == 'Individual' && app.Role__c == 'Primary Applicant') {
                    primaryApplicant = app;
                    System.debug('✅ Found Primary Applicant: ' + app.Id);
                } else {
                    additionalApplicantsList.add(app);
                    System.debug('✅ Found Additional Applicant: ' + app.Id);
                }
            }
            
            // Build Business Info from Business Applicant
            if (businessApplicant != null) {
                dto.businessInfo = buildBusinessInfoFromApplicant(businessApplicant);
                dto.hasBusinessInfo = true;
                dto.accountType = 'Business';
                System.debug('📋 Built BusinessInfoDTO from Business Applicant');
            }
            
            // Build Primary Applicant Info
            if (primaryApplicant != null) {
                dto.applicantInfo = buildApplicantInfoFromApplicant(primaryApplicant);
                dto.hasApplicantInfo = true;
                dto.hasPrimaryContact = true;
                System.debug('📋 Built ApplicantInfoDTO from Primary Applicant');
            }
            
            // Build Additional Applicants list
            if (!additionalApplicantsList.isEmpty()) {
                dto.additionalApplicants = new List<ApplicantInfoDTO>();
                for (Applicant addApp : additionalApplicantsList) {
                    dto.additionalApplicants.add(buildApplicantInfoFromApplicant(addApp));
                }
                System.debug('📋 Built ' + dto.additionalApplicants.size() + ' Additional Applicant DTOs');
            }
            
            // Query Product Selection data
            List<ApplicationFormProduct> products = [
                SELECT Id, ProductId, FundingAmount__c
                FROM ApplicationFormProduct
                WHERE ApplicationFormId = :applicationFormId
                WITH USER_MODE
            ];
            
            if (!products.isEmpty() && products[0].ProductId != null) {
                // Query Product2 separately to get ProductCode
                List<Product2> productDetails = [
                    SELECT Id, ProductCode
                    FROM Product2
                    WHERE Id = :products[0].ProductId
                    WITH USER_MODE
                    LIMIT 1
                ];
                
                if (!productDetails.isEmpty()) {
                    dto.productSelection = new ProductSelectionDTO();
                    dto.productSelection.productCode = productDetails[0].ProductCode;
                    System.debug('📋 Found Product: ' + dto.productSelection.productCode);
                }
            }
            
            // Query Documents (ContentDocumentLinks)
            List<ContentDocumentLink> docLinks = [
                SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType,
                       ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :applicationFormId
                WITH USER_MODE
            ];
            
            if (!docLinks.isEmpty()) {
                dto.documents = new DocumentsDTO();
                dto.documents.documents = new List<DocumentDTO>();
                for (ContentDocumentLink link : docLinks) {
                    DocumentDTO doc = new DocumentDTO();
                    doc.id = link.ContentDocumentId;
                    doc.name = link.ContentDocument.Title;
                    doc.fileName = link.ContentDocument.Title;
                    doc.contentVersionId = link.ContentDocument.LatestPublishedVersionId;
                    dto.documents.documents.add(doc);
                }
                System.debug('📋 Found ' + dto.documents.documents.size() + ' Document(s)');
            }
            
            // Query Services (stored in ApplicationForm custom fields or related objects)
            // For now, services are not persisted to Salesforce, so we skip this
            // TODO: Implement services persistence and retrieval if needed
            
            // Query Relationship data (ApplicationProductPartyRole)
            List<ApplicationProductPartyRole__c> roles = [
                SELECT Id, ApplicationFormProduct__c, Applicant__c, Role__c
                FROM ApplicationProductPartyRole__c
                WHERE ApplicationForm__c = :applicationFormId
                WITH USER_MODE
            ];
            
            if (!roles.isEmpty()) {
                dto.relationship = new RelationshipDTO();
                dto.relationship.assignments = new List<RoleAssignmentDTO>();
                
                // Group roles by product and applicant
                Map<String, RoleAssignmentDTO> assignmentMap = new Map<String, RoleAssignmentDTO>();
                for (ApplicationProductPartyRole__c role : roles) {
                    String key = String.valueOf(role.ApplicationFormProduct__c) + '_' + String.valueOf(role.Applicant__c);
                    if (!assignmentMap.containsKey(key)) {
                        RoleAssignmentDTO assignment = new RoleAssignmentDTO();
                        assignment.productId = role.ApplicationFormProduct__c;
                        assignment.applicantId = role.Applicant__c;
                        assignment.roles = new List<String>();
                        assignmentMap.put(key, assignment);
                    }
                    // Parse semicolon-separated roles
                    if (String.isNotBlank(role.Role__c)) {
                        assignmentMap.get(key).roles.addAll(role.Role__c.split(';'));
                    }
                }
                dto.relationship.assignments.addAll(assignmentMap.values());
                System.debug('📋 Found ' + dto.relationship.assignments.size() + ' Role Assignment(s)');
            }
            
            dto.message = 'Resuming application from step: ' + (dto.resumeAtStep != null ? dto.resumeAtStep : 'Start');
            System.debug('✅ handleApplicationForm END - Successfully loaded all data');
            
        } catch (Exception e) {
            System.debug('❌ ERROR in handleApplicationForm: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            dto.message = 'Failed to load application data: ' + e.getMessage();
            dto.accountType = 'Unknown';
        }
    }

    /**
     * Build BusinessInfoDTO from Business Applicant record
     * Maps from the SAME fields that WizardPersistenceService writes to
     * This ensures resume functionality works correctly
     */
    private static BusinessInfoDTO buildBusinessInfoFromApplicant(Applicant businessApplicant) {
        BusinessInfoDTO info = new BusinessInfoDTO();
        
        // Account selection
        info.businessAccountType = businessApplicant.AccountId != null ? 'existing' : 'new';
        info.selectedAccountId = businessApplicant.AccountId;
        
        // Business details - Read from FSC standard fields that persistence writes to
        info.businessName = businessApplicant.BusinessEntityName;  // FSC standard field
        info.dbaName = businessApplicant.Doing_Business_As__c;     // FSC standard field
        info.businessType = businessApplicant.BusinessEntityType;  // FSC standard field (picklist)
        info.taxId = businessApplicant.Business_Tax_ID__c;
        info.dateEstablished = formatDate(businessApplicant.Date_Established__c);
        info.stateOfIncorporation = businessApplicant.Business_Registration_State__c;  // Matches persistence
        
        // NAICS - Read from the field that persistence actually writes to
        // Note: Persistence writes naicsCodeId to NAICS_Code__c (lookup field)
        info.naicsCodeId = businessApplicant.NAICS_Code__c;  // This is the lookup ID field
        info.naicsCode = null;  // Not persisted separately
        info.naicsDescription = null;  // Not persisted separately
        info.industryType = businessApplicant.Industry_Type__c;
        info.businessDescription = businessApplicant.Business_Description__c;
        
        // Contact info
        info.businessPhone = businessApplicant.Business_Phone__c;
        info.businessEmail = businessApplicant.Business_Email__c;
        info.businessHomePhone = businessApplicant.Business_Home_Phone__c;
        info.businessMobilePhone = businessApplicant.Business_Mobile_Phone__c;
        info.businessWebsite = businessApplicant.Business_Website__c;
        
        // Financial info
        info.annualRevenue = businessApplicant.Annual_Revenue__c;
        info.numberOfEmployees = businessApplicant.Number_of_Employees__c;  // Match persistence case
        
        // Address
        info.businessStreetLine1 = businessApplicant.Business_Street_Line_1__c;
        info.businessStreetLine2 = businessApplicant.Business_Street_Line_2__c;
        info.businessCity = businessApplicant.Business_City__c;
        info.businessState = businessApplicant.Business_State__c;
        info.businessPostalCode = businessApplicant.Business_Postal_Code__c;
        info.businessCountry = businessApplicant.Business_Country__c;
        
        // Primary Contact - either lookup to PersonAccount OR text fields, never both
        if (businessApplicant.Primary_Contact_PersonAccount__c != null) {
            // Existing PersonAccount selected
            info.primaryContactType = 'existing';
            info.selectedContactId = businessApplicant.Primary_Contact_PersonAccount__c;
            info.primaryContactName = null;  // Not used when existing contact selected
            info.primaryContactTitle = null; // Not used when existing contact selected
        } else if (String.isNotBlank(businessApplicant.Primary_Contact_Name__c)) {
            // New contact with name/title stored as text
            info.primaryContactType = 'new';
            info.selectedContactId = null;
            info.primaryContactName = businessApplicant.Primary_Contact_Name__c;
            info.primaryContactTitle = businessApplicant.Primary_Contact_Title__c;
        } else {
            // No primary contact
            info.primaryContactType = 'new';
            info.selectedContactId = null;
            info.primaryContactName = null;
            info.primaryContactTitle = null;
        }
        
        return info;
    }

    /**
     * Build ApplicantInfoDTO from Individual Applicant record
     */
    private static ApplicantInfoDTO buildApplicantInfoFromApplicant(Applicant applicant) {
        ApplicantInfoDTO info = new ApplicantInfoDTO();
        
        // Personal Identity
        info.salutation = applicant.Salutation;
        info.firstName = applicant.FirstName;
        info.lastName = applicant.LastName;
        info.birthDate = formatDate(applicant.BirthDate);
        
        // Tax ID
        info.taxIdType = applicant.Tax_ID_Type__c;
        info.taxId = applicant.Tax_ID__c;
        
        // Contact info
        info.email = applicant.Email;
        info.mobilePhone = applicant.Mobile_Phone__c;
        info.homePhone = applicant.Home_Phone__c;
        info.workPhone = applicant.Work_Phone__c;
        
        // Address
        info.mailingStreetLine1 = applicant.Mailing_Street_Line_1__c;
        info.mailingStreetLine2 = applicant.Mailing_Street_Line_2__c;
        info.mailingCity = applicant.Mailing_City__c;
        info.mailingState = applicant.Mailing_State__c;
        info.mailingPostalCode = applicant.Mailing_Postal_Code__c;
        info.mailingCountry = applicant.Mailing_Country__c;
        
        // Government ID
        info.governmentIdType = applicant.Government_ID_Type__c;
        info.governmentIdNumber = applicant.Government_ID_Number__c;
        info.idIssuingCountry = applicant.ID_Issuing_Country__c;
        info.idIssuingState = applicant.ID_Issuing_State__c;
        info.idIssueDate = formatDate(applicant.ID_Issue_Date__c);
        info.idExpirationDate = formatDate(applicant.ID_Expiration_Date__c);
        
        return info;
    }
}

