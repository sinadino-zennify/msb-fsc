/**
 * @description Test class for RelationshipAssignmentController
 * @author DAO AI Accelerator
 * @date 2025-01-20
 */
@isTest
private class RelationshipAssignmentControllerTest {
    
    @TestSetup
    static void setup() {
        // Create test products
        List<Product2> products = new List<Product2>();
        
        Product2 prod1 = new Product2(
            Name = 'Business Checking',
            ProductCode = 'BUS-CHK-001',
            Description = 'Business checking account',
            Category__c = 'Checkings',
            Active_BAO__c = true,
            AvailableChannel__c = 'Branch;Online'
        );
        products.add(prod1);
        
        Product2 prod2 = new Product2(
            Name = 'Business Savings',
            ProductCode = 'BUS-SAV-001',
            Description = 'Business savings account',
            Category__c = 'Savings',
            Active_BAO__c = true,
            AvailableChannel__c = 'Branch'
        );
        products.add(prod2);
        
        insert products;
        
        // Create test ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding'
        );
        insert appForm;
        
        // Create test Applicants
        List<Applicant> applicants = new List<Applicant>();
        
        Applicant primaryApp = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Individual',
            Role__c = 'Primary Applicant',
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com'
        );
        applicants.add(primaryApp);
        
        Applicant secondaryApp = new Applicant(
            ApplicationFormId = appForm.Id,
            Type = 'Individual',
            Role__c = 'Co-Applicant',
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@test.com'
        );
        applicants.add(secondaryApp);
        
        insert applicants;
        
        // Create test ApplicationFormProducts
        List<ApplicationFormProduct> afProducts = new List<ApplicationFormProduct>();
        
        ApplicationFormProduct afp1 = new ApplicationFormProduct(
            ApplicationFormId = appForm.Id,
            ProductId = prod1.Id,
            FundingAmount__c = 5000.00
        );
        afProducts.add(afp1);
        
        ApplicationFormProduct afp2 = new ApplicationFormProduct(
            ApplicationFormId = appForm.Id,
            ProductId = prod2.Id,
            FundingAmount__c = 10000.00
        );
        afProducts.add(afp2);
        
        insert afProducts;
        
        // Create test role assignments
        List<ApplicationProductPartyRole__c> roles = new List<ApplicationProductPartyRole__c>();
        
        ApplicationProductPartyRole__c role1 = new ApplicationProductPartyRole__c(
            ApplicationForm__c = appForm.Id,
            ApplicationFormProduct__c = afp1.Id,
            Applicant__c = primaryApp.Id,
            Role__c = 'Primary;Joint'
        );
        roles.add(role1);
        
        insert roles;
    }
    
    @isTest
    static void testGetRelationshipData() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        
        Test.startTest();
        RelationshipAssignmentController.RelationshipDataWrapper result = 
            RelationshipAssignmentController.getRelationshipData(appForm.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.products.size(), 'Should have 2 products');
        System.assertEquals(2, result.applicants.size(), 'Should have 2 applicants');
        System.assertEquals(1, result.existingAssignments.size(), 'Should have 1 existing assignment');
        
        // Verify primary applicant is marked
        Boolean hasPrimary = false;
        for (RelationshipAssignmentController.ApplicantWrapper app : result.applicants) {
            if (app.isPrimary) {
                hasPrimary = true;
                break;
            }
        }
        System.assert(hasPrimary, 'Should have a primary applicant');
    }
    
    @isTest
    static void testSaveRoleAssignments_New() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        List<ApplicationFormProduct> products = [SELECT Id FROM ApplicationFormProduct WHERE ApplicationFormId = :appForm.Id];
        List<Applicant> applicants = [SELECT Id FROM Applicant WHERE ApplicationFormId = :appForm.Id];
        
        List<RelationshipAssignmentController.RoleAssignmentWrapper> assignments = 
            new List<RelationshipAssignmentController.RoleAssignmentWrapper>();
        
        // Create new assignment
        RelationshipAssignmentController.RoleAssignmentWrapper assignment = 
            new RelationshipAssignmentController.RoleAssignmentWrapper();
        assignment.productId = products[1].Id;
        assignment.applicantId = applicants[1].Id;
        assignment.roles = new List<String>{'Authorized Signer'};
        assignments.add(assignment);
        
        Test.startTest();
        List<Id> resultIds = RelationshipAssignmentController.saveRoleAssignments(appForm.Id, assignments);
        Test.stopTest();
        
        System.assertNotEquals(null, resultIds, 'Result IDs should not be null');
        System.assertEquals(1, resultIds.size(), 'Should have 1 result ID');
        
        List<ApplicationProductPartyRole__c> savedRoles = [
            SELECT Id, Role__c 
            FROM ApplicationProductPartyRole__c 
            WHERE ApplicationForm__c = :appForm.Id
            AND ApplicationFormProduct__c = :products[1].Id
        ];
        System.assertEquals(1, savedRoles.size(), 'Should have 1 saved role');
        System.assert(savedRoles[0].Role__c.contains('Authorized Signer'), 'Should contain Authorized Signer role');
    }
    
    @isTest
    static void testSaveRoleAssignments_Update() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        ApplicationProductPartyRole__c existingRole = [
            SELECT Id, ApplicationFormProduct__c, Applicant__c, Role__c
            FROM ApplicationProductPartyRole__c
            WHERE ApplicationForm__c = :appForm.Id
            LIMIT 1
        ];
        
        List<RelationshipAssignmentController.RoleAssignmentWrapper> assignments = 
            new List<RelationshipAssignmentController.RoleAssignmentWrapper>();
        
        // Update existing assignment
        RelationshipAssignmentController.RoleAssignmentWrapper assignment = 
            new RelationshipAssignmentController.RoleAssignmentWrapper();
        assignment.id = existingRole.Id;
        assignment.productId = existingRole.ApplicationFormProduct__c;
        assignment.applicantId = existingRole.Applicant__c;
        assignment.roles = new List<String>{'Primary', 'Beneficiary'};
        assignments.add(assignment);
        
        Test.startTest();
        List<Id> resultIds = RelationshipAssignmentController.saveRoleAssignments(appForm.Id, assignments);
        Test.stopTest();
        
        System.assertNotEquals(null, resultIds, 'Result IDs should not be null');
        
        ApplicationProductPartyRole__c updatedRole = [
            SELECT Id, Role__c 
            FROM ApplicationProductPartyRole__c 
            WHERE Id = :existingRole.Id
        ];
        System.assert(updatedRole.Role__c.contains('Primary'), 'Should contain Primary role');
        System.assert(updatedRole.Role__c.contains('Beneficiary'), 'Should contain Beneficiary role');
    }
    
    @isTest
    static void testSaveRoleAssignments_Delete() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        
        // Save with empty assignments list - should delete existing
        List<RelationshipAssignmentController.RoleAssignmentWrapper> assignments = 
            new List<RelationshipAssignmentController.RoleAssignmentWrapper>();
        
        Test.startTest();
        RelationshipAssignmentController.saveRoleAssignments(appForm.Id, assignments);
        Test.stopTest();
        
        List<ApplicationProductPartyRole__c> remainingRoles = [
            SELECT Id 
            FROM ApplicationProductPartyRole__c 
            WHERE ApplicationForm__c = :appForm.Id
        ];
        System.assertEquals(0, remainingRoles.size(), 'Should have deleted all roles');
    }
    
    @isTest
    static void testGetRelationshipData_NoProducts() {
        // Create new ApplicationForm without products
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding'
        );
        insert appForm;
        
        Test.startTest();
        RelationshipAssignmentController.RelationshipDataWrapper result = 
            RelationshipAssignmentController.getRelationshipData(appForm.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.products.size(), 'Should have 0 products');
    }
}