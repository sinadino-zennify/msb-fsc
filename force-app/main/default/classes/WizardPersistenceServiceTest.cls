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
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Applicant', payload);
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
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Product', payload);
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
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Review', payload);
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
            WizardPersistenceService.upsertStep(null, 'DAO_Business_InBranch_Applicant', payload);
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
            WizardPersistenceService.upsertStep(testAccount.Id, '', payload);
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
            WizardPersistenceService.upsertStep(testAccount.Id, 'DAO_Business_InBranch_Applicant', new Map<String, Object>());
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
            WizardPersistenceService.upsertStep(testAccount.Id, 'Unknown_Step', payload);
        Test.stopTest();
        
        System.assertEquals(false, response.success, 'Response should fail');
        System.assertEquals(1, response.messages.size(), 'Should have one error message');
        System.assertEquals('UNKNOWN_STEP', response.messages[0].code, 'Should have correct error code');
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
