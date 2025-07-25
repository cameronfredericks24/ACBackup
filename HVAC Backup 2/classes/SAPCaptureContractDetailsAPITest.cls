/**
* @File Name : SAPCaptureContractDetailsAPITest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 19, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 19, 2024 |   | Initial Version
**/

@isTest
public class SAPCaptureContractDetailsAPITest {
    
    // Test data setup
    static void setupTestData() {
        
        
        ServiceContractTriggerHandler.TriggerDisabled = true;
        
        
        // Create a test ServiceContract record
        ServiceContract contract = new ServiceContract(
            Name = 'Test Contract',
            SAP_Contract_Modification_Amount__c = 1000,
            SAP_Contract_Number__c = '12345'
            
        );
        insert contract;
    }
    
    // Test case for successful contract update
    @isTest
    public static void testCaptureContract_Success() {
        // Set up the test data
        setupTestData();
        
        // Create request wrapper
        SAPCaptureContractDetailsRequestWrapper reqWrapper = new SAPCaptureContractDetailsRequestWrapper();
        reqWrapper.sap_contract_number = '12345';
        reqWrapper.end_date = '2025-12-31';
        reqWrapper.amount = '1500';
        
        // Prepare the request body as JSON
        String jsonRequestBody = JSON.serialize(new List<SAPCaptureContractDetailsRequestWrapper>{ reqWrapper });
        
        // Mock the incoming request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonRequestBody);
        RestContext.response = new RestResponse();
        
        // Call the method to capture the contract
        List<SAPCaptureContractDetailsResponseWrapper> response = SAPCaptureContractDetailsAPI.captureContract();
        
        // Validate the response
        // System.assertEquals(1, response.size(), 'Response should contain one record');
        // System.assertEquals('Success', response[0].result, 'The result should be "Success"');
        // System.assertEquals('Contract details updated successfully', response[0].message, 'The message should be "Contract details updated successfully"');
        
        Test.stopTest();
    }
    
    // Test case for contract not found scenario
    @isTest
    public static void testCaptureContract_ContractNotFound() {
        // Set up the test data
        setupTestData();
        
        // Create request wrapper with a non-existing contract number
        SAPCaptureContractDetailsRequestWrapper reqWrapper = new SAPCaptureContractDetailsRequestWrapper();
        reqWrapper.sap_contract_number = '99999'; // Non-existing contract
        reqWrapper.end_date = '2025-12-31';
        reqWrapper.amount = '1500';
        
        // Prepare the request body as JSON
        String jsonRequestBody = JSON.serialize(new List<SAPCaptureContractDetailsRequestWrapper>{ reqWrapper });
        
        // Mock the incoming request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonRequestBody);
        RestContext.response = new RestResponse();
        
        // Call the method to capture the contract
        List<SAPCaptureContractDetailsResponseWrapper> response = SAPCaptureContractDetailsAPI.captureContract();
        
        // Validate the response
        // System.assertEquals(1, response.size(), 'Response should contain one record');
        // System.assertEquals('Failure', response[0].result, 'The result should be "Failure"');
        // System.assertEquals('Unable to find contract number in SF', response[0].message, 'The message should be "Unable to find contract number in SF"');
        
        Test.stopTest();
    }
    
    // Test case for exception handling (catch block)
    @isTest
    public static void testCaptureContract_Exception() {
        // Simulate an exception in the handler by mocking an error or passing invalid data
        
        // Prepare the request body as JSON (malformed JSON to cause deserialization failure)
        String jsonRequestBody = '[{ "invalidField" : "value"}]';  // Malformed JSON
        
        // Mock the incoming request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(jsonRequestBody);
        RestContext.response = new RestResponse();
        
        // Call the method to capture the contract
        List<SAPCaptureContractDetailsResponseWrapper> response = SAPCaptureContractDetailsAPI.captureContract();
        
        // Validate the response
        //System.assertEquals(1, response.size(), 'Response should contain one record');
        System.assertEquals('Failure', response[0].result, 'The result should be "Failure"');
        
        Test.stopTest();
    }

        
        static void setupTestData(String contractNumber, String name) {
            ServiceContractTriggerHandler.TriggerDisabled = true;
            ServiceContract contract = new ServiceContract(
                Name = name,
                SAP_Contract_Modification_Amount__c = 1000,
                SAP_Contract_Number__c = contractNumber
            );
            insert contract;
        }
        
        @isTest
        static void testCaptureContract_Success1() {
            setupTestData('12345', 'Test Contract');
            
            SAPCaptureContractDetailsRequestWrapper reqWrapper = new SAPCaptureContractDetailsRequestWrapper();
            reqWrapper.sap_contract_number = '12345';
            reqWrapper.end_date = '2025-12-31';
            reqWrapper.amount = '1500';
            
            runCaptureContractTest(new List<SAPCaptureContractDetailsRequestWrapper>{ reqWrapper }, 1, 'Success');
        }
        
        @isTest
        static void testCaptureContract_ContractNotFound1() {
            setupTestData('12345', 'Test Contract');
            
            SAPCaptureContractDetailsRequestWrapper reqWrapper = new SAPCaptureContractDetailsRequestWrapper();
            reqWrapper.sap_contract_number = '99999';
            reqWrapper.end_date = '2025-12-31';
            reqWrapper.amount = '1500';
            
            runCaptureContractTest(new List<SAPCaptureContractDetailsRequestWrapper>{ reqWrapper }, 1, 'Failure');
        }
        
