@isTest
private class WizardDataServiceTest {

    private static Id getRecordTypeIdByDeveloperName(SObjectType sobjectType, String developerName) {
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = sobjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        if (recordTypeInfos.containsKey(developerName)) {
            return recordTypeInfos.get(developerName).getRecordTypeId();
        }
        return null;
    }

    @isTest
    private static void testOpportunityWithBusinessAccount() {
        Id businessRtId = getRecordTypeIdByDeveloperName(Account.SObjectType, 'IndustriesBusiness');
        Account businessAccount = new Account(
            Name = 'Acme Incorporated',
            RecordTypeId = businessRtId,
            Phone = '555-555-0000',
            Business_Email__c = 'info@acme.com',
            Business_Home_Phone__c = '555-555-0001',
            Business_Mobile_Phone__c = '555-555-0002',
            Website = 'https://www.acme.com',
            BillingStreet = '123 Market St\nSuite 100',
            BillingCity = 'Sacramento',
            BillingState = 'CA',
            BillingPostalCode = '95814',
            BillingCountry = 'United States',
            AnnualRevenue = 1000000,
            NumberOfEmployees = 75,
            Industry = 'Finance',
            Description = 'Financial Services',
            Business_Tax_ID__c = '98-7654321',
            SW_Doing_Business_As__c = 'Acme DBA',
            SW_Date_Business_Established__c = Date.newInstance(2010, 1, 15),
            SW_Business_Registration_State__c = 'CA',
            FinServ__TaxID__c = '12-3456789'
        );
        insert businessAccount;

        Id personRtId = getRecordTypeIdByDeveloperName(Account.SObjectType, 'PersonAccount');
        Account personAccount = new Account(
            RecordTypeId = personRtId,
            FirstName = 'Emma',
            LastName = 'Taylor',
            Salutation = 'Ms.',
            PersonBirthdate = Date.today().addYears(-32),
            PersonEmail = 'emma.taylor@example.com',
            PersonMobilePhone = '555-555-1234',
            PersonHomePhone = '555-555-5678',
            PersonMailingStreet = '456 Elm St\nApt 2',
            PersonMailingCity = 'Sacramento',
            PersonMailingState = 'CA',
            PersonMailingPostalCode = '95816',
            PersonMailingCountry = 'USA',
            SSN_Tax_Id__c = '123-45-6789',
            Tax_ID_Type__c = 'SSN'
        );
        insert personAccount;

        Contact primaryContact = [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId = :personAccount.Id
            LIMIT 1
        ];

        primaryContact.Title = 'Chief Financial Officer';
        update primaryContact;

        businessAccount.FinServ__PrimaryContact__c = primaryContact.Id;
        update businessAccount;

        Opportunity opp = new Opportunity(
            Name = 'Acme Onboarding',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            AccountId = businessAccount.Id
        );
        insert opp;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(opp.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        System.assertEquals('Opportunity', result.entryPointType, 'Entry point should be Opportunity');
        System.assertEquals('Business', result.accountType, 'Account type should be Business');
        System.assertFalse(result.hideBusinessStep, 'Business step should remain visible');

        System.assertNotEquals(null, result.businessInfo, 'Business information should be populated');
        System.assertEquals('existing', result.businessInfo.businessAccountType, 'Business account type should be existing');
        System.assertEquals(businessAccount.Id, result.businessInfo.selectedAccountId, 'Existing account should be pre-selected');
        System.assertEquals(businessAccount.Name, result.businessInfo.businessName, 'Business name should be populated');
        System.assertEquals('Acme DBA', result.businessInfo.dbaName, 'DBA should come from SW_Doing_Business_As__c');
        System.assertEquals('98-7654321', result.businessInfo.taxId, 'Tax ID should come from Business_Tax_ID__c');
        System.assertEquals('2010-01-15', result.businessInfo.dateEstablished, 'Date Established should reflect SW field');
        System.assertEquals('California', result.businessInfo.stateOfIncorporation, 'State of Incorporation should be normalized');
        System.assertEquals('California', result.businessInfo.businessState, 'Business state should be normalized');
        System.assertEquals('USA', result.businessInfo.businessCountry, 'Business country should be normalized');
        System.assertEquals('Financial Services', result.businessInfo.businessDescription, 'Business description should come from Account');
        System.assertEquals('Finance', result.businessInfo.industryType, 'Industry should map directly from Account');
        System.assertEquals('101-500', result.businessInfo.numberOfEmployees, 'Employee range should translate to 101-500');

        System.assertNotEquals(null, result.applicantInfo, 'Primary applicant info should be populated from primary contact');
        System.assertEquals('Emma', result.applicantInfo.firstName, 'Applicant first name should match primary contact');
        System.assertEquals('Taylor', result.applicantInfo.lastName, 'Applicant last name should match primary contact');
        System.assertEquals('123-45-6789', result.applicantInfo.taxId, 'Tax ID should come from Person Account');
        System.assertEquals('Ms. Emma Taylor', result.businessInfo.primaryContactName, 'Primary contact name should be derived from contact');
        System.assertEquals('Chief Financial Officer', result.businessInfo.primaryContactTitle, 'Primary contact title should map from contact');
    }

    @isTest
    private static void testOpportunityWithPersonAccount() {
        Id personRtId = getRecordTypeIdByDeveloperName(Account.SObjectType, 'PersonAccount');
        Account personAccount = new Account(
            RecordTypeId = personRtId,
            FirstName = 'Olivia',
            LastName = 'Chen',
            Salutation = 'Ms.',
            PersonBirthdate = Date.today().addYears(-28),
            PersonEmail = 'olivia.chen@example.com',
            PersonMobilePhone = '555-000-1111',
            PersonHomePhone = '555-000-2222',
            PersonMailingStreet = '789 Pine St',
            PersonMailingCity = 'San Francisco',
            PersonMailingState = 'CA',
            PersonMailingPostalCode = '94105',
            PersonMailingCountry = 'USA',
            SSN_Tax_Id__c = '234-56-7890',
            Tax_ID_Type__c = 'SSN'
        );
        insert personAccount;

        Opportunity opp = new Opportunity(
            Name = 'Olivia Chen DAO',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            AccountId = personAccount.Id
        );
        insert opp;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(opp.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        System.assertEquals('Opportunity', result.entryPointType);
        System.assertEquals('Person', result.accountType);
        System.assertFalse(result.hideBusinessStep, 'Business step should remain visible for Person Account entry');
        System.assertNotEquals(null, result.businessInfo, 'Business info DTO should be initialized');
        System.assertEquals('new', result.businessInfo.businessAccountType, 'Business account type should default to new');
        System.assertEquals('new', result.businessInfo.primaryContactType, 'Primary contact type should default to new');

        System.assertNotEquals(null, result.applicantInfo);
        System.assertEquals('Olivia', result.applicantInfo.firstName);
        System.assertEquals('Chen', result.applicantInfo.lastName);
        System.assertEquals('234-56-7890', result.applicantInfo.taxId);
    }

    @isTest
    private static void testOpportunityBusinessWithoutPrimaryContact() {
        Id businessRtId = getRecordTypeIdByDeveloperName(Account.SObjectType, 'IndustriesBusiness');
        Account businessAccount = new Account(
            Name = 'Summit Logistics',
            RecordTypeId = businessRtId,
            Phone = '555-888-9999',
            BillingStreet = '15 Depot Rd',
            BillingCity = 'Roseville',
            BillingState = 'CA',
            BillingPostalCode = '95661',
            BillingCountry = 'USA',
            NumberOfEmployees = 15,
            Industry = 'Transportation'
        );
        insert businessAccount;

        Opportunity opp = new Opportunity(
            Name = 'Summit Logistics DAO',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            AccountId = businessAccount.Id
        );
        insert opp;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(opp.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        System.assertEquals('Opportunity', result.entryPointType);
        System.assertEquals('Business', result.accountType);
        System.assertNotEquals(null, result.businessInfo, 'Business info should be present');
        System.assertEquals('new', result.businessInfo.primaryContactType, 'Primary contact should default to new when none exists');
        System.assertEquals(null, result.applicantInfo, 'Applicant info should not be populated without a primary contact');
    }

    @isTest
    private static void testDirectBusinessAccount() {
        Id businessRtId = getRecordTypeIdByDeveloperName(Account.SObjectType, 'IndustriesBusiness');
        Account businessAccount = new Account(
            Name = 'River City Builders',
            RecordTypeId = businessRtId,
            Phone = '555-777-1212',
            Business_Email__c = 'contact@rivercity.com',
            BillingStreet = '100 Builder Way',
            BillingCity = 'Folsom',
            BillingState = 'CA',
            BillingPostalCode = '95630',
            BillingCountry = 'United States',
            NumberOfEmployees = 8,
            Industry = 'Construction',
            Business_Tax_ID__c = '11-2223333',
            SW_Doing_Business_As__c = 'River City Builders LLC',
            SW_Date_Business_Established__c = Date.newInstance(2001, 4, 2),
            SW_Business_Registration_State__c = 'CA'
        );
        insert businessAccount;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(businessAccount.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        System.assertEquals('Account', result.entryPointType);
        System.assertEquals('Business', result.accountType);
        System.assertFalse(result.hideBusinessStep);
        System.assertNotEquals(null, result.businessInfo);
        System.assertEquals('River City Builders', result.businessInfo.businessName);
        System.assertEquals('River City Builders LLC', result.businessInfo.dbaName);
        System.assertEquals('11-2223333', result.businessInfo.taxId);
        System.assertEquals('2001-04-02', result.businessInfo.dateEstablished);
        System.assertEquals('California', result.businessInfo.stateOfIncorporation);
        System.assertEquals('California', result.businessInfo.businessState);
        System.assertEquals('USA', result.businessInfo.businessCountry);
        System.assertEquals('1-10', result.businessInfo.numberOfEmployees);
    }

    @isTest
    private static void testDirectPersonAccount() {
        Id personRtId = getRecordTypeIdByDeveloperName(Account.SObjectType, 'PersonAccount');
        Account personAccount = new Account(
            RecordTypeId = personRtId,
            FirstName = 'Liam',
            LastName = 'Reed',
            Salutation = 'Mr.',
            PersonBirthdate = Date.today().addYears(-40),
            PersonEmail = 'liam.reed@example.com',
            PersonMobilePhone = '555-111-3333',
            PersonMailingStreet = '321 Oak Ave',
            PersonMailingCity = 'Elk Grove',
            PersonMailingState = 'CA',
            PersonMailingPostalCode = '95758',
            PersonMailingCountry = 'USA'
        );
        insert personAccount;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(personAccount.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        System.assertEquals('Account', result.entryPointType);
        System.assertEquals('Person', result.accountType);
        System.assertFalse(result.hideBusinessStep);
        System.assertNotEquals(null, result.businessInfo);
        System.assertEquals('new', result.businessInfo.businessAccountType);
        System.assertEquals('new', result.businessInfo.primaryContactType);
        System.assertNotEquals(null, result.applicantInfo);
    }

    @isTest
    private static void testUnsupportedRecord() {
        // Create a dummy ApplicationForm record ID using Opportunity (no actual ApplicationForm object defined here)
        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(null, 'DAO_Business_InBranch');
        Test.stopTest();

        System.assertEquals('No context record provided.', result.message);
    }
}

