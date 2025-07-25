public class SAPAuthorisation {
    public static String makeRequest(String modelNumber, String serialNumber, String invoiceNumber) {
        String csrfToken;
        String returnResponse = null;

        try {
            // Get SAP credentials from custom metadata
            SAP_Credential__mdt serialNumberCreds = [SELECT Id, UserName__c, Password__c FROM SAP_Credential__mdt LIMIT 1];

            // Encode the credentials for Basic Authentication
            String authHeader = serialNumberCreds.UserName__c + ':' + serialNumberCreds.Password__c;
            String encodedAuthHeader = EncodingUtil.base64Encode(Blob.valueOf(authHeader));

            system.debug('authHeader - '+ authHeader);

            // Prepare request headers
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Basic ' + encodedAuthHeader);
            headers.put('x-csrf-token', 'fetch');

            // String metadataDevName = 'Serial_Number_Auth';
            String metadataDevName = 'Serial_Number_QA_Auth';
            
            // Make the callout using HTTPCallout class
            HttpResponse res = HTTPCallout.makeCallout(metadataDevName, null, headers, null, null);

            // Handle response
            if (res.getStatusCode() == 405) {   //405 is the success status code for this API
                // Successful response, extract necessary tokens
                System.debug('Response: ' + res.getHeaderKeys());
                System.debug('code: ' + res.getStatusCode());
                System.debug('code: ' + res.getHeader('x-csrf-token'));
                System.debug('set-cookie: ' + res.getHeader('set-cookie'));

                String originalString = res.getHeader('set-cookie');

                if (res.getHeader('x-csrf-token') != null) {
                    csrfToken = res.getHeader('x-csrf-token');
                    String sessionCookie = res.getHeader('set-cookie');

                    HttpResponse response = SerialNumberValidationSAP.makeRequest(csrfToken, modelNumber, serialNumber, invoiceNumber, sessionCookie);
                    system.debug(response.getStatusCode());
                    system.debug('sap response body -- ' + response.getBody());

                    if (response.getBody() != null && response.getStatusCode() == 200)  {
                        String responseBody = response.getBody();
                            // Check if the response body is an empty array
                            if (responseBody == '[]') {
                                returnResponse = null;
                            } else {
                                returnResponse = JSON.serialize(responseBody);
                            }     
                   }
                    else{
                        returnResponse = null;
                    }
                }
            } 
            else if(res.getStatusCode() == 408 || res.getStatusCode() == 503){

                System.debug('read timed out: ' + res.getStatusCode());

                returnResponse = 'Read timed out';

                API_Log__c apiResponse = new API_Log__c();
                apiResponse.Response_Body__c = res.getBody();
                apiResponse.Response_Status_Code__c = '408';
                apiResponse.Request_Body__c = modelNumber + '-' + serialNumber + '-' + invoiceNumber;
                apiResponse.Class_Name__c = 'SAPAuthorisation';
                apiResponse.Method_Name__c= 'makeRequest';
                
                INSERT apiResponse;


            }
            else {
                // Handle error response
                System.debug('Error Response: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            // Handle exceptions
            System.debug('Error: ' + e.getMessage());
            System.debug('line number: ' + e.getLineNumber());

        }

         system.debug('returnResponse - ' + returnResponse);


        return returnResponse;
    }
}