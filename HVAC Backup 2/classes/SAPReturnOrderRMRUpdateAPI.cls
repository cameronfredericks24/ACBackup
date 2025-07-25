/*
@Author : Abhijeet Ojha
@CreatedDate : 14th March 2024
@Description : Sync the Return Order status from SAP
*/
@RestResource(urlMapping='/sap/returnorderstatus')
global class SAPReturnOrderRMRUpdateAPI {
    @HttpPost
    global static List<SAPReturnOrderRMRUpdateResponseWrapper> syncStatus() {
        // Obtain the incoming REST request and response objects.
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Initialize the list of response wrappers for the API.
        List<SAPReturnOrderRMRUpdateResponseWrapper> responses = new List<SAPReturnOrderRMRUpdateResponseWrapper>();

        try {
            // Retrieve the JSON request body from the incoming request.
            String jsonReqBody = req.requestBody.toString();

            // Deserialize the JSON request body into a list of request wrappers.
            List<SAPReturnOrderRMRUpdateRequestWrapper> reqWraps = (List<SAPReturnOrderRMRUpdateRequestWrapper>)JSON.deserialize(jsonReqBody, List<SAPReturnOrderRMRUpdateRequestWrapper>.class);

            // Process the requests in bulk
            responses = SAPReturnOrderRMRUpdateHelper.synchronizeReturnOrderStatusInBulk(reqWraps);
        } catch (Exception e) {
            SAPReturnOrderRMRUpdateResponseWrapper response = new SAPReturnOrderRMRUpdateResponseWrapper();
            System.debug('Exception: ' + e.getMessage());
            response.result = SAPReturnOrderRMRUpdateHelper.ERROR_RESPONSE_RESULT;
            response.message = SAPReturnOrderRMRUpdateHelper.ERROR_RESPONSE_MESSAGE;
            responses.add(response);
        }
        return responses;
    }
}