/**
 * @description Service class for validating deposit account opening application data
 * 
 * DATA MODEL: Uses ApplicationForm, Applicant, Account, FinancialAccount
 * See /docs/01-foundation/data-model.md for complete data model
 * 
 * @author DAO AI Accelerator
 * @date 2025-01-16
 */
public with sharing class DAOValidationService {
    
    /**
     * @description Validate applicant information
     * @param applicantData Applicant data to validate
     * @return Validation result with errors if any
     */
    @AuraEnabled
    public static ValidationResult validateApplicantData(DAOApplicationService.ApplicationDataWrapper applicantData) {
        try {
            ValidationResult result = new ValidationResult();
            result.isValid = true;
            result.errors = new List<String>();

            // Validate required fields
            if (String.isBlank(applicantData.applicantFirstName)) {
                result.errors.add('First Name is required');
                result.isValid = false;
            }

            if (String.isBlank(applicantData.applicantLastName)) {
                result.errors.add('Last Name is required');
                result.isValid = false;
            }

            if (String.isBlank(applicantData.applicantEmail)) {
                result.errors.add('Email is required');
                result.isValid = false;
            } else if (!isValidEmail(applicantData.applicantEmail)) {
                result.errors.add('Invalid email format');
                result.isValid = false;
            }

            if (String.isBlank(applicantData.applicantPhone)) {
                result.errors.add('Phone is required');
                result.isValid = false;
            } else if (!isValidPhone(applicantData.applicantPhone)) {
                result.errors.add('Invalid phone format');
                result.isValid = false;
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error validating applicant data: ' + e.getMessage());
        }
    }

    /**
     * @description Validate product selection
     * @param productId Selected product ID
     * @return Validation result
     */
    @AuraEnabled
    public static ValidationResult validateProductSelection(String productId) {
        try {
            ValidationResult result = new ValidationResult();
            result.isValid = true;
            result.errors = new List<String>();

            if (String.isBlank(productId)) {
                result.errors.add('Product selection is required');
                result.isValid = false;
            }

            // TODO: Add additional product validation logic
            // - Check if product is available
            // - Validate product eligibility for applicant
            // - Check minimum requirements

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error validating product selection: ' + e.getMessage());
        }
    }

    /**
     * @description Validate collateral information
     * @param collateralItems List of collateral items
     * @return Validation result
     */
    @AuraEnabled
    public static ValidationResult validateCollateralData(List<DAOApplicationService.CollateralWrapper> collateralItems) {
        try {
            ValidationResult result = new ValidationResult();
            result.isValid = true;
            result.errors = new List<String>();

            if (collateralItems == null || collateralItems.isEmpty()) {
                result.errors.add('At least one collateral item is required');
                result.isValid = false;
            } else {
                for (DAOApplicationService.CollateralWrapper collateral : collateralItems) {
                    if (String.isBlank(collateral.collateralType)) {
                        result.errors.add('Collateral type is required for all items');
                        result.isValid = false;
                    }
                    if (collateral.value == null || collateral.value <= 0) {
                        result.errors.add('Collateral value must be greater than 0');
                        result.isValid = false;
                    }
                }
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error validating collateral data: ' + e.getMessage());
        }
    }

    /**
     * @description Validate complete application before submission
     * @param applicationData Complete application data
     * @return Validation result
     */
    @AuraEnabled
    public static ValidationResult validateCompleteApplication(DAOApplicationService.ApplicationDataWrapper applicationData) {
        try {
            ValidationResult result = new ValidationResult();
            result.isValid = true;
            result.errors = new List<String>();

            // Validate applicant data
            ValidationResult applicantValidation = validateApplicantData(applicationData);
            if (!applicantValidation.isValid) {
                result.errors.addAll(applicantValidation.errors);
                result.isValid = false;
            }

            // Validate product selection
            ValidationResult productValidation = validateProductSelection(applicationData.selectedProductId);
            if (!productValidation.isValid) {
                result.errors.addAll(productValidation.errors);
                result.isValid = false;
            }

            // Validate collateral data
            ValidationResult collateralValidation = validateCollateralData(applicationData.collateralItems);
            if (!collateralValidation.isValid) {
                result.errors.addAll(collateralValidation.errors);
                result.isValid = false;
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error validating complete application: ' + e.getMessage());
        }
    }

    // Private helper methods
    private static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        return emailPattern.matcher(email).matches();
    }

    private static Boolean isValidPhone(String phone) {
        // Remove all non-numeric characters
        String cleanPhone = phone.replaceAll('\\D', '');
        return cleanPhone.length() == 10;
    }

    // Wrapper class for validation results
    public class ValidationResult {
        @AuraEnabled public Boolean isValid { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
        @AuraEnabled public String message { get; set; }
    }
}
