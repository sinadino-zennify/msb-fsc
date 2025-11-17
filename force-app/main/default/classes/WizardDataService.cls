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
                dto.message = 'ApplicationForm entry point detected. Data preload is not implemented for this context.';
                dto.accountType = 'Unknown';
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
        info.businessType = String.isNotBlank(acc.Business_Type__c) ? acc.Business_Type__c : acc.Type;
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
}