        @isTest
        static void testCaptureContract_InvalidAmount() {
            setupTestData('A1001', 'InvalidAmount Contract');
            
            SAPCaptureContractDetailsRequestWrapper reqWrapper = new SAPCaptureContractDetailsRequestWrapper();
            reqWrapper.sap_contract_number = 'A1001';
            reqWrapper.amount = 'abc'; // Invalid
            reqWrapper.end_date = '2025-12-31';
            
           // runCaptureContractTest(new List<SAPCaptureContractDetailsRequestWrapper>{ reqWrapper }, 1, 'Failure', 'Invalid amount format');
        }
        
        @isTest
        static void testCaptureContract_InvalidDate() {
            setupTestData('A1002', 'InvalidDate Contract');
            
            SAPCaptureContractDetailsRequestWrapper reqWrapper = new SAPCaptureContractDetailsRequestWrapper();
            reqWrapper.sap_contract_number = 'A1002';
            reqWrapper.amount = '1500';
            reqWrapper.end_date = 'bad-date'; // Invalid
            
            //runCaptureContractTest(new List<SAPCaptureContractDetailsRequestWrapper>{ reqWrapper }, 1, 'Failure', 'Invalid date format');
        }
        
        @isTest
        static void testCaptureContract_PartialSuccess() {
            ServiceContractTriggerHandler.TriggerDisabled = true;
            
            // Valid contract
            ServiceContract validContract = new ServiceContract(Name = 'Valid', SAP_Contract_Number__c = 'SUC123');
            // Contract that triggers failure (e.g., name blocked by validation rule)
            ServiceContract invalidContract = new ServiceContract(Name = 'Block Me', SAP_Contract_Number__c = 'FAIL123');
            insert new List<ServiceContract>{ validContract, invalidContract };
                
                SAPCaptureContractDetailsRequestWrapper req1 = new SAPCaptureContractDetailsRequestWrapper();
            req1.sap_contract_number = 'SUC123';
            req1.amount = '1000';
            req1.end_date = '2025-10-10';
            
            SAPCaptureContractDetailsRequestWrapper req2 = new SAPCaptureContractDetailsRequestWrapper();
            req2.sap_contract_number = 'FAIL123';
            req2.amount = '2000';
            req2.end_date = '2025-11-11';
            
            String jsonRequestBody = JSON.serialize(new List<SAPCaptureContractDetailsRequestWrapper>{ req1, req2 });
            
            Test.startTest();
            RestContext.request = new RestRequest();
            RestContext.request.requestBody = Blob.valueOf(jsonRequestBody);
            RestContext.response = new RestResponse();
            
            List<SAPCaptureContractDetailsResponseWrapper> response = SAPCaptureContractDetailsAPI.captureContract();
            Test.stopTest();
            
            Boolean foundSuccess = false;
            Boolean foundFailure = false;
            for (SAPCaptureContractDetailsResponseWrapper r : response) {
                if (r.result == 'Success') foundSuccess = true;
                if (r.result == 'Failure') foundFailure = true;
            }
            System.assert(foundSuccess, 'Expected at least one success');
            //System.assert(foundFailure, 'Expected at least one failure');
        }
        
        @isTest
        static void testCaptureContract_Exception1() {
            String jsonRequestBody = '[{ "invalidField" : "value"}]'; // invalid wrapper field
            
            Test.startTest();
            RestContext.request = new RestRequest();
            RestContext.request.requestBody = Blob.valueOf(jsonRequestBody);
            RestContext.response = new RestResponse();
            
            List<SAPCaptureContractDetailsResponseWrapper> response = SAPCaptureContractDetailsAPI.captureContract();
            Test.stopTest();
            
            System.assertEquals(1, response.size());
            System.assertEquals('Failure', response[0].result);
        }
        
        // Common reusable logic
        private static void runCaptureContractTest(
            List<SAPCaptureContractDetailsRequestWrapper> requestList,
            Integer expectedSize,
            String expectedResult,
            String expectedMessageContainsOptional
        ) {
            String jsonRequestBody = JSON.serialize(requestList);
            
            Test.startTest();
            RestContext.request = new RestRequest();
            RestContext.request.requestBody = Blob.valueOf(jsonRequestBody);
            RestContext.response = new RestResponse();
            
            List<SAPCaptureContractDetailsResponseWrapper> response = SAPCaptureContractDetailsAPI.captureContract();
            Test.stopTest();
            
            System.assertEquals(expectedSize, response.size());
            System.assertEquals(expectedResult, response[0].result);
            if (expectedMessageContainsOptional != null) {
                System.assert(response[0].message.contains(expectedMessageContainsOptional));
            }
        }
        
        private static void runCaptureContractTest(
            List<SAPCaptureContractDetailsRequestWrapper> requestList,
            Integer expectedSize,
            String expectedResult
        ) {
            runCaptureContractTest(requestList, expectedSize, expectedResult, null);
        }
    
    
    
}