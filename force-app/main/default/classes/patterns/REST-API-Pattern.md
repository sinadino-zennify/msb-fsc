# REST API Pattern - DAO Integration

This document outlines the recommended pattern for implementing REST API endpoints in {{PROJECT_NAME}}.

---

## 📋 Overview

REST APIs in this project follow a consistent pattern for:
- Request handling
- Payload parsing
- Response generation
- Error handling

---

## 🏗️ Class Structure

### 1. REST Service Class

**Purpose**: Handles HTTP requests and orchestrates the flow

```java
/**
 * @description REST API endpoint for {{INTEGRATION_SOURCE}} integration
 * 
 * DATA MODEL: Uses ApplicationForm, Applicant, Account, FinancialAccount
 * See /docs/01-foundation/data-model.md for complete data model
 * 
 * @endpoint POST /services/apexrest/dao/application
 * @authentication OAuth 2.0 via Connected App
 */
@RestResource(urlMapping='/dao/application')
global with sharing class DaoApplicationRestService {
    
    @HttpPost
    global static void processApplication() {
        ApiResponse.BaseResponse response;
        Integer httpStatusCode = 200;
        
        try {
            // 1. Get request
            RestRequest request = RestContext.request;
            String requestBody = request.requestBody.toString();
            
            // 2. Parse payload
            Payload payload = parsePayload(requestBody);
            
            // 3. Process (validate, create/update records)
            // TODO: Implement business logic
            
            // 4. Build success response
            response = buildSuccessResponse(payload);
            httpStatusCode = 200;
            
        } catch (Exception e) {
            // 5. Build error response
            response = buildErrorResponse(e);
            httpStatusCode = 500;
        }
        
        // 6. Set response
        RestContext.response.statusCode = httpStatusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}
```

### 2. Payload DTO Class

**Purpose**: Defines request structure for JSON deserialization

```java
/**
 * @description Data Transfer Objects for {{INTEGRATION_SOURCE}} API
 * 
 * Field names aligned with field-mappings.csv
 */
global class DaoApplicationPayload {
    
    global class Payload {
        public List<ApplicantData> applicants;
        public BusinessData business;
        public ApplicationData application;
    }
    
    global class ApplicantData {
        public String dao_applicant_id;  // External ID
        public String first_name;
        public String last_name;
        // ... more fields from CSV
    }
    
    global class BusinessData {
        public String dao_business_id;  // External ID
        public String business_name;
        // ... more fields from CSV
    }
    
    global class ApplicationData {
        public String dao_application_id;  // External ID
        public String stage;
        // ... more fields from CSV
    }
}
```

### 3. Response Class

**Purpose**: Defines response structure

```java
/**
 * @description Response classes for {{INTEGRATION_SOURCE}} API
 */
global class ApiResponse {
    
    global virtual class BaseResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public DateTime timestamp;
        @AuraEnabled public String message;
    }
    
    global class SuccessResponse extends BaseResponse {
        @AuraEnabled public ApplicationResult application;
        @AuraEnabled public BusinessResult business;
        @AuraEnabled public List<ApplicantResult> applicants;
        
        global SuccessResponse() {
            this.success = true;
            this.timestamp = System.now();
            this.applicants = new List<ApplicantResult>();
        }
    }
    
    global class ErrorResponse extends BaseResponse {
        @AuraEnabled public String error_code;
        @AuraEnabled public List<ErrorDetail> errors;
        
        global ErrorResponse() {
            this.success = false;
            this.timestamp = System.now();
            this.errors = new List<ErrorDetail>();
        }
    }
}
```

---

## 🔒 Security Considerations

1. **Use `with sharing`** for security enforcement
2. **Validate all inputs** before processing
3. **Check CRUD/FLS** before DML operations
4. **Sanitize debug logs** - never log PII
5. **Use External IDs** for idempotent upserts

---

## 🧪 Testing Pattern

```java
@isTest
private class DaoApplicationRestServiceTest {
    
    @testSetup
    static void setup() {
        // Minimal test data setup
    }
    
    @isTest
    static void testSuccessfulRequest() {
        Test.startTest();
        
        // 1. Prepare request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/dao/application';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(getTestPayload());
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        // 2. Call endpoint
        DaoApplicationRestService.processApplication();
        
        // 3. Assert response
        String responseBody = RestContext.response.responseBody.toString();
        // Add assertions
        
        Test.stopTest();
    }
    
    private static String getTestPayload() {
        // Return test JSON matching field-mappings.csv
        return '{ "applicants": [...], "business": {...}, "application": {...} }';
    }
}
```

---

## 📚 References

- `/docs/01-foundation/field-mappings.csv` - Field mapping source
- `/docs/04-implementation/dao-api-quickstart.md` - API setup guide
- Salesforce REST API Guide: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/

---

**Last Updated**: 2025-01-16  
**Pattern Version**: 1.0

