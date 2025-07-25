/**
* @File Name : SAPInvoicePaymentAPITest.cls
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
public class SAPInvoicePaymentAPITest {
    @isTest
    static void testCaptureInvoice_Success() {
        ServiceContractTriggerHandler.TriggerDisabled = true;
        
        
           ServiceContract contract = new ServiceContract(Name = 'Test Contract',SAP_Contract_Number__c = '12345');
        insert contract;
        
        // Step 1: Prepare a mock request body
        String requestBody = '{ "paymentDetails": [ ' +
            '{ ' +
            '"amc_Contract_Number": "12345", ' +
            '"customer_Code": "CUST001", ' +
            '"invoice_Number": "INV001", ' +
            '"invoice_Date": "2024-11-19", ' +
            '"amount": "100.00", ' +
            '"document_Number": "DOC12345", ' +
            '"document_Date": "2024-11-18", ' +
            '"payment_transaction_number": "PAY12345" ' +
            '} ' +
            '] }';

        // Step 2: Set the mock request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Step 3: Mock the helper method
        Test.startTest(); 
       
        
        List<SAPInvoicePaymentResponseWrapper> responseWrappers = SAPInvoicePaymentAPI.captureInvoice();
        Test.stopTest();

        // Step 4: Assert the response
       
    }

    @isTest
    static void testCaptureInvoice_Exception() {
        // Step 1: Prepare a mock request body
        String requestBody = '{ "paymentDetails": [ ' +
            '{ ' +
            '"amc_Contract_Number": "AMC12345", ' +
            '"customer_Code": "CUST001", ' +
            '"invoice_Number": "INV001", ' +
            '"invoice_Date": "2024-11-19", ' +
            '"amount": "100.00", ' +
            '"document_Number": "DOC12345", ' +
            '"document_Date": "2024-11-18", ' +
            '"payment_transaction_number": "PAY12345" ' +
            '} ' +
            '] }';

        // Step 2: Set the mock request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Step 3: Mock the helper method to throw an exception
        Test.startTest();
      

        List<SAPInvoicePaymentResponseWrapper> responseWrappers = SAPInvoicePaymentAPI.captureInvoice();
        Test.stopTest();

        // Step 4: Assert the response
       
    }
}