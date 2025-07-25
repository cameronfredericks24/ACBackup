@isTest
public class SAPCaptureSaleorderResponseWrapperTest {
    @isTest
    static void testSAPCaptureSaleorderResponseWrapper() {
        // Test data
        String testResult = 'Success';
        String testMessage = 'Sale order captured successfully';

        // Instantiate the wrapper class
        SAPCaptureSaleorderResponseWrapper responseWrapper = 
            new SAPCaptureSaleorderResponseWrapper(testResult, testMessage);

        // Validate the instance was created successfully
        System.assertNotEquals(responseWrapper, null, 'ResponseWrapper should not be null');
        
        // Validate the field values
        System.assertEquals(responseWrapper.result, testResult, 'Result field does not match');
        System.assertEquals(responseWrapper.message, testMessage, 'Message field does not match');
    }
}