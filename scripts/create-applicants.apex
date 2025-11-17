// Script: create-applicants.apex
// Purpose: Seed primary and secondary Applicant records for a specific ApplicationForm.
// Usage:   sf apex run --file scripts/create-applicants.apex --target-org <alias>

class ApplicantSeed {
    public String daoApplicantId;
    public String salutation;
    public String firstName;
    public String middleName;
    public String lastName;
    public String suffix;
    public Date birthDate;
    public String email;
    public String mobilePhone;
    public String homePhone;
    public String workPhone;
    public String mailingStreetLine1;
    public String mailingStreetLine2;
    public String mailingCity;
    public String mailingState;
    public String mailingPostalCode;
    public String mailingCountry;
    public String taxId;
    public String taxIdType;
    public String governmentIdType;
    public String governmentIdNumber;
    public String idIssuingCountry;
    public String idIssuingState;
    public Date idIssueDate;
    public Date idExpirationDate;
    public Account personAccount;

    public ApplicantSeed(String daoApplicantId) {
        this.daoApplicantId = daoApplicantId;
        this.mailingCountry = 'USA';
        this.idIssuingCountry = 'USA';
    }
}

class ApplicantSeedRunner {

    public static void run() {
        final Id applicationFormId = '13XWE000000ZrXh2AK';

        ApplicationForm applicationForm;
        try {
            applicationForm = [
                SELECT Id, Name
                FROM ApplicationForm
                WHERE Id = :applicationFormId
                LIMIT 1
            ];
        } catch (QueryException qe) {
            System.debug(String.format('✗ ApplicationForm {0} not found. Aborting.', new List<Object>{applicationFormId}));
            return;
        }

        List<ApplicantSeed> seeds = new List<ApplicantSeed>();

        ApplicantSeed primary = new ApplicantSeed('MSB-APP-PRIMARY');
        primary.salutation = 'Mr.';
        primary.firstName = 'Alex';
        primary.middleName = 'J';
        primary.lastName = 'Rivera';
        primary.birthDate = Date.newInstance(1988, 5, 12);
        primary.email = 'alex.rivera@example.com';
        primary.mobilePhone = '4155550101';
        primary.homePhone = '4155550102';
        primary.workPhone = '4155550103';
        primary.mailingStreetLine1 = '123 Market St';
        primary.mailingStreetLine2 = 'Suite 500';
        primary.mailingCity = 'San Francisco';
        primary.mailingState = 'CA';
        primary.mailingPostalCode = '94105';
        primary.taxId = '222334444';
        primary.taxIdType = 'SSN';
        primary.governmentIdType = 'Driver\'s License';
        primary.governmentIdNumber = 'D1234567';
        primary.idIssuingState = 'CA';
        primary.idIssueDate = Date.newInstance(2018, 2, 15);
        primary.idExpirationDate = Date.newInstance(2028, 2, 15);
        seeds.add(primary);

        ApplicantSeed coApplicant = new ApplicantSeed('MSB-APP-COAPP');
        coApplicant.salutation = 'Ms.';
        coApplicant.firstName = 'Jordan';
        coApplicant.middleName = 'A';
        coApplicant.lastName = 'Blake';
        coApplicant.birthDate = Date.newInstance(1990, 11, 3);
        coApplicant.email = 'jordan.blake@example.com';
        coApplicant.mobilePhone = '2065550201';
        coApplicant.homePhone = '2065550202';
        coApplicant.workPhone = '2065550203';
        coApplicant.mailingStreetLine1 = '456 Pine Ave';
        coApplicant.mailingCity = 'Seattle';
        coApplicant.mailingState = 'WA';
        coApplicant.mailingPostalCode = '98101';
        coApplicant.taxId = '333445555';
        coApplicant.taxIdType = 'SSN';
        coApplicant.governmentIdType = 'Passport';
        coApplicant.governmentIdNumber = 'XP123456';
        coApplicant.idIssuingState = 'WA';
        coApplicant.idIssueDate = Date.newInstance(2019, 6, 1);
        coApplicant.idExpirationDate = Date.newInstance(2029, 6, 1);
        seeds.add(coApplicant);

        // PersonAccount creation intentionally disabled per request. If you need to seed PersonAccounts
        // alongside Applicants, uncomment the block below.
        /*
        Schema.RecordTypeInfo personAccountInfo = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount');
        if (personAccountInfo == null) {
            System.debug('✗ PersonAccount record type not available. Enable Person Accounts or update the script before retrying.');
            return;
        }
        Id personAccountRecordTypeId = personAccountInfo.getRecordTypeId();

        Set<String> emailKeys = new Set<String>();
        for (ApplicantSeed spec : seeds) {
            if (String.isNotBlank(spec.email)) {
                emailKeys.add(spec.email.toLowerCase());
            }
        }

        Map<String, Account> existingByEmail = new Map<String, Account>();
        if (!emailKeys.isEmpty()) {
            for (Account existing : [
                SELECT Id, PersonEmail
                FROM Account
                WHERE IsPersonAccount = true
                AND PersonEmail IN :emailKeys
            ]) {
                if (String.isNotBlank(existing.PersonEmail)) {
                    existingByEmail.put(existing.PersonEmail.toLowerCase(), existing);
                }
            }
        }

        List<Account> accountsToInsert = new List<Account>();
        List<Account> accountsToUpdate = new List<Account>();

        for (ApplicantSeed spec : seeds) {
            Account personAccount = null;
            if (String.isNotBlank(spec.email)) {
                personAccount = existingByEmail.get(spec.email.toLowerCase());
            }

            if (personAccount == null) {
                personAccount = new Account();
                personAccount.RecordTypeId = personAccountRecordTypeId;
                accountsToInsert.add(personAccount);
            } else if (!accountsToUpdate.contains(personAccount)) {
                accountsToUpdate.add(personAccount);
            }

            personAccount.FirstName = spec.firstName;
            personAccount.LastName = String.isNotBlank(spec.lastName) ? spec.lastName : 'Applicant';
            personAccount.PersonEmail = spec.email;
            personAccount.PersonBirthdate = spec.birthDate;
            personAccount.Phone = spec.workPhone;
            personAccount.PersonMobilePhone = spec.mobilePhone;
            personAccount.PersonHomePhone = spec.homePhone;
            personAccount.PersonMailingStreet = combineStreet(spec.mailingStreetLine1, spec.mailingStreetLine2);
            personAccount.PersonMailingCity = spec.mailingCity;
            personAccount.PersonMailingState = spec.mailingState;
            personAccount.PersonMailingPostalCode = spec.mailingPostalCode;
            personAccount.PersonMailingCountry = spec.mailingCountry;

            spec.personAccount = personAccount;
        }

        if (!accountsToInsert.isEmpty()) {
            insert accountsToInsert;
            for (Account insertedAcc : accountsToInsert) {
                System.debug(String.format('✓ Created PersonAccount {0}', new List<Object>{insertedAcc.Id}));
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
            for (Account updatedAcc : accountsToUpdate) {
                System.debug(String.format('✓ Updated PersonAccount {0}', new List<Object>{updatedAcc.Id}));
            }
        }
        */

        List<Applicant> applicantsToUpsert = new List<Applicant>();
        for (ApplicantSeed spec : seeds) {
            Applicant applicant = new Applicant();
            applicant.DAOApplicantId__c = spec.daoApplicantId;
            applicant.ApplicationFormId = applicationForm.Id;
            // applicant.AccountId = spec.personAccount != null ? spec.personAccount.Id : null; // PersonAccount linkage disabled
            applicant.Type = 'Individual'; // Valid values: 'Individual' (PersonAccount) or 'Business' (Business Account)
            applicant.Salutation = spec.salutation;
            applicant.FirstName = spec.firstName;
            applicant.MiddleName = spec.middleName;
            applicant.LastName = spec.lastName;
            applicant.Suffix = spec.suffix;
            applicant.BirthDate = spec.birthDate;
            applicant.Email = spec.email;
            applicant.Mobile_Phone__c = spec.mobilePhone;
            applicant.Home_Phone__c = spec.homePhone;
            applicant.Work_Phone__c = spec.workPhone;
            applicant.Mailing_Street_Line_1__c = spec.mailingStreetLine1;
            applicant.Mailing_Street_Line_2__c = spec.mailingStreetLine2;
            applicant.Mailing_City__c = spec.mailingCity;
            applicant.Mailing_State__c = spec.mailingState;
            applicant.Mailing_Postal_Code__c = spec.mailingPostalCode;
            applicant.Mailing_Country__c = spec.mailingCountry;
            applicant.Tax_ID__c = spec.taxId;
            applicant.Tax_ID_Type__c = spec.taxIdType;
            applicant.Government_ID_Type__c = spec.governmentIdType;
            applicant.Government_ID_Number__c = spec.governmentIdNumber;
            applicant.ID_Issuing_Country__c = spec.idIssuingCountry;
            applicant.ID_Issuing_State__c = spec.idIssuingState;
            applicant.ID_Issue_Date__c = spec.idIssueDate;
            applicant.ID_Expiration_Date__c = spec.idExpirationDate;
            applicantsToUpsert.add(applicant);
        }

        Database.UpsertResult[] upsertResults = Database.upsert(applicantsToUpsert, Applicant.DAOApplicantId__c, false);
        Integer successCount = 0;
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            ApplicantSeed spec = seeds[i];
            if (result.isSuccess()) {
                successCount++;
                System.debug(String.format('✓ Applicant {0} ({1} {2}) upserted. Id: {3}', new List<Object>{
                    spec.daoApplicantId, spec.firstName, spec.lastName, result.getId()
                }));
            } else {
                for (Database.Error err : result.getErrors()) {
                    System.debug(String.format('✗ Applicant {0} failed: {1} (Status Code: {2})', new List<Object>{
                        spec.daoApplicantId, err.getMessage(), err.getStatusCode()
                    }));
                }
            }
        }

        System.debug(String.format(
            'Completed applicant seeding for ApplicationForm {0}. Successful upserts: {1}/{2}.',
            new List<Object>{applicationForm.Id, successCount, upsertResults.size()}
        ));
    }

    private static String combineStreet(String line1, String line2) {
        if (String.isBlank(line1)) {
            return line2;
        }
        if (String.isBlank(line2)) {
            return line1;
        }
        return line1 + '\n' + line2;
    }
}

ApplicantSeedRunner.run();

