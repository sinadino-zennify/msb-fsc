@IsTest
private class WizardConfigServiceTest {
    
    @IsTest
    static void testGetSteps_ValidWizardApiName() {
        // Test with the deployed CMDT records
        String wizardApiName = 'DAO_Business_InBranch';
        
        Test.startTest();
        List<WizardConfigService.WizardStepDTO> steps = WizardConfigService.getSteps(wizardApiName);
        Test.stopTest();
        
        // Verify we get the 3 steps in correct order
        System.assertEquals(3, steps.size(), 'Should return 3 steps for DAO_Business_InBranch');
        
        // Verify ordering by Order__c
        System.assertEquals(1, steps[0].order, 'First step should have order 1');
        System.assertEquals(2, steps[1].order, 'Second step should have order 2');
        System.assertEquals(3, steps[2].order, 'Third step should have order 3');
        
        // Verify component bundles
        System.assertEquals('applicantDetails', steps[0].componentBundle, 'First step should be applicantDetails');
        System.assertEquals('productSelection', steps[1].componentBundle, 'Second step should be productSelection');
        System.assertEquals('reviewAndSubmit', steps[2].componentBundle, 'Third step should be reviewAndSubmit');
        
        // Verify step labels (should use StepLabel__c when available)
        System.assertEquals('Applicant', steps[0].stepLabel, 'First step label should be Applicant');
        System.assertEquals('Product', steps[1].stepLabel, 'Second step label should be Product');
        System.assertEquals('Review', steps[2].stepLabel, 'Third step label should be Review');
        
        // Verify wizard API name
        for (WizardConfigService.WizardStepDTO step : steps) {
            System.assertEquals(wizardApiName, step.wizardApiName, 'All steps should have correct wizard API name');
        }
    }
    
    @IsTest
    static void testGetSteps_BlankWizardApiName() {
        Test.startTest();
        List<WizardConfigService.WizardStepDTO> steps = WizardConfigService.getSteps('');
        Test.stopTest();
        
        System.assertEquals(0, steps.size(), 'Should return empty list for blank wizard API name');
    }
    
    @IsTest
    static void testGetSteps_NullWizardApiName() {
        Test.startTest();
        List<WizardConfigService.WizardStepDTO> steps = WizardConfigService.getSteps(null);
        Test.stopTest();
        
        System.assertEquals(0, steps.size(), 'Should return empty list for null wizard API name');
    }
    
    @IsTest
    static void testGetSteps_NonExistentWizardApiName() {
        Test.startTest();
        List<WizardConfigService.WizardStepDTO> steps = WizardConfigService.getSteps('NonExistent_Wizard');
        Test.stopTest();
        
        System.assertEquals(0, steps.size(), 'Should return empty list for non-existent wizard API name');
    }
    
    @IsTest
    static void testStepLabelDefaulting() {
        // This test verifies that stepLabel defaults to DeveloperName when StepLabel__c is blank
        // Since we can't easily create CMDT records in tests, this tests the logic with existing data
        String wizardApiName = 'DAO_Business_InBranch';
        
        Test.startTest();
        List<WizardConfigService.WizardStepDTO> steps = WizardConfigService.getSteps(wizardApiName);
        Test.stopTest();
        
        // Verify that all steps have non-blank step labels
        for (WizardConfigService.WizardStepDTO step : steps) {
            System.assert(String.isNotBlank(step.stepLabel), 'Step label should never be blank');
            System.assert(String.isNotBlank(step.developerName), 'Developer name should never be blank');
        }
    }
    
    @IsTest
    static void testSkippableDefaulting() {
        String wizardApiName = 'DAO_Business_InBranch';
        
        Test.startTest();
        List<WizardConfigService.WizardStepDTO> steps = WizardConfigService.getSteps(wizardApiName);
        Test.stopTest();
        
        // Verify that skippable defaults to false when null
        for (WizardConfigService.WizardStepDTO step : steps) {
            System.assertEquals(false, step.skippable, 'Skippable should default to false');
        }
    }
}
