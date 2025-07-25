/*
@Author : Abhijeet Ojha
@CreatedDate : 15th March 2024
@Description : Capture Warehouse Details from SAP.
*/
@RestResource(urlMapping='/sap/capturewarehousemaster')
global class SAPCaptureWareHouseMasterAPI {
    
    @HttpPost
    global static List<SAPCaptureWareHouseMasterResponseWrapper> captureWarehouseMasterData(){
        // Obtain the incoming REST request and response objects.
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        // Initialize the response wrapper for the API.
        List<SAPCaptureWareHouseMasterResponseWrapper> responseWrapper = new List<SAPCaptureWareHouseMasterResponseWrapper>();
        List<SAPCaptureWareHouseMasterRequestWrapper.WareHouseDetails> warehouseDetailsList;
        try {
            // Retrieve the JSON request body from the incoming request.
            String reqBody = req.requestBody.toString();
            SAPCaptureWareHouseMasterRequestWrapper reqWrap = (SAPCaptureWareHouseMasterRequestWrapper) JSON.deserialize(reqBody, SAPCaptureWareHouseMasterRequestWrapper.class);
            warehouseDetailsList = reqWrap.warehousedetails;
            
            // Process the warehouse details in bulk
            responseWrapper = SAPCaptureWareHouseMasterHelper.createWarehousemaster(warehouseDetailsList);
        } catch(Exception e) {
            system.debug('exception--' + e.getMessage());
            // If an exception occurs, return a generic error response for all requests
            SAPCaptureWareHouseMasterResponseWrapper errorResponse = new SAPCaptureWareHouseMasterResponseWrapper();
            errorResponse.result = 'Error';
            errorResponse.message = 'An error occurred while processing locations: ' + e.getMessage();
            responseWrapper.add(errorResponse);
        }
        return responseWrapper;
    }
}