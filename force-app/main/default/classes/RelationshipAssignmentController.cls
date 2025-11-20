/**
 * @description Controller for RelationshipAssignment LWC - handles product-applicant role assignments
 * @author DAO AI Accelerator
 * @date 2025-01-20
 */
public with sharing class RelationshipAssignmentController {
    
    /**
     * @description Get all data needed for relationship assignment grid
     * @param applicationFormId The ApplicationForm record ID
     * @return RelationshipDataWrapper containing products, applicants, and existing assignments
     */
    @AuraEnabled(cacheable=false)
    public static RelationshipDataWrapper getRelationshipData(Id applicationFormId) {
        try {
            RelationshipDataWrapper result = new RelationshipDataWrapper();
            
            // Get selected products for this application
            List<ApplicationFormProduct> products = [
                SELECT Id, Name, ProductId, Product.Name, Product.ProductCode, 
                       FundingAmount__c
                FROM ApplicationFormProduct
                WHERE ApplicationFormId = :applicationFormId
                ORDER BY CreatedDate
            ];
            
            result.products = new List<ProductWrapper>();
            for (ApplicationFormProduct afp : products) {
                ProductWrapper pw = new ProductWrapper();
                pw.id = afp.Id;
                pw.name = afp.Product.Name;
                pw.productCode = afp.Product.ProductCode;
                pw.fundingAmount = afp.FundingAmount__c;
                result.products.add(pw);
            }
            
            // Get all applicants (Type = 'Individual') for this application
            List<Applicant> applicants = [
                SELECT Id, FirstName, LastName, MiddleName, Email, Role__c
                FROM Applicant
                WHERE ApplicationFormId = :applicationFormId
                AND Type = 'Individual'
                ORDER BY Role__c DESC, CreatedDate
            ];
            
            result.applicants = new List<ApplicantWrapper>();
            for (Applicant app : applicants) {
                ApplicantWrapper aw = new ApplicantWrapper();
                aw.id = app.Id;
                aw.firstName = app.FirstName;
                aw.lastName = app.LastName;
                aw.middleName = app.MiddleName;
                aw.email = app.Email;
                aw.role = app.Role__c;
                aw.displayName = getApplicantDisplayName(app);
                aw.isPrimary = app.Role__c == 'Primary Applicant';
                result.applicants.add(aw);
            }
            
            // Get existing role assignments
            List<ApplicationProductPartyRole__c> existingRoles = [
                SELECT Id, ApplicationFormProduct__c, Applicant__c, Role__c
                FROM ApplicationProductPartyRole__c
                WHERE ApplicationForm__c = :applicationFormId
            ];
            
            result.existingAssignments = new List<RoleAssignmentWrapper>();
            for (ApplicationProductPartyRole__c role : existingRoles) {
                RoleAssignmentWrapper raw = new RoleAssignmentWrapper();
                raw.id = role.Id;
                raw.productId = role.ApplicationFormProduct__c;
                raw.applicantId = role.Applicant__c;
                raw.roles = role.Role__c != null ? role.Role__c.split(';') : new List<String>();
                result.existingAssignments.add(raw);
            }
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving relationship data: ' + e.getMessage());
        }
    }
    
    /**
     * @description Save role assignments for products and applicants
     * @param applicationFormId The ApplicationForm record ID
     * @param assignments List of role assignments to save
     * @return List of created/updated ApplicationProductPartyRole IDs
     */
    @AuraEnabled
    public static List<Id> saveRoleAssignments(Id applicationFormId, List<RoleAssignmentWrapper> assignments) {
        try {
            List<Id> resultIds = new List<Id>();
            
            // Get existing assignments
            Map<String, ApplicationProductPartyRole__c> existingMap = new Map<String, ApplicationProductPartyRole__c>();
            for (ApplicationProductPartyRole__c role : [
                SELECT Id, ApplicationFormProduct__c, Applicant__c, Role__c
                FROM ApplicationProductPartyRole__c
                WHERE ApplicationForm__c = :applicationFormId
            ]) {
                String key = String.valueOf(role.ApplicationFormProduct__c) + '_' + String.valueOf(role.Applicant__c);
                existingMap.put(key, role);
            }
            
            List<ApplicationProductPartyRole__c> toUpsert = new List<ApplicationProductPartyRole__c>();
            Set<String> keysToKeep = new Set<String>();
            
            // Process assignments
            for (RoleAssignmentWrapper assignment : assignments) {
                if (assignment.roles == null || assignment.roles.isEmpty()) {
                    continue; // Skip if no roles selected
                }
                
                String key = String.valueOf(assignment.productId) + '_' + String.valueOf(assignment.applicantId);
                keysToKeep.add(key);
                
                ApplicationProductPartyRole__c role;
                if (String.isNotBlank(assignment.id)) {
                    // Update existing by record ID
                    role = new ApplicationProductPartyRole__c(Id = assignment.id);
                } else if (existingMap.containsKey(key)) {
                    // Update existing by product+applicant match
                    role = existingMap.get(key);
                } else {
                    // Create new
                    role = new ApplicationProductPartyRole__c();
                    role.ApplicationForm__c = applicationFormId;
                    role.ApplicationFormProduct__c = assignment.productId;
                    role.Applicant__c = assignment.applicantId;
                }
                
                role.Role__c = String.join(assignment.roles, ';');
                toUpsert.add(role);
            }
            
            // Upsert assignments
            if (!toUpsert.isEmpty()) {
                upsert toUpsert;
                for (ApplicationProductPartyRole__c role : toUpsert) {
                    resultIds.add(role.Id);
                }
            }
            
            // Delete removed assignments
            List<ApplicationProductPartyRole__c> toDelete = new List<ApplicationProductPartyRole__c>();
            for (String key : existingMap.keySet()) {
                if (!keysToKeep.contains(key)) {
                    toDelete.add(existingMap.get(key));
                }
            }
            
            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
            
            return resultIds;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error saving role assignments: ' + e.getMessage());
        }
    }
    
    // Helper method to format applicant display name
    private static String getApplicantDisplayName(Applicant app) {
        String displayName = '';
        if (String.isNotBlank(app.FirstName)) {
            displayName = app.FirstName;
        }
        if (String.isNotBlank(app.MiddleName)) {
            displayName += ' ' + app.MiddleName;
        }
        if (String.isNotBlank(app.LastName)) {
            displayName += ' ' + app.LastName;
        }
        return displayName.trim();
    }
    
    // Wrapper classes
    public class RelationshipDataWrapper {
        @AuraEnabled public List<ProductWrapper> products { get; set; }
        @AuraEnabled public List<ApplicantWrapper> applicants { get; set; }
        @AuraEnabled public List<RoleAssignmentWrapper> existingAssignments { get; set; }
    }
    
    public class ProductWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public Decimal fundingAmount { get; set; }
    }
    
    public class ApplicantWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String middleName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String role { get; set; }
        @AuraEnabled public String displayName { get; set; }
        @AuraEnabled public Boolean isPrimary { get; set; }
    }
    
    public class RoleAssignmentWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public Id applicantId { get; set; }
        @AuraEnabled public List<String> roles { get; set; }
    }
}