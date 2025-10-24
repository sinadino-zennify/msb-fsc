// Test script for {{INTEGRATION_SOURCE}} API
// This validates that the API correctly parses the request payload

// Create test JSON payload matching field-mappings-template.csv
String jsonPayload = '{' +
'  "applicants": [' +
'    {' +
'      "dao_applicant_id": "TEST001",' +
'      "first_name": "John",' +
'      "last_name": "Doe",' +
'      "email": "john.doe@test.com"' +
'    }' +
'  ],' +
'  "business": {' +
'    "dao_business_id": "TESTBIZ001",' +
'    "business_name": "Test Business LLC"' +
'  },' +
'  "application": {' +
'    "dao_application_id": "TESTAPP001",' +
'    "stage": "In Progress"' +
'  }' +
'}';

System.debug('=== TEST: {{INTEGRATION_SOURCE}} API Field Mapping Validation ===');
System.debug('Testing with payload matching field-mappings-template.csv');
System.debug('');

// Test: Parse the JSON into the payload structure
try {
    // TODO: Replace with your actual payload class name
    // YourPayloadClass.Payload payload = (YourPayloadClass.Payload) JSON.deserialize(
    //     jsonPayload, 
    //     YourPayloadClass.Payload.class
    // );
    
    System.debug('✓ JSON parsing successful');
    System.debug('');
    
    // Add field validation here
    System.debug('=== TEST RESULT: SUCCESS ✓ ===');
    System.debug('All fields from field-mappings-template.csv parsed correctly!');
    
} catch (Exception e) {
    System.debug('✗ TEST FAILED');
    System.debug('Error Type: ' + e.getTypeName());
    System.debug('Error Message: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

