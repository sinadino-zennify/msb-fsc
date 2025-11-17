@IsTest
private class WizardPersistenceServiceTest {
    
    @TestSetup
    static void setup() {
        // Create test Account for testing
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    }
    
    @IsTest
    static void testUpsertStep_ApplicantStep_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Map<String, Object> payload = new Map<String, Object>{
            'accountId' => testAccount.Id,
            'applicantType' => 'Primary'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Applicant', payload, null);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(0, response.messages.size(), 'Should have no error messages');
        System.assert(response.savedIds.containsKey('applicant'), 'Should contain applicant ID');
    }
    
    @IsTest
    static void testUpsertStep_ProductStep_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Map<String, Object> payload = new Map<String, Object>{
            'productCode' => 'CHECKING_001'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Product', payload, null);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(0, response.messages.size(), 'Should have no error messages');
        System.assert(response.savedIds.containsKey('applicationForm'), 'Should contain applicationForm ID');
    }
    
    @IsTest
    static void testUpsertStep_ReviewStep_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Map<String, Object> payload = new Map<String, Object>{
            'confirmed' => true
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Review', payload, null);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(0, response.messages.size(), 'Should have no error messages');
        System.assert(response.savedIds.containsKey('applicationForm'), 'Should contain applicationForm ID');
    }
    
    @IsTest
    static void testUpsertStep_NullApplicationId_PrototypeMode() {
        Map<String, Object> payload = new Map<String, Object>{
            'accountId' => 'test'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(null, 'DAO_Business_InBranch_Applicant', payload, null);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Response should succeed in prototype mode');
        System.assertEquals(0, response.messages.size(), 'Should have no error messages');
        System.assert(response.savedIds.containsKey('placeholder'), 'Should contain placeholder ID');
    }
    
    @IsTest
    static void testUpsertStep_BlankStepName() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Map<String, Object> payload = new Map<String, Object>{
            'accountId' => 'test'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(testAccount.Id, '', payload, null);
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'Response should fail');
        System.assertEquals(1, response.messages.size(), 'Should have one error message');
        System.assertEquals('MISSING_STEP_NAME', response.messages[0].code, 'Should have correct error code');
    }
    
    @IsTest
    static void testUpsertStep_EmptyPayload() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Applicant', new Map<String, Object>(), null);
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'Response should fail');
        System.assertEquals(1, response.messages.size(), 'Should have one error message');
        System.assertEquals('MISSING_PAYLOAD', response.messages[0].code, 'Should have correct error code');
    }
    
    @IsTest
    static void testUpsertStep_UnknownStep() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Map<String, Object> payload = new Map<String, Object>{
            'test' => 'value'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(testAccount.Id, 'Unknown_Step', payload, null);
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'Response should fail');
        System.assertEquals(1, response.messages.size(), 'Should have one error message');
        System.assertEquals('UNKNOWN_STEP', response.messages[0].code, 'Should have correct error code');
    }
    
    @IsTest
    static void testUpsertStep_WithOpportunityContext() {
        // Create test Account and Opportunity
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30)
        );
        insert testOpp;
        
        Map<String, Object> payload = new Map<String, Object>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john.doe@example.com'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(null, 'DAO_Business_InBranch_Applicant', payload, testOpp.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assert(response.savedIds.containsKey('applicationForm'), 'Should create ApplicationForm');
        
        // Verify ApplicationForm has OpportunityId and AccountId set
        Id appFormId = response.savedIds.get('applicationForm');
        ApplicationForm appForm = [SELECT OpportunityId, AccountId FROM ApplicationForm WHERE Id = :appFormId];
        System.assertEquals(testOpp.Id, appForm.OpportunityId, 'Should set OpportunityId from context');
        System.assertEquals(testAccount.Id, appForm.AccountId, 'Should set AccountId from Opportunity.AccountId');
    }
    
    @IsTest
    static void testUpsertStep_WithAccountContext() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Map<String, Object> payload = new Map<String, Object>{
            'firstName' => 'Jane',
            'lastName' => 'Smith',
            'email' => 'jane.smith@example.com'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response = 
            WizardPersistenceService.upsertStep(null, 'DAO_Business_InBranch_Applicant', payload, testAccount.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assert(response.savedIds.containsKey('applicationForm'), 'Should create ApplicationForm');
        
        // Verify ApplicationForm has AccountId set
        Id appFormId = response.savedIds.get('applicationForm');
        ApplicationForm appForm = [SELECT AccountId FROM ApplicationForm WHERE Id = :appFormId];
        System.assertEquals(testAccount.Id, appForm.AccountId, 'Should set AccountId from context');
    }
    
    @IsTest
    static void testUpsertApplicant_PreventsDuplicates() {
        // Create ApplicationForm first
        Map<String, Object> payload1 = new Map<String, Object>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john.doe@example.com'
        };
        
        WizardPersistenceService.PersistenceResponse response1 = 
            WizardPersistenceService.upsertStep(null, 'DAO_Business_InBranch_Applicant', payload1, null);
        Id appFormId = response1.savedIds.get('applicationForm');
        Id applicantId1 = response1.savedIds.get('applicant');
        
        // Update the same applicant with new email
        Map<String, Object> payload2 = new Map<String, Object>{
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john.updated@example.com'
        };
        
        Test.startTest();
        WizardPersistenceService.PersistenceResponse response2 = 
            WizardPersistenceService.upsertStep(appFormId, 'DAO_Business_InBranch_Applicant', payload2, null);
        Test.stopTest();
        
        Id applicantId2 = response2.savedIds.get('applicant');
        System.assertEquals(applicantId1, applicantId2, 'Should update existing Applicant, not create new one');
        
        // Verify only one Applicant exists for this ApplicationForm
        List<Applicant> applicants = [SELECT Id, Email FROM Applicant WHERE ApplicationFormId = :appFormId];
        System.assertEquals(1, applicants.size(), 'Should have only one Applicant record');
        System.assertEquals('john.updated@example.com', applicants[0].Email, 'Should have updated email');
    }
    
    @IsTest
    static void testErrorMessage_Constructor() {
        WizardPersistenceService.ErrorMessage error = new WizardPersistenceService.ErrorMessage(
            'TEST_CODE', 'Test message', 'TestField__c'
        );
        
        System.assertEquals('TEST_CODE', error.code, 'Should set correct code');
        System.assertEquals('Test message', error.message, 'Should set correct message');
        System.assertEquals('TestField__c', error.fieldApiName, 'Should set correct field API name');
    }
    
    @IsTest
    static void testPersistenceResponse_Constructor() {
        WizardPersistenceService.PersistenceResponse response = new WizardPersistenceService.PersistenceResponse();
        
        System.assertEquals(true, response.success, 'Should default to success');
        System.assertNotEquals(null, response.messages, 'Should initialize messages list');
        System.assertNotEquals(null, response.savedIds, 'Should initialize savedIds map');
        System.assertEquals(0, response.messages.size(), 'Should start with empty messages');
        System.assertEquals(0, response.savedIds.size(), 'Should start with empty savedIds');
    }
}
