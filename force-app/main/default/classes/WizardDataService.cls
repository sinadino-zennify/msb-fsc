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
                   FinServ__TaxID__c,
                   Business_Tax_ID__c,
                   Business_Tax_ID_Type__c,
                   Phone,
                   Business_Phone__c,
                   Business_Email__c,
                   Business_Home_Phone__c,
                   Business_Mobile_Phone__c,
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
                   YearStarted,
                   NAICS_Lookup__c,
                   NAICS_Code__c,
                   NAICS_Description__c,
                   FinServ__PrimaryContact__c,
                   PersonBirthdate,
                   PersonEmail,
                   PersonMobilePhone,
                   PersonHomePhone,
                   PersonMailingStreet,
                   PersonMailingCity,
                   PersonMailingState,
                   PersonMailingPostalCode,
                   PersonMailingCountry,
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
            dto.hideBusinessStep = true;
            dto.applicantInfo = buildApplicantFromPersonAccount(acc);
            dto.hasApplicantInfo = dto.applicantInfo != null;
        dto.hasPrimaryContact = dto.hasApplicantInfo;
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
                           Account.ID_Expiration_Date__c
                    FROM Contact
                    WHERE Id = :acc.FinServ__PrimaryContact__c
                    WITH USER_MODE
                    LIMIT 1
                ];

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
                    dto.businessInfo.primaryContactName = buildFullName(primaryContact.Salutation, primaryContact.FirstName, primaryContact.LastName);
                    dto.businessInfo.primaryContactTitle = primaryContact.Title;
                }
            } else {
                dto.businessInfo.primaryContactType = 'new';
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
        info.dbaName = null; // No non-SW DBA field on Account
        info.businessType = String.isNotBlank(acc.Business_Type__c) ? acc.Business_Type__c : acc.Type;
        info.taxId = String.isNotBlank(acc.Business_Tax_ID__c) ? acc.Business_Tax_ID__c : acc.FinServ__TaxID__c;
        info.dateEstablished = null; // No standard date field available on Account
        info.stateOfIncorporation = null; // No non-SW field available on Account

        info.naicsCodeId = acc.NAICS_Lookup__c;
        info.naicsCode = acc.NAICS_Code__c;
        info.naicsDescription = acc.NAICS_Description__c;
        info.industryType = acc.Industry;
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
        info.businessState = acc.BillingState;
        info.businessPostalCode = acc.BillingPostalCode;
        info.businessCountry = acc.BillingCountry;

        info.primaryContactType = 'new';
        info.selectedContactId = null;

        return info;
    }

    private static ApplicantInfoDTO buildApplicantFromPersonAccount(Account personAccount) {
        ApplicantInfoDTO applicant = new ApplicantInfoDTO();
        applicant.salutation = personAccount.Salutation;
        applicant.firstName = personAccount.FirstName;
        applicant.lastName = personAccount.LastName;
        applicant.birthDate = formatDate(personAccount.PersonBirthdate);
        applicant.taxId = personAccount.SSN_Tax_Id__c;
        applicant.taxIdType = personAccount.Tax_ID_Type__c;
        applicant.email = personAccount.PersonEmail;
        applicant.mobilePhone = personAccount.PersonMobilePhone;
        applicant.homePhone = personAccount.PersonHomePhone;
        applicant.workPhone = personAccount.Phone;

        String[] streetLines = splitStreet(personAccount.PersonMailingStreet);
        applicant.mailingStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
        applicant.mailingStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
        applicant.mailingCity = personAccount.PersonMailingCity;
        applicant.mailingState = personAccount.PersonMailingState;
        applicant.mailingPostalCode = personAccount.PersonMailingPostalCode;
        applicant.mailingCountry = personAccount.PersonMailingCountry;

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

        ApplicantInfoDTO applicant = new ApplicantInfoDTO();
        applicant.salutation = contact.Salutation;
        applicant.firstName = contact.FirstName;
        applicant.lastName = contact.LastName;
        applicant.birthDate = formatDate(contact.Birthdate);
        applicant.email = contact.Email;
        applicant.mobilePhone = contact.MobilePhone;
        applicant.homePhone = contact.HomePhone;
        applicant.workPhone = contact.Phone;

        String[] streetLines = splitStreet(contact.MailingStreet);
        applicant.mailingStreetLine1 = streetLines != null && streetLines.size() > 0 ? streetLines[0] : null;
        applicant.mailingStreetLine2 = streetLines != null && streetLines.size() > 1 ? streetLines[1] : null;
        applicant.mailingCity = contact.MailingCity;
        applicant.mailingState = contact.MailingState;
        applicant.mailingPostalCode = contact.MailingPostalCode;
        applicant.mailingCountry = contact.MailingCountry;

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
}

