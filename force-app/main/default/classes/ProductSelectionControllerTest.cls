/**
 * @description Test class for ProductSelectionController
 * @author DAO AI Accelerator
 * @date 2025-01-16
 */
@isTest
private class ProductSelectionControllerTest {
    
    @testSetup
    static void setup() {
        // Create test products
        List<Product2> products = new List<Product2>();
        
        Product2 prod1 = new Product2(
            Name = 'Business Checking',
            ProductCode = 'BIZ_CHK_001',
            Description = 'Standard business checking account',
            Category__c = 'Checkings',
            Active_BAO__c = true,
            AvailableChannel__c = 'Branch'
        );
        products.add(prod1);
        
        Product2 prod2 = new Product2(
            Name = 'Business Savings',
            ProductCode = 'BIZ_SAV_001',
            Description = 'Business savings account',
            Category__c = 'Savings',
            Active_BAO__c = true,
            AvailableChannel__c = 'Branch'
        );
        products.add(prod2);
        
        Product2 prod3 = new Product2(
            Name = 'Consumer Checking',
            ProductCode = 'CON_CHK_001',
            Description = 'Personal checking account',
            Category__c = 'Checkings',
            Active_CAO__c = true,
            AvailableChannel__c = 'Branch;Online'
        );
        products.add(prod3);
        
        insert products;
        
        // Create test ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            UsageType = 'Onboarding'
        );
        insert appForm;
        
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
    }
    
    @isTest
    static void testGetProducts_Business() {
        Test.startTest();
        ProductSelectionController.ProductDataWrapper result = 
            ProductSelectionController.getProducts('Business');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.allProducts, 'Products list should not be null');
        System.assertEquals(2, result.allProducts.size(), 'Should return 2 business products');
        System.assertNotEquals(null, result.categories, 'Categories should not be null');
        System.assert(result.categories.size() > 0, 'Should have at least one category');
    }
    
    @isTest
    static void testGetProducts_Consumer() {
        Test.startTest();
        ProductSelectionController.ProductDataWrapper result = 
            ProductSelectionController.getProducts('Consumer');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.allProducts, 'Products list should not be null');
        System.assertEquals(1, result.allProducts.size(), 'Should return 1 consumer product');
    }
    
    @isTest
    static void testGetExistingProducts() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        
        Test.startTest();
        List<ProductSelectionController.CartItemWrapper> result = 
            ProductSelectionController.getExistingProducts(appForm.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Should return 2 existing products');
        System.assertEquals(5000.00, result[0].fundingAmount, 'First product funding amount should match');
        System.assertEquals(10000.00, result[1].fundingAmount, 'Second product funding amount should match');
    }
    
    @isTest
    static void testSaveProducts_New() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = 'BIZ_CHK_001' LIMIT 1];
        
        // Delete existing products first
        delete [SELECT Id FROM ApplicationFormProduct WHERE ApplicationFormId = :appForm.Id];
        
        List<ProductSelectionController.CartItemWrapper> cartItems = new List<ProductSelectionController.CartItemWrapper>();
        ProductSelectionController.CartItemWrapper item = new ProductSelectionController.CartItemWrapper();
        item.productId = prod.Id;
        item.fundingAmount = 7500.00;
        cartItems.add(item);
        
        Test.startTest();
        List<Id> resultIds = ProductSelectionController.saveProducts(appForm.Id, cartItems);
        Test.stopTest();
        
        System.assertNotEquals(null, resultIds, 'Result IDs should not be null');
        System.assertEquals(1, resultIds.size(), 'Should return 1 saved ID');
        
        List<ApplicationFormProduct> savedProducts = [
            SELECT Id, FundingAmount__c 
            FROM ApplicationFormProduct 
            WHERE ApplicationFormId = :appForm.Id
        ];
        System.assertEquals(1, savedProducts.size(), 'Should have 1 saved product');
        System.assertEquals(7500.00, savedProducts[0].FundingAmount__c, 'Funding amount should match');
    }
    
    @isTest
    static void testSaveProducts_Update() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        ApplicationFormProduct existingProduct = [
            SELECT Id, ProductId, FundingAmount__c 
            FROM ApplicationFormProduct 
            WHERE ApplicationFormId = :appForm.Id 
            LIMIT 1
        ];
        
        List<ProductSelectionController.CartItemWrapper> cartItems = new List<ProductSelectionController.CartItemWrapper>();
        ProductSelectionController.CartItemWrapper item = new ProductSelectionController.CartItemWrapper();
        item.id = existingProduct.Id;
        item.productId = existingProduct.ProductId;
        item.fundingAmount = 12000.00;
        cartItems.add(item);
        
        Test.startTest();
        List<Id> resultIds = ProductSelectionController.saveProducts(appForm.Id, cartItems);
        Test.stopTest();
        
        System.assertNotEquals(null, resultIds, 'Result IDs should not be null');
        
        ApplicationFormProduct updatedProduct = [
            SELECT Id, FundingAmount__c 
            FROM ApplicationFormProduct 
            WHERE Id = :existingProduct.Id
        ];
        System.assertEquals(12000.00, updatedProduct.FundingAmount__c, 'Funding amount should be updated');
    }
    
    @isTest
    static void testSaveProducts_Delete() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        
        Integer initialCount = [
            SELECT COUNT() 
            FROM ApplicationFormProduct 
            WHERE ApplicationFormId = :appForm.Id
        ];
        System.assertEquals(2, initialCount, 'Should start with 2 products');
        
        // Save empty cart (should delete all)
        List<ProductSelectionController.CartItemWrapper> cartItems = new List<ProductSelectionController.CartItemWrapper>();
        
        Test.startTest();
        List<Id> resultIds = ProductSelectionController.saveProducts(appForm.Id, cartItems);
        Test.stopTest();
        
        Integer finalCount = [
            SELECT COUNT() 
            FROM ApplicationFormProduct 
            WHERE ApplicationFormId = :appForm.Id
        ];
        System.assertEquals(0, finalCount, 'All products should be deleted');
    }
    
    @isTest
    static void testGetProducts_NoResults() {
        // Delete all products
        delete [SELECT Id FROM Product2];
        
        Test.startTest();
        ProductSelectionController.ProductDataWrapper result = 
            ProductSelectionController.getProducts('Business');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.allProducts.size(), 'Should return empty list');
    }
}