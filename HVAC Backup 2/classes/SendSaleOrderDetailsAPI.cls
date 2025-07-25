public without sharing class SendSaleOrderDetailsAPI {
    // Org Constants for hard code value
    public static final String salesOrderTypeMD = UtilityClass.getOrgConstantValue('SalesOrderType');
    public static final String salesOrganizationMD = UtilityClass.getOrgConstantValue('SalesOrganization');
    public static final String distributionChannelMD = UtilityClass.getOrgConstantValue('DistributionChannel');
    public static final String purchaseOrderByCustomerMD = UtilityClass.getOrgConstantValue('PurchaseOrderByCustomer');
    public static final String customerPurchaseOrderTypeMD = UtilityClass.getOrgConstantValue('CustomerPurchaseOrderType');
    public static final String transactionCurrencyMD = UtilityClass.getOrgConstantValue('TransactionCurrency');
    public static final String customerPaymentTermsMD = UtilityClass.getOrgConstantValue('CustomerPaymentTerms');
    public static final String usageMD = UtilityClass.getOrgConstantValue('Usage');
    public static final String partnerFunctionAGMD = UtilityClass.getOrgConstantValue('PartnerFunctionAG');
    public static final String partnerFunctionWEMD = UtilityClass.getOrgConstantValue('PartnerFunctionWE');
    public static final String partnerFunctionZAMD = UtilityClass.getOrgConstantValue('PartnerFunctionZA');
    public static final String partnerFunctionZRMD = UtilityClass.getOrgConstantValue('PartnerFunctionZR');
    public static final String partnerFunctionZBMD = UtilityClass.getOrgConstantValue('PartnerFunctionZB');
    public static final String conditionTypeMD = UtilityClass.getOrgConstantValue('ConditionType');
    public static final String conditionCurrencyMD = UtilityClass.getOrgConstantValue('ConditionCurrency');
    public static final String shippingPointMD = UtilityClass.getOrgConstantValue('ShippingPoint');
    public static final String routeMD = UtilityClass.getOrgConstantValue('Route');
    
    
    // Retrieving Record Type ID for Channel Partner Account Type
    public static final Id saleOrderRecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Sale_Order').getRecordTypeId();
    
    public static SAPSaleOrderWrapper saleOrderData(Id partRequestId) {
        
        set<Id> branchDivisionIdLst = new set<Id>();
        
        // Query the Part Request
        ProductRequest partRequest = [
            SELECT Id, CreatedDate, Branch__r.Branch_Code__c, DestinationLocation.Warehouse_Code__c, ProductRequestNumber,
                CP__r.CP_Code__c, SDE__r.Employee_Number__c, Account.SAP_Customer_Id__c,CP__r.CP_User__r.Employee_Number__c,CP__r.Customer_Code__c,WorkOrderId,WorkOrder.Department__c,WorkOrder.Department__r.Department_Number__c,
                WorkOrder.Branchh__c,WorkOrder.Branchh__r.Branch_Code__c
            FROM ProductRequest
            WHERE Id = :partRequestId AND RecordTypeId = :saleOrderRecordTypeId LIMIT 1 ];
        
        // Query the related ProductRequestLineItems separately
        List<ProductRequestLineItem> partRequestLineItems = [
            SELECT Id, ProductRequestLineItemNumber, Product2.ProductCode, QuantityRequested, QuantityUnitOfMeasure , Product2.Base_Price__c
            FROM ProductRequestLineItem
            WHERE ParentId = :partRequestId
        ];
        
        // Initialize the SAPSaleOrderWrapper
        SAPSaleOrderWrapper saleOrder = new SAPSaleOrderWrapper();
        
        // Populate default values
        saleOrder.Data.Usage = usageMD; // Hardcoded
        saleOrder.Data.SalesOrderType = salesOrderTypeMD; // Hardcoded
        saleOrder.Data.SalesOrganization = salesOrganizationMD; // Hardcoded
        saleOrder.Data.DistributionChannel = distributionChannelMD; // Hardcoded
        saleOrder.Data.TransactionCurrency = transactionCurrencyMD; // Hardcoded
        saleOrder.Data.CustomerPaymentTerms = customerPaymentTermsMD; // Example: Based on your provided values
        saleOrder.Data.PurchaseOrderByCustomer = partRequest.ProductRequestNumber; // Example Free Text
        saleOrder.Data.CustomerPurchaseOrderType = customerPurchaseOrderTypeMD; // Hardcoded
        
        
        // Retrieve Organization Division based on Branch Code and SDE Code
        list<Branch_Division__c> branchDept = [
            SELECT Id, Department__r.Department_Number__c FROM Branch_Division__c
            WHERE Branch__r.Branch_Code__c  = :partRequest.Branch__r.Branch_Code__c
            AND Service_SDE__r.Employee_Number__c =:partRequest.SDE__r.Employee_Number__c
            LIMIT 1
        ];
        
        
        String branchCode;
        String serviceDepartmentNumber;
        
        
        if(partRequest.WorkOrderId != null){
            saleOrder.Data.OrganizationDivision = partRequest.WorkOrder.Department__r.Department_Number__c;
            saleOrder.Data.SalesOffice = partRequest.WorkOrder.Branchh__r.Branch_Code__c;
            branchCode = partRequest.WorkOrder.Branchh__r.Branch_Code__c;
            serviceDepartmentNumber = partRequest.WorkOrder.Department__r.Department_Number__c;
            
        }
        else if(!branchDept.isEmpty()) {
            saleOrder.Data.OrganizationDivision = branchDept[0].Department__r.Department_Number__c;
            saleOrder.Data.SalesOffice = partRequest.Branch__r.Branch_Code__c;
            branchCode = partRequest.Branch__r.Branch_Code__c;
            serviceDepartmentNumber = branchDept[0].Department__r.Department_Number__c;
            
        }
        
        system.debug('branchCode--<'+branchCode);
        system.debug('serviceDepartmentNumber--<'+serviceDepartmentNumber);
        
        if (partRequest.CreatedDate != null) {
            saleOrder.Data.CustomerPurchaseOrderDate = partRequest.CreatedDate.format('yyyyMMdd');
        }
        
        // Populate Header Partners with null/blank checks
        saleOrder.Data.Header_Partners = new SAPSaleOrderWrapper.HeaderPartnersWrapper();
        
        if (partRequest.CP__r.Customer_Code__c != null && partRequest.CP__r.Customer_Code__c != '') {
            
            saleOrder.Data.Header_Partners.addPartner(partnerFunctionAGMD, partRequest.CP__r.Customer_Code__c);
            saleOrder.Data.Header_Partners.addPartner(partnerFunctionWEMD, partRequest.CP__r.Customer_Code__c);
            
        }
        
        if (partRequest.CP__r.CP_User__r.Employee_Number__c != null && partRequest.CP__r.CP_User__r.Employee_Number__c != '') {
            saleOrder.Data.Header_Partners.addPartner(partnerFunctionZAMD, partRequest.CP__r.CP_User__r.Employee_Number__c);
            saleOrder.Data.Header_Partners.addPartner(partnerFunctionZBMD, partRequest.CP__r.CP_User__r.Employee_Number__c);
        }
        
        if (partRequest.SDE__r.Employee_Number__c != null && partRequest.SDE__r.Employee_Number__c != '') {
            // Remove the first letter 'E' from Employee_Number__c
            String modifiedEmployeeNumber = partRequest.SDE__r.Employee_Number__c.substring(1);
            saleOrder.Data.Header_Partners.addPartner(partnerFunctionZRMD, modifiedEmployeeNumber);
        }
        
        // Populate Line Items with null/blank checks
        
        list<Department_ESA_SDE_SDH__c> deptEsaSdeLst = [SELECT ID,Channel_Partner__c,Department__r.Department_Number__c,Preferred_Location__r.Warehouse_Code__c,Preferred_Location__r.ParentLocation.Warehouse_Code__c,Branch__c,branch__r.Branch_Code__c
                                                        FROM Department_ESA_SDE_SDH__c 
                                                        WHERE Department__r.Department_Number__c =:serviceDepartmentNumber 
                                                        AND Channel_Partner__c =: partRequest.CP__c AND Branch__r.Branch_Code__c =:branchCode];
        
        system.debug('deptEsaSdeLst-- '+ deptEsaSdeLst);
        String deptDivPlantCode;
        String deptDivPhysicalWarehouse;
        
        list<Branch_Division__c> branchDivisionLst = [SELECT id,Service_SDE__r.EmployeeNumber,Service_SDE__r.Employee_Number__c,Department__r.Department_Number__c 
                                                        FROM Branch_Division__c 
                                                        WHERE Branch_Code__c =:branchCode
                                                        AND Department__r.Department_Number__c=: serviceDepartmentNumber ];
        
        if(!branchDivisionLst.isEmpty()){
            for(Branch_Division__c brdiv:branchDivisionLst){
                branchDivisionIdLst.add(brdiv.Id);
            }
        }
        
        system.debug('branchDivisionIdLst -- '+ branchDivisionIdLst);
        
        
        
        if(!branchDivisionLst.isEmpty()) {
            
            list<Associated_Warehouse__c> associatedWarehouseLst = [select Id,Warehouse_Code__c from Associated_Warehouse__c where Branch_Department__c IN: branchDivisionIdLst];
            
            system.debug('associatedWarehouseLst -- '+ associatedWarehouseLst);
            
            if(associatedWarehouseLst.size() > 0) {
                deptDivPlantCode = associatedWarehouseLst[0].Warehouse_Code__c;
            }
        }
        
        system.debug('deptDivPlantCode-- '+ deptDivPlantCode);
        
        
        if(deptDivPlantCode != null || deptDivPlantCode != ''){
            list<Schema.Location> locationList = [SELECT Id, Name, Warehouse_Code__c, ParentLocation.Warehouse_Code__c FROM Location WHERE Warehouse_Code__c =: deptDivPlantCode];
            
            system.debug('locationList-- '+ locationList);
            
            
            if(locationList.size() > 0) {
                deptDivPhysicalWarehouse = locationList[0].ParentLocation.Warehouse_Code__c;
            }
        }
        
        saleOrder.Data.Line_Items = new SAPSaleOrderWrapper.LineItemsWrapper();
        
        for (ProductRequestLineItem lineItem : partRequestLineItems) {
            String ProductionPlant;
            String pricingProcedureStepMD;
            String conditionRateValueMD;
            String firstCharacter ='';
            String storageLocation = 'S';
            if (lineItem.Product2.ProductCode != null && lineItem.Product2.ProductCode != '') {
                String fullItemNumber = lineItem.ProductRequestLineItemNumber;
                String salesOrderItem = fullItemNumber != null && fullItemNumber.contains('-') ? fullItemNumber.split('-')[1] : '';
                if(lineItem.QuantityUnitOfMeasure != null || lineItem.QuantityUnitOfMeasure != ''){
                    firstCharacter = (lineItem.QuantityUnitOfMeasure).substring(0,2).toUpperCase();
                }
                if(!branchDept.isEmpty()){
                    
                    if(branchDept[0].Department__r.Department_Number__c != null || branchDept[0].Department__r.Department_Number__c != ''){
                        storageLocation = 'S' + branchDept[0].Department__r.Department_Number__c;
                    }
                    
                }
                else if(partRequest.WorkOrder.Department__c != null){
                    storageLocation =  'S' + partRequest.WorkOrder.Department__r.Department_Number__c ;
                }
                
                //get production plant
                
                if(!deptEsaSdeLst.isEmpty()){
                    ProductionPlant = deptEsaSdeLst[0].Preferred_Location__r.ParentLocation.Warehouse_Code__c;
                }
                else{
                    ProductionPlant = deptDivPhysicalWarehouse;
                    
                }
                
                // Example assignments if custom fields are available
                if (lineItem.Product2.Base_Price__c != null) {
                    conditionRateValueMD = String.valueOf(lineItem.Product2.Base_Price__c);
                }
                
                if (fullItemNumber != null) {
                    pricingProcedureStepMD =  fullItemNumber != null && fullItemNumber.contains('-') ? fullItemNumber.split('-')[1] : '';
                    
                }
                
                // Add line items directly
                saleOrder.Data.Line_Items.addItem(
                    salesOrderItem,
                lineItem.Product2.ProductCode,
                String.valueOf(lineItem.QuantityRequested),
                firstCharacter,
                ProductionPlant,
                storageLocation != null ? storageLocation : '',
                null, // Hardcoded
                routeMD, // Example, not confirmed
                new List<SAPSaleOrderWrapper.PriceListWrapper>{
                    new SAPSaleOrderWrapper.PriceListWrapper(pricingProcedureStepMD, conditionTypeMD, conditionRateValueMD, conditionCurrencyMD)// Hardcoded
                }
                );
            }
        }
        
        // DEBUG: Log line items to ensure they are added correctly
        System.debug('Line Items: ' + JSON.serialize(saleOrder.Data.Line_Items.Items_List));
        
        return saleOrder;
    }
    // Method to send SaleOrder details to SAP via HTTP POST request
    @future(callout=true)
    public static void sendSaleOrder(Id partRequestId) {
        try {
            SAPSaleOrderWrapper saleOrderWrapper = saleOrderData(partRequestId);
            String requestBody = JSON.serialize(saleOrderWrapper);
            
            // DEBUG: Log request body to verify all line items
            System.debug('Request Body: ' + requestBody);
            
            // Get SAP credentials from custom metadata
            SAP_Credential__mdt serialNumberCreds = [SELECT Id, UserName__c, Password__c FROM SAP_Credential__mdt LIMIT 1];
            
            // Encode the credentials for Basic Authentication
            String authHeader = serialNumberCreds.UserName__c + ':' + serialNumberCreds.Password__c;
            String encodedAuthHeader = EncodingUtil.base64Encode(Blob.valueOf(authHeader));
            
            // Prepare request headers
            Map<String, String> authHeaders = new Map<String, String>();
            authHeaders.put('Authorization', 'Basic ' + encodedAuthHeader);
            authHeaders.put('x-csrf-token', 'fetch');
            
            // Metadata details
            String metadataDevName = 'Send_Saleorder_Details_API';
            
            HttpResponse response = makeCallout(metadataDevName, null, authHeaders, requestBody, null, partRequestId);
            
            System.debug('response--<'+response);
            
            
            // Make the initial callout to fetch CSRF token and session cookies
            // HttpResponse res = makeCallout(metadataDevName, null, authHeaders, null, null, partRequestId);
            // System.debug('Res--<'+res);
            
            // Handle response
            if (response.getStatusCode() == 200) { // Assuming 405 is the success status code for this API
                
                // Log API response
                API_Log__c apiResponse = new API_Log__c();
                apiResponse.Response_Body__c = response.getBody();
                apiResponse.Response_Status_Code__c = String.valueOf(response.getStatusCode());
                apiResponse.Request_Body__c = String.valueOf(requestBody);
                apiResponse.Class_Name__c = 'SendSaleOrderDetailsAPI';
                apiResponse.Part_Request__c = partRequestId;
                system.debug('insert apiResponse'+apiResponse);
                insert apiResponse;
                
                ProductRequest srequest = new ProductRequest(Id = partRequestId);
                srequest.API_Response__c = response.getBody();
                srequest.API_Response_Code__c = String.valueOf(response.getStatusCode());
                
                // Parse the response body
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                
                // Check SUCCESS key and update status if conditions are met
                if (responseMap.containsKey('SUCCESS') && String.valueOf(responseMap.get('SUCCESS')) == '0') {
                    System.debug('inside if');
                    
                    srequest.Status = 'Draft';
                    System.debug('Setting ProductRequest status to Draft due to null SALESORDER and SUCCESS = 0');
                } else {
                    if (responseMap.containsKey('SALESORDER') && (responseMap.get('SALESORDER') != null || responseMap.get('SALESORDER') != '' )) {
                        
                        System.debug('inside else');
                        
                        String salesOrder = (String) responseMap.get('SALESORDER');
                        srequest.SAP_Saleorder_Number__c = salesOrder;
                        srequest.Status = 'Submitted';
                        
                        System.debug('SALESORDER Value: ' + salesOrder);
                    }
                    System.debug('SALESORDER is null, but SUCCESS is not 0');
                }
                
                
                update srequest;
                
                
                
                
                
            } else {
                
                System.debug('Error Response: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred in sendSaleOrder: ' + e.getMessage());
            System.debug('line num ' + e.getLineNumber());
        }
    }
    
    public static HttpResponse makeCallout(String metadataName,String endPoint, Map<String, String> headers, String requestBody, Map<String, String> urlParams, Id partRequestId) {
        String endPointURL;
        HttpResponse response = null;
        
        Integer timeout = 120000;
        
        try{
            
            System.debug('Request Body 2: ' + requestBody);
            
            // Query the custom metadata records based on the httpConfigName
            Callout_Configuration__mdt config = [SELECT Endpoint__c, Method__c, RequestBody__c, Headers__c, URLParameters__c
        FROM Callout_Configuration__mdt
        WHERE DeveloperName = :metadataName
        LIMIT 1];
            
            if(endPoint!=null){
                
                endPointURL = endPoint;
            }
            else{
                endPointURL = config.Endpoint__c;
            }
            String method = config.Method__c;
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPointURL);
            
            // Setting method
            request.setMethod(method);
            
            System.debug('headers: ' + headers);
            
            
            // Setting headers
            if (headers != null && !headers.isEmpty()) {
                for (String key : headers.keySet()) {
                    request.setHeader(key, headers.get(key));
                }
            }
            
            system.debug('requestBody 1 - '+ requestBody);
            
            // Setting request body
            if (requestBody != null) {
                request.setBody(requestBody);
                system.debug('requestBody - '+ requestBody);
                system.debug('requestBody string- '+ JSON.serialize(requestBody));
            }
            
            // Setting URL parameters
            if (urlParams != null && !urlParams.isEmpty()) {
                String queryString = '';
                for (String key : urlParams.keySet()) {
                    if (queryString!=null) {
                        queryString += '&';
                    }
                    queryString += EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(urlParams.get(key), 'UTF-8');
                }
                system.debug('endpoint - '+ endPointURL + '?' + queryString );
                request.setEndpoint(endPointURL + '?' + queryString);
            }
            
            
            request.setTimeout(timeout);
            
            system.debug('request - '+ request);
            system.debug('request body - '+ request.getBody());
            system.debug('request method - '+ request.getMethod());
            
            
            // Making the callout
            Http http = new Http();
            response = http.send(request);
            
            system.debug(response.getStatusCode());
            system.debug(response.getBody());
            
            //    // Log API response
            //     API_Log__c apiResponse = new API_Log__c();
            //     apiResponse.Response_Body__c = response.getBody();
            //     apiResponse.Response_Status_Code__c = String.valueOf(response.getStatusCode());
            //     apiResponse.Request_Body__c = JSON.serialize(requestBody);
            //     apiResponse.Class_Name__c = 'SendSaleOrderDetailsAPI';
            //     apiResponse.Method_Name__c= 'sendSaleOrder';
            
            
            //     system.debug('insert apiResponse'+apiResponse);
            //     insert apiResponse;
            
            //     ProductRequest srequest = new ProductRequest(Id = partRequestId);
            //     srequest.API_Response__c = response.getBody();
            //     srequest.API_Response_Code__c = String.valueOf(response.getStatusCode());
            //     // Parse the response body to extract the SALESORDER value
            // Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // if (responseMap.containsKey('SALESORDER')) {
                //     String salesOrder = (String) responseMap.get('SALESORDER');
                //     srequest.SAP_MR_Number__c = salesOrder;
                //     System.debug('SALESORDER Value: ' + salesOrder);
            // } else {
                //     System.debug('SALESORDER key not found in the response');
            // }
            //     update srequest;
            
            
        }
        catch(Exception e){
            // Handle exceptions
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            
        }
        return response;
    }
    
    // Method to send SaleOrder details to SAP via HTTP POST request
    @AuraEnabled
    public static void sendSaleOrderQuickAction(Id partRequestId) {
        try {
            SAPSaleOrderWrapper saleOrderWrapper = saleOrderData(partRequestId);
            String requestBody = JSON.serialize(saleOrderWrapper);
            
            // DEBUG: Log request body to verify all line items
            System.debug('Request Body: ' + requestBody);
            
            // Get SAP credentials from custom metadata
            SAP_Credential__mdt serialNumberCreds = [SELECT Id, UserName__c, Password__c FROM SAP_Credential__mdt LIMIT 1];
            
            // Encode the credentials for Basic Authentication
            String authHeader = serialNumberCreds.UserName__c + ':' + serialNumberCreds.Password__c;
            String encodedAuthHeader = EncodingUtil.base64Encode(Blob.valueOf(authHeader));
            
            // Prepare request headers
            Map<String, String> authHeaders = new Map<String, String>();
            authHeaders.put('Authorization', 'Basic ' + encodedAuthHeader);
            authHeaders.put('x-csrf-token', 'fetch');
            
            // Metadata details
            String metadataDevName = 'Send_Saleorder_Details_API';
            
            HttpResponse response = makeCallout(metadataDevName, null, authHeaders, requestBody, null, partRequestId);
            
            System.debug('response--<'+response);
            
            
            // Make the initial callout to fetch CSRF token and session cookies
            // HttpResponse res = makeCallout(metadataDevName, null, authHeaders, null, null, partRequestId);
            // System.debug('Res--<'+res);
            
            // Handle response
            if (response.getStatusCode() == 200) { // Assuming 405 is the success status code for this API
                
                // Log API response
                API_Log__c apiResponse = new API_Log__c();
                apiResponse.Response_Body__c = response.getBody();
                apiResponse.Response_Status_Code__c = String.valueOf(response.getStatusCode());
                apiResponse.Request_Body__c = String.valueOf(requestBody);
                apiResponse.Class_Name__c = 'SendSaleOrderDetailsAPI';
                apiResponse.Part_Request__c = partRequestId;
                system.debug('insert apiResponse'+apiResponse);
                insert apiResponse;
                
                ProductRequest srequest = new ProductRequest(Id = partRequestId);
                srequest.API_Response__c = response.getBody();
                srequest.API_Response_Code__c = String.valueOf(response.getStatusCode());
                
                // Parse the response body
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                // Check SUCCESS key and update status if conditions are met
                if (responseMap.containsKey('SUCCESS') && String.valueOf(responseMap.get('SUCCESS')) == '0') {
                    System.debug('inside if');
                    
                    srequest.Status = 'Draft';
                    System.debug('Setting ProductRequest status to Draft due to null SALESORDER and SUCCESS = 0');
                } else {
                    if (responseMap.containsKey('SALESORDER') && (responseMap.get('SALESORDER') != null || responseMap.get('SALESORDER') != '' )) {
                        
                        System.debug('inside else');
                        
                        String salesOrder = (String) responseMap.get('SALESORDER');
                        srequest.SAP_Saleorder_Number__c = salesOrder;
                        srequest.Status = 'Submitted';
                        
                        System.debug('SALESORDER Value: ' + salesOrder);
                    }
                    System.debug('SALESORDER is null, but SUCCESS is not 0');
                }
                
                
                update srequest;
                
                
                
                
                
            } else {
                
                System.debug('Error Response: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred in sendSaleOrder: ' + e.getMessage());
            System.debug('line num ' + e.getLineNumber());
        }
    }
    
}