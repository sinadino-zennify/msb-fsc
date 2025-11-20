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

    /**
     * Test ApplicationForm resume functionality with Business Applicant
     */
    @isTest
    private static void testApplicationFormResumeWithBusinessApplicant() {
        // Create ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding',
            Stage = 'Initiated',
            SubmissionDate = System.today(),
            StepKey__c = 'DAO_Business_InBranch_Business'
        );
        insert appForm;

        // Create Business Applicant using FSC standard fields that persistence writes to
        Applicant businessApplicant = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Business',
            BusinessEntityName = 'Tech Innovations LLC',  // FSC standard field
            Doing_Business_As__c = 'Tech Innovations',    // FSC standard field
            BusinessEntityType = 'LLC',                   // FSC standard field
            Business_Tax_ID__c = '12-3456789',
            Date_Established__c = Date.newInstance(2015, 6, 15),
            Business_Registration_State__c = 'California',
            Industry_Type__c = 'Technology',
            Business_Description__c = 'Software development and consulting',
            Business_Phone__c = '555-123-4567',
            Business_Email__c = 'info@techinnovations.com',
            Business_Mobile_Phone__c = '555-987-6543',
            Business_Website__c = 'https://www.techinnovations.com',
            Annual_Revenue__c = 2500000,
            Number_of_Employees__c = '51-100',
            Business_Street_Line_1__c = '100 Innovation Drive',
            Business_Street_Line_2__c = 'Suite 200',
            Business_City__c = 'San Francisco',
            Business_State__c = 'California',
            Business_Postal_Code__c = '94105',
            Business_Country__c = 'USA',
            Primary_Contact_Type__c = 'new'
        );
        insert businessApplicant;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(appForm.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        // Verify entry point and resume step
        System.assertEquals('ApplicationForm', result.entryPointType, 'Entry point should be ApplicationForm');
        System.assertEquals('DAO_Business_InBranch_Business', result.resumeAtStep, 'Should resume at Business step');

        // Verify Business Info populated from FSC standard fields
        System.assertNotEquals(null, result.businessInfo, 'Business info should be populated');
        System.assertEquals('Tech Innovations LLC', result.businessInfo.businessName);
        System.assertEquals('Tech Innovations', result.businessInfo.dbaName);
        System.assertEquals('LLC', result.businessInfo.businessType);
        System.assertEquals('12-3456789', result.businessInfo.taxId);
        System.assertEquals('2015-06-15', result.businessInfo.dateEstablished);
        System.assertEquals('California', result.businessInfo.stateOfIncorporation);
        System.assertEquals('Technology', result.businessInfo.industryType);
        System.assertEquals('555-123-4567', result.businessInfo.businessPhone);
        System.assertEquals('info@techinnovations.com', result.businessInfo.businessEmail);
        System.assertEquals(2500000, result.businessInfo.annualRevenue);
        System.assertEquals('51-100', result.businessInfo.numberOfEmployees);
        System.assertEquals('100 Innovation Drive', result.businessInfo.businessStreetLine1);
        System.assertEquals('Suite 200', result.businessInfo.businessStreetLine2);
        System.assertEquals('San Francisco', result.businessInfo.businessCity);
        System.assertEquals('California', result.businessInfo.businessState);
        System.assertEquals('94105', result.businessInfo.businessPostalCode);
        System.assertEquals('USA', result.businessInfo.businessCountry);
    }

    /**
     * Test ApplicationForm resume functionality with Primary Applicant
     */
    @isTest
    private static void testApplicationFormResumeWithPrimaryApplicant() {
        // Create ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding',
            Stage = 'Initiated',
            SubmissionDate = System.today(),
            StepKey__c = 'DAO_Business_InBranch_Applicant'
        );
        insert appForm;

        // Create Primary Applicant
        Applicant primaryApplicant = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Individual',
            Role__c = 'Primary Applicant',
            Salutation = 'Mr.',
            FirstName = 'John',
            LastName = 'Smith',
            BirthDate = Date.newInstance(1985, 3, 15),
            Tax_ID__c = '123-45-6789',
            Tax_ID_Type__c = 'SSN',
            Is_US_Citizen__c = true,
            Is_US_Resident__c = true,
            Email = 'john.smith@example.com',
            Mobile_Phone__c = '555-111-2222',
            Home_Phone__c = '555-333-4444',
            Mailing_Street_Line_1__c = '456 Main Street',
            Mailing_Street_Line_2__c = 'Apt 5B',
            Mailing_City__c = 'Sacramento',
            Mailing_State__c = 'California',
            Mailing_Postal_Code__c = '95814',
            Mailing_Country__c = 'USA',
            Government_ID_Type__c = 'Driver License',
            Government_ID_Number__c = 'D1234567',
            ID_Issuing_State__c = 'California',
            ID_Issue_Date__c = Date.newInstance(2020, 1, 1),
            ID_Expiration_Date__c = Date.newInstance(2025, 1, 1)
        );
        insert primaryApplicant;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(appForm.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        // Verify entry point and resume step
        System.assertEquals('ApplicationForm', result.entryPointType);
        System.assertEquals('DAO_Business_InBranch_Applicant', result.resumeAtStep);

        // Verify Primary Applicant Info populated
        System.assertNotEquals(null, result.applicantInfo, 'Applicant info should be populated');
        System.assertEquals('Mr.', result.applicantInfo.salutation);
        System.assertEquals('John', result.applicantInfo.firstName);
        System.assertEquals('Smith', result.applicantInfo.lastName);
        System.assertEquals('1985-03-15', result.applicantInfo.birthDate);
        System.assertEquals('SSN', result.applicantInfo.taxIdType);
        System.assertEquals('123-45-6789', result.applicantInfo.taxId);
        System.assertEquals('john.smith@example.com', result.applicantInfo.email);
        System.assertEquals('555-111-2222', result.applicantInfo.mobilePhone);
        System.assertEquals('555-333-4444', result.applicantInfo.homePhone);
        System.assertEquals('456 Main Street', result.applicantInfo.mailingStreetLine1);
        System.assertEquals('Apt 5B', result.applicantInfo.mailingStreetLine2);
        System.assertEquals('Sacramento', result.applicantInfo.mailingCity);
        System.assertEquals('California', result.applicantInfo.mailingState);
        System.assertEquals('95814', result.applicantInfo.mailingPostalCode);
        System.assertEquals('USA', result.applicantInfo.mailingCountry);
        System.assertEquals('Driver License', result.applicantInfo.governmentIdType);
        System.assertEquals('D1234567', result.applicantInfo.governmentIdNumber);
    }

    /**
     * Test ApplicationForm resume with Additional Applicants
     */
    @isTest
    private static void testApplicationFormResumeWithAdditionalApplicants() {
        // Create ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding',
            Stage = 'Initiated',
            SubmissionDate = System.today(),
            StepKey__c = 'DAO_Business_InBranch_Additional'
        );
        insert appForm;

        // Create Primary Applicant
        Applicant primaryApplicant = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Individual',
            Role__c = 'Primary Applicant',
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com'
        );
        insert primaryApplicant;

        // Create Additional Applicants
        List<Applicant> additionalApplicants = new List<Applicant>{
            new Applicant(
                ApplicationFormId = appForm.Id,
                Type = 'Individual',
                Role__c = 'Co-Applicant',
                FirstName = 'Robert',
                LastName = 'Johnson',
                Email = 'robert.johnson@example.com',
                Mobile_Phone__c = '555-222-3333'
            ),
            new Applicant(
                ApplicationFormId = appForm.Id,
                Type = 'Individual',
                Role__c = 'Authorized Signer',
                FirstName = 'Sarah',
                LastName = 'Williams',
                Email = 'sarah.williams@example.com',
                Mobile_Phone__c = '555-444-5555'
            )
        };
        insert additionalApplicants;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(appForm.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        // Verify entry point and resume step
        System.assertEquals('ApplicationForm', result.entryPointType);
        System.assertEquals('DAO_Business_InBranch_Additional', result.resumeAtStep);

        // Verify Primary Applicant
        System.assertNotEquals(null, result.applicantInfo);
        System.assertEquals('Jane', result.applicantInfo.firstName);

        // Verify Additional Applicants
        System.assertNotEquals(null, result.additionalApplicants, 'Additional applicants should be populated');
        System.assertEquals(2, result.additionalApplicants.size(), 'Should have 2 additional applicants');
        System.assertEquals('Robert', result.additionalApplicants[0].firstName);
        System.assertEquals('Johnson', result.additionalApplicants[0].lastName);
        System.assertEquals('Sarah', result.additionalApplicants[1].firstName);
        System.assertEquals('Williams', result.additionalApplicants[1].lastName);
    }

    /**
     * Test ApplicationForm resume with full workflow data
     */
    @isTest
    private static void testApplicationFormResumeWithCompleteData() {
        // Create ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding',
            Stage = 'Initiated',
            SubmissionDate = System.today(),
            StepKey__c = 'DAO_Business_InBranch_Review'
        );
        insert appForm;

        // Create Business Applicant using FSC standard fields
        Applicant businessApplicant = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Business',
            BusinessEntityName = 'Complete Solutions Inc'
        );
        insert businessApplicant;

        // Create Primary Applicant
        Applicant primaryApplicant = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Individual',
            Role__c = 'Primary Applicant',
            FirstName = 'Michael',
            LastName = 'Brown',
            Email = 'michael.brown@example.com'
        );
        insert primaryApplicant;

        // Create Product
        Product2 product = new Product2(
            Name = 'Business Checking',
            ProductCode = 'BIZ_CHECKING',
            IsActive = true
        );
        insert product;

        ApplicationFormProduct afp = new ApplicationFormProduct(
            ApplicationFormId = appForm.Id,
            ProductId = product.Id,
            FundingAmount__c = 50000
        );
        insert afp;

        Test.startTest();
        WizardDataService.WizardDataDTO result = WizardDataService.getWizardData(appForm.Id, 'DAO_Business_InBranch');
        Test.stopTest();

        // Verify all data loaded
        System.assertEquals('ApplicationForm', result.entryPointType);
        System.assertEquals('DAO_Business_InBranch_Review', result.resumeAtStep);
        System.assertNotEquals(null, result.businessInfo, 'Business info should be loaded');
        System.assertNotEquals(null, result.applicantInfo, 'Applicant info should be loaded');
        System.assertNotEquals(null, result.productSelection, 'Product selection should be loaded');
        System.assertEquals('BIZ_CHECKING', result.productSelection.productCode);
    }
}

