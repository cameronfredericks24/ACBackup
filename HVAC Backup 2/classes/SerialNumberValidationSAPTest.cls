@isTest
public class SerialNumberValidationSAPTest {
    @isTest
    static void testMakeRequest() {
        // Setup test data
        String csrfToken = 'test-csrf-token';
        String sessionCookie = 'test-session-cookie';

        // Mock the responses
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SerialNumberValidationSAPMock());
        
        // Call the method
        HttpResponse response = SerialNumberValidationSAP.makeRequest(
            csrfToken, 
            'SDLX150150C', 
            'SDLX150150CLWN05412', 
            '2161104622', 
            sessionCookie
        );
        
        // Verify results
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
        System.debug('Response: ' + response.getBody());
        Test.stopTest();
    }
}