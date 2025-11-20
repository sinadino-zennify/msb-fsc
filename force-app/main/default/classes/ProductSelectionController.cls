/**
 * @description Controller for ProductSelection LWC - handles Product2 queries and ApplicationFormProduct persistence
 * @author DAO AI Accelerator
 * @date 2025-01-16
 */
public with sharing class ProductSelectionController {
    
    /**
     * @description Get active products for Business Account Opening filtered by Branch channel
     * @param workflowType Type of workflow (Business/Consumer)
     * @return List of products grouped by category
     */
    @AuraEnabled(cacheable=true)
    public static ProductDataWrapper getProducts(String workflowType) {
        try {
            // Build query based on workflow type
            String activeField = workflowType == 'Business' ? 'Active_BAO__c' : 'Active_CAO__c';
            
            String query = 'SELECT Id, Name, ProductCode, Description, Category__c, ' +
                          'Family, Product_Type__c, MinorCode__c ' +
                          'FROM Product2 ' +
                          'WHERE ' + activeField + ' = true ' +
                          'AND AvailableChannel__c INCLUDES (\'Branch\') ' +
                          'ORDER BY Category__c, Name';
            
            List<Product2> products = Database.query(query);
            
            // Group products by category
            Map<String, List<ProductWrapper>> categoryMap = new Map<String, List<ProductWrapper>>();
            Set<String> categories = new Set<String>();
            
            for (Product2 prod : products) {
                String category = prod.Category__c != null ? prod.Category__c : 'Other';
                categories.add(category);
                
                if (!categoryMap.containsKey(category)) {
                    categoryMap.put(category, new List<ProductWrapper>());
                }
                
                ProductWrapper wrapper = new ProductWrapper();
                wrapper.id = prod.Id;
                wrapper.name = prod.Name;
                wrapper.productCode = prod.ProductCode;
                wrapper.description = prod.Description;
                wrapper.category = category;
                wrapper.family = prod.Family;
                wrapper.productType = prod.Product_Type__c;
                wrapper.minorCode = prod.MinorCode__c;
                
                categoryMap.get(category).add(wrapper);
            }
            
            // Build category list
            List<CategoryWrapper> categoryList = new List<CategoryWrapper>();
            for (String cat : categories) {
                CategoryWrapper catWrapper = new CategoryWrapper();
                catWrapper.name = cat;
                catWrapper.label = cat;
                catWrapper.productCount = categoryMap.get(cat).size();
                categoryList.add(catWrapper);
            }
            
            ProductDataWrapper result = new ProductDataWrapper();
            result.categories = categoryList;
            result.allProducts = new List<ProductWrapper>();
            for (List<ProductWrapper> prods : categoryMap.values()) {
                result.allProducts.addAll(prods);
            }
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get existing ApplicationFormProducts for an ApplicationForm
     * @param applicationFormId The ApplicationForm record ID
     * @return List of existing cart items
     */
    @AuraEnabled
    public static List<CartItemWrapper> getExistingProducts(Id applicationFormId) {
        try {
            List<CartItemWrapper> cartItems = new List<CartItemWrapper>();
            
            List<ApplicationFormProduct> afProducts = [
                SELECT Id, Name, ProductId, Product.Name, Product.ProductCode, 
                       Product.Description, Product.Category__c, FundingAmount__c
                FROM ApplicationFormProduct
                WHERE ApplicationFormId = :applicationFormId
                ORDER BY CreatedDate
            ];
            
            for (ApplicationFormProduct afp : afProducts) {
                CartItemWrapper item = new CartItemWrapper();
                item.id = afp.Id;
                item.productId = afp.ProductId;
                item.productName = afp.Product.Name;
                item.productCode = afp.Product.ProductCode;
                item.description = afp.Product.Description;
                item.category = afp.Product.Category__c;
                item.fundingAmount = afp.FundingAmount__c;
                cartItems.add(item);
            }
            
            return cartItems;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving existing products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Save selected products as ApplicationFormProducts
     * @param applicationFormId The ApplicationForm record ID
     * @param cartItems List of products to save
     * @return List of created/updated ApplicationFormProduct IDs
     */
    @AuraEnabled
    public static List<Id> saveProducts(Id applicationFormId, List<CartItemWrapper> cartItems) {
        try {
            List<Id> resultIds = new List<Id>();
            
            // Get existing ApplicationFormProducts
            Map<Id, ApplicationFormProduct> existingMap = new Map<Id, ApplicationFormProduct>();
            for (ApplicationFormProduct afp : [
                SELECT Id, ProductId, FundingAmount__c
                FROM ApplicationFormProduct
                WHERE ApplicationFormId = :applicationFormId
            ]) {
                existingMap.put(afp.ProductId, afp);
            }
            
            List<ApplicationFormProduct> toUpsert = new List<ApplicationFormProduct>();
            Set<Id> productIdsToKeep = new Set<Id>();
            
            // Process cart items
            for (CartItemWrapper item : cartItems) {
                productIdsToKeep.add(item.productId);
                
                ApplicationFormProduct afp;
                if (item.id != null) {
                    // Update existing
                    afp = new ApplicationFormProduct(Id = item.id);
                } else if (existingMap.containsKey(item.productId)) {
                    // Update by Product2Id match
                    afp = existingMap.get(item.productId);
                } else {
                    // Create new
                    afp = new ApplicationFormProduct();
                    afp.ApplicationFormId = applicationFormId;
                    afp.ProductId = item.productId;
                }
                
                afp.FundingAmount__c = item.fundingAmount;
                toUpsert.add(afp);
            }
            
            // Upsert products
            if (!toUpsert.isEmpty()) {
                upsert toUpsert;
                for (ApplicationFormProduct afp : toUpsert) {
                    resultIds.add(afp.Id);
                }
            }
            
            // Delete removed products
            List<ApplicationFormProduct> toDelete = new List<ApplicationFormProduct>();
            for (ApplicationFormProduct afp : existingMap.values()) {
                if (!productIdsToKeep.contains(afp.ProductId)) {
                    toDelete.add(afp);
                }
            }
            
            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
            
            return resultIds;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error saving products: ' + e.getMessage());
        }
    }
    
    // Wrapper classes
    public class ProductDataWrapper {
        @AuraEnabled public List<CategoryWrapper> categories { get; set; }
        @AuraEnabled public List<ProductWrapper> allProducts { get; set; }
    }
    
    public class CategoryWrapper {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Integer productCount { get; set; }
    }
    
    public class ProductWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String family { get; set; }
        @AuraEnabled public String productType { get; set; }
        @AuraEnabled public String minorCode { get; set; }
    }
    
    public class CartItemWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public Decimal fundingAmount { get; set; }
    }
}