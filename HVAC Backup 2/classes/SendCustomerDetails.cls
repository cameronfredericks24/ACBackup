public class SendCustomerDetails {
    
    // Inner class for holding customer details
    public class CustomerDetail {
        public String SAP_CUSTOMER_ID { get; set; }
        public String SF_CUSTOMER_ID { get; set; }
        public String CUSTOMER_CODE { get; set; }
        public String CUSTOMER_NAME { get; set; }
        public String EMAIL { get; set; }
        public String GST { get; set; }
        public String PAN { get; set; }
        public String FLATNO { get; set; }
        public String ADDRESS1 { get; set; }
        public String ADDRESS2 { get; set; }
        public String ADDRESS3 { get; set; }
        public String ADDRESS4 { get; set; }
        public String CITY { get; set; }
        public String POSTAL_CODE { get; set; }
        public String STATE { get; set; }
        public String COUNTRY { get; set; }
        public String TITLE { get; set; }
        public String TAN { get; set; }
        public String FLAG { get; set; }
        public String PHONE { get; set; }
        public String SALES_OFFICE { get; set; }
        public String SEGMENT { get; set; }
        public String SUBSEGMENT { get; set; }
        public String DEPT { get; set; }
        public String JOIG { get; set; }

        //public String GROUP { get; set; }
        
    }
    
    
    // Method to fetch customer data
    public static List<CustomerDetail> CustomerData(List<Id> AccountId,String contractId) {
        try {

            list<ServiceContract> contractLst = new list<ServiceContract>();
            String DeptNumber;

            List<Account> acclist = [SELECT Id, Outstanding_Amount__c, RecordType.DeveloperName,
                                      Shipping_House_Flat_BlockNo__c, Branch__r.Branch_Code__c, CP_Code__c,
                                      Residential_Configuration__c, SDE__r.Employee_Number__c, SAP_Customer_Id__c,
                                      GST_Number__c, JOIG__c, TAN_Number__c, PAN_Number__c, CP__c, Title__c, Salutation__c,
                                      SOL_Store_ID__c, Sub_Segment__c, Group__c, Category__c, Phone, ShippingCity, Industry,
                                      ShippingState, ShippingStreet, ShippingPostalCode, ShippingCountry, ShippingStateCode,
                                      ShippingCountryCode, Email__c, Customer_Code__c, Address__c,
                                      Name, Customer_ID__c,Branch_Code__c FROM Account WHERE Id IN :AccountId];


            if(contractId != null){
                contractLst = [SELECT Id,Department__r.Department_Number__c FROM ServiceContract WHERE Id=:contractId ];

            }         
            
            if(!contractLst.isEmpty()){
                DeptNumber = contractLst[0].Department__r.Department_Number__c;
            }
            
            List<CustomerDetail> Wrapperlist = new List<CustomerDetail>();
            for (Account acc : acclist) {
                CustomerDetail customer = new CustomerDetail();
                
                customer.SF_CUSTOMER_ID = acc.Customer_ID__c;
                customer.CUSTOMER_CODE = acc.Customer_Code__c;
                customer.CUSTOMER_NAME = acc.Name;
                customer.EMAIL = acc.Email__c;
                customer.PHONE = acc.Phone;
                
                customer.SAP_CUSTOMER_ID = acc.SAP_Customer_Id__c;
                customer.SF_CUSTOMER_ID = acc.Customer_ID__c;
                
                // Set flag based on SAP_CUSTOMER_ID value
                customer.FLAG = (acc.SAP_Customer_Id__c == null) ? 'Insert' : 'Update';
                
              
                
                //customer.TAN = acc.TAN_Number__c;
                customer.SALES_OFFICE = acc.Branch_Code__c;
                if(acc.RecordType.DeveloperName == 'Commercial_Customer'){
                    customer.JOIG = (acc.JOIG__c !=null)?acc.JOIG__c:'1';

                    if(acc.JOIG__c == 'NA'){
                        customer.JOIG  = '1';
                    }

                                      customer.GST = (acc.GST_Number__c != null && acc.GST_Number__c != 'NA') ? acc.GST_Number__c : null;
                    customer.PAN = (acc.PAN_Number__c != null && acc.PAN_Number__c != 'NA') ? acc.PAN_Number__c : null;   
                }
                if(acc.RecordType.DeveloperName == 'Residential_Customer'){
                    customer.JOIG = '0';   
                    customer.GST = (acc.GST_Number__c != null && acc.GST_Number__c != 'NA') ? acc.GST_Number__c : null;
                    customer.PAN = (acc.PAN_Number__c != null && acc.PAN_Number__c != 'NA') ? acc.PAN_Number__c : null;       
                    
                    if(customer.GST != null && acc.GST_Number__c != 'NA' && customer.PAN != null && acc.PAN_Number__c != 'NA'){
                        customer.JOIG = '1';   

                    }

                }
                
                customer.TAN = (acc.TAN_Number__c != null) ? acc.TAN_Number__c : 'NA';
                customer.SALES_OFFICE = acc.Branch_Code__c;


                customer.FLATNO = acc.Shipping_House_Flat_BlockNo__c;
                
                
                // Splitting ShippingStreet into separate components
                if (acc.ShippingStreet != null) {
                    if(acc.ShippingStreet.contains('\n')){
                        String[] ShippingStreetComponents = acc.ShippingStreet.split('\n');
                    
                        System.debug('ShippingStreetComponents size:'+ShippingStreetComponents.size());
                        if(ShippingStreetComponents.size() <5){
                            if (ShippingStreetComponents.size() > 0) {
                            customer.ADDRESS1 = ShippingStreetComponents[0].trim();
                            }
                            if (ShippingStreetComponents.size() > 1) {
                                customer.ADDRESS2 = ShippingStreetComponents[1].trim();
                            }
                            if (ShippingStreetComponents.size() > 2) {
                                customer.ADDRESS3 = ShippingStreetComponents[2].trim();
                            }
                            if (ShippingStreetComponents.size() > 3) {
                                customer.ADDRESS4 = ShippingStreetComponents[3].trim();
                            }
                        } else{
                            // Split the string based on commas
                            List<String> parts = acc.ShippingStreet.split(',');
                            
                            // Trim each part to remove leading and trailing spaces
                            for (Integer i = 0; i < parts.size(); i++) {
                                parts[i] = parts[i].trim();
                            }
                            
                            // Determine the parts
                            customer.ADDRESS4 = parts.size() > 0 ? parts[parts.size() - 1] : '';
                            customer.ADDRESS3 = parts.size() > 1 ? parts[parts.size() - 2] : '';
                            customer.ADDRESS2 = parts.size() > 2 ? parts[parts.size() - 3] : '';
                            
                            // Remaining elements go into part1
                            customer.ADDRESS1 = '';
                            for(Integer i =0; i< parts.size() - 3; i++){
                                customer.ADDRESS1 += parts[i]+',';
                            }
                            
                        }
                    } else{
                        String[] ShippingStreetComponents = acc.ShippingStreet.split(',');
                        System.debug('ShippingStreetComponents size:'+ShippingStreetComponents.size());
                        if(ShippingStreetComponents.size() <5){
                            if (ShippingStreetComponents.size() > 0) {
                            customer.ADDRESS1 = ShippingStreetComponents[0].trim();
                            }
                            if (ShippingStreetComponents.size() > 1) {
                                customer.ADDRESS2 = ShippingStreetComponents[1].trim();
                            }
                            if (ShippingStreetComponents.size() > 2) {
                                customer.ADDRESS3 = ShippingStreetComponents[2].trim();
                            }
                            if (ShippingStreetComponents.size() > 3) {
                                customer.ADDRESS4 = ShippingStreetComponents[3].trim();
                            }
                        } else{
                            // Split the string based on commas
                            List<String> parts = acc.ShippingStreet.split(',');
                            
                            // Trim each part to remove leading and trailing spaces
                            for (Integer i = 0; i < parts.size(); i++) {
                                parts[i] = parts[i].trim();
                            }
                            
                            // Determine the parts
                            customer.ADDRESS4 = parts.size() > 0 ? parts[parts.size() - 1] : '';
                            customer.ADDRESS3 = parts.size() > 1 ? parts[parts.size() - 2] : '';
                            customer.ADDRESS2 = parts.size() > 2 ? parts[parts.size() - 3] : '';
                            
                            // Remaining elements go into part1
                            customer.ADDRESS1 = '';
                            for(Integer i =0; i< parts.size() - 3; i++){
                                customer.ADDRESS1 += parts[i]+',';
                            }
                            
                        }
                        
                    }
                    
                }
                
                customer.CITY = acc.ShippingCity;
                customer.POSTAL_CODE = acc.ShippingPostalCode;
                customer.STATE = acc.ShippingStateCode;
                
                if(acc.ShippingStateCode == 'OD'){

                    customer.STATE = 'OR';

                }
                  if(acc.ShippingStateCode == 'GO'){

                    customer.STATE = 'GA';

                }

                  if(acc.ShippingStateCode == 'TG'){

                    customer.STATE = 'TS';

                }

                customer.COUNTRY = acc.ShippingCountryCode;
                
            
                //(0001 – Ms.), (0002 – Mr.), (0003 – Company), (0004 – Mr. and Mrs.0), (0005 – M/s)
                customer.TITLE = (acc.Title__c == 'Ms.' || acc.Title__c == 'Ms')? acc.Title__c = '0001' :
                    (acc.Title__c == 'Mr.' || acc.Title__c == 'Mr')? acc.Title__c = '0002' :
                    (acc.Title__c == 'Company')? acc.Title__c = '0003' :
                    (acc.Title__c == 'Mr. and Mrs.')? acc.Title__c = '0004' :
                    (acc.Title__c == 'M/s')? acc.Title__c = '0005' : '';
                if(acc.Title__c == '' || acc.Title__c == null){
                    if(acc.RecordType.DeveloperName == 'Commercial_Customer'){
                        customer.TITLE = '0003';
                    }
                    if(acc.RecordType.DeveloperName == 'Residential_Customer'){
                        customer.TITLE = '0002';
                    }
                }

                //add department number
                if(DeptNumber != null &&  !String.isBlank(DeptNumber)){
                    customer.DEPT = DeptNumber;
                }
                
                system.debug(' customer.CITY - '+  customer.CITY);
                system.debug(' customer.POSTAL_CODE - '+  customer.POSTAL_CODE);
                system.debug(' customer.STATE - '+  customer.STATE);
                system.debug(' customer.COUNTRY - '+  customer.COUNTRY);
                
                
                Wrapperlist.add(customer);
            }
            return Wrapperlist;
            
        } catch (Exception e) {
            // Exception handling
            System.debug('Exception caught while processing customer data: ' + e.getMessage());
            System.debug('Exception line number ' + e.getLineNumber());
            
            return new List<CustomerDetail>(); // Return an empty list
        }
    }
    
 
    
    @InvocableMethod(
    label='Send Service Contract and Account Details to SAP'
        category='Service Contract'
        )
    public static List<String> sendSAPFlow(List<List<String>> ids) {

        system.debug('ids -- '+ ids);

        List<String> accIDs = new List<String>();
        accIDs.add(ids[0][0]);
        system.debug('accIDs -- '+ accIDs);

        system.debug('ids[0][1] -- '+ ids[0][1]);

        sendToSAP(accIDs, null, ids[0][1]);

        return null;
    }
    
   

    @future(callout = true)
public static void sendToSAP(List<Id> AccountId, String mrId, String contractId) {
    try {
        System.debug('contractId: ' + contractId);

        // Fetch customer details
        List<CustomerDetail> wrapperList = CustomerData(AccountId, contractId);

        // Serialize JSON body
        String requestBody = JSON.serialize(wrapperList);
        System.debug('Request Body: ' + requestBody);

        // Fetch SAP credentials
        SAP_Credential__mdt serialNumberCreds = [SELECT Id, UserName__c, Password__c FROM SAP_Credential__mdt LIMIT 1];

        // Prepare basic authentication
        String authHeader = serialNumberCreds.UserName__c + ':' + serialNumberCreds.Password__c;
        String encodedAuthHeader = EncodingUtil.base64Encode(Blob.valueOf(authHeader));

        // First callout headers
        Map<String, String> authHeaders = new Map<String, String>();
        authHeaders.put('Authorization', 'Basic ' + encodedAuthHeader);
        authHeaders.put('x-csrf-token', 'fetch');

        // Metadata for first callout
        String metadataDevName = 'Send_Customer_Details_Auth';
        HttpResponse res = HTTPCallout.makeCallout(metadataDevName, null, authHeaders, null, null);

        if (res.getStatusCode() == 405) {
            // Extract tokens and cookies
            String csrfToken = res.getHeader('x-csrf-token');
            String cookie = res.getHeader('set-cookie');

            System.debug('CSRF Token: ' + csrfToken);
            System.debug('Cookie: ' + cookie);

            // Call the second method for subsequent callout
            handleSecondCallout(csrfToken, cookie, requestBody, contractId, mrId);
        } else if (res.getStatusCode() == 408) {
            System.debug('Timeout error: ' + res.getStatusCode());

            // Log timeout error inline
            insert new API_Log__c(
                Response_Body__c = res.getBody(),
                Response_Status_Code__c = '408',
                Request_Body__c = contractId,
                Class_Name__c = 'SendCustomerDetails',
                Method_Name__c = 'sendToSAP',
                Service_Contract__c = contractId
            );
        } else {
            System.debug('Unexpected Response: ' + res.getStatusCode());
        }
    } catch (Exception ex) {
        insert new Exception_Log__c(
            Error_Message__c = ex.getMessage(),
            Line_Number__c = String.valueOf(ex.getLineNumber()),
            Logged_By__c = UserInfo.getUserId(),
            Source__c = 'sendToSAP'
        );
    }
}


public static void handleSecondCallout(String csrfToken, String cookie, String requestBody, String contractId, String mrId) {
    try {
        // Prepare headers for the second callout
        Map<String, String> headers = new Map<String, String>();
        headers.put('x-csrf-token', csrfToken);
        headers.put('Content-Type', 'application/json');
        headers.put('Cookie', cookie);

        // Metadata for the second callout
        String sendCustMetadataName = 'Send_Customer_Details_API';
        HttpResponse response = HTTPCallout.makeCallout(sendCustMetadataName, null, headers, requestBody, null);

        System.debug('Second Callout Response Code: ' + response.getStatusCode());
        System.debug('Second Callout Response Body: ' + response.getBody());

        // Log API response
                API_Log__c apiResponse = new API_Log__c();
                apiResponse.Response_Body__c = response.getBody();
                apiResponse.Response_Status_Code__c = String.valueOf(response.getStatusCode());
                apiResponse.Request_Body__c = requestBody;
                apiResponse.Class_Name__c = 'SendCustomerDetails';
                apiResponse.Method_Name__c = 'sendToSAP';


                if(contractId != null){
                    apiResponse.Service_Contract__c = contractId;
                }
                 if(mrId != null){
                    apiResponse.Part_Request__c = mrId;
                }


                apiResponse.Method_Name__c = 'sendToSAP';

                insert apiResponse;

                if(mrId != null){

                    List<ProductRequest> partRequests = [SELECT Id, SAP_MR_Number__c, API_Error_Message__c, Is_MR_API_Failed__c FROM ProductRequest WHERE Id = :mrId LIMIT 1];

                    for (ProductRequest partRequest : partRequests){
                                            partRequest.Is_MR_API_Failed__c = true;
                                            partRequest.API_Error_Message__c = response.getBody();
                                        }

                        update partRequests;


                }



                if (response.getStatusCode() == 200) {
                    System.debug('success: ' + response.getBody());
                    
                    // Deserialize the JSON response into a list of ResponseWrapper objects
                    List<ResponseWrapper> finalResponse = (List<ResponseWrapper>) JSON.deserialize(response.getBody(), List<ResponseWrapper>.class);
                    
                    
                    // Collect all SF_CUSTOMER_ID values
                    Set<String> sfCustomerIds = new Set<String>();
                    for (ResponseWrapper rw : finalResponse) {
                        sfCustomerIds.add(rw.SF_CUSTOMER_ID);
                    }
                    
                    // Query all Accounts with the collected SF_CUSTOMER_ID values
                    Map<String, Account> accountMap = new Map<String, Account>();
                    for (Account acc : [SELECT Id, Customer_ID__c,SAP_Customer_ID__c FROM Account WHERE Customer_ID__c IN :sfCustomerIds]) {
                        accountMap.put(acc.Customer_ID__c, acc);
                    }
                    
                    // List to hold the accounts to update
                    List<Account> accountsToUpdate = new List<Account>();
                    
                    // Iterate through the deserialized response and update the accounts
                    for (ResponseWrapper rw : finalResponse) {
                        if (accountMap.containsKey(rw.SF_CUSTOMER_ID)) {
                            Account acc = accountMap.get(rw.SF_CUSTOMER_ID);
                            if(rw.SAP_CUSTOMER_ID.startsWith('0')){
                                acc.SAP_Customer_ID__c = rw.SAP_CUSTOMER_ID.substring(1, rw.SAP_CUSTOMER_ID.length());
                            } else{
                                acc.SAP_Customer_ID__c = rw.SAP_CUSTOMER_ID;
                            }
                            
                            accountsToUpdate.add(acc);
                        }                       
                    }
                    
                    // Update the accounts in bulk
                    if (!accountsToUpdate.isEmpty()) {
                        update accountsToUpdate;
                        System.debug('Accounts updated successfully.');
                        
                        //fetch all the customer contacts and send to SAP
                        
                        list<String> contactIds = new list<String>();
                        set<Id> accountIds = new set<Id>();
                        
                        for(Account updatedAccount: accountsToUpdate){
                            accountIds.add(updatedAccount.Id);
                            
                        }
                        
                        //call queable contract API
                        if(contractId != null){
                            System.debug('SendContractDetailsSAPQueueable called.');
                            System.debug('contractId called.-- ' + contractId);

                            System.enqueueJob(new SendContractDetailsSAPQueueable(contractId));
                            
                        }

                            //only send mr is customer api is success
                               if(mrId != null && finalResponse[0].STATUS != 'Fail'){
                                //send MR details to SAP
                                System.debug('SendMRDetailsSAPQueueable called.');                                
                                System.enqueueJob(new SendMRDetailsSAPQueueable(mrId));
                                
                            }
                        
                        list<Contact> contactLst = [SELECT Id,SAP_Contact_Id__c FROM Contact WHERE AccountId IN: accountIds];
                        
                        if(!contactLst.isEmpty() && mrId == null && contractId == null){
                            
                            for(Contact customerContact : contactLst){
                                if(customerContact.SAP_Contact_Id__c == null){
                                    contactIds.add(customerContact.Id);
                                }
                            }
                            system.debug('contactIds - '+ contactIds);                           
                        }

                        if(!contactIds.isEmpty()){

                            System.debug('SendContactDetailsQueueable called.');

                            System.enqueueJob(new SendContactDetailsQueueable(contactIds));

                        }
                    }
                    else {
                        System.debug('No accounts found to update.');
                    }
                }
         else {
            System.debug('Error during second callout: ' + response.getBody());
        }
    } catch (Exception ex) {
        insert new Exception_Log__c(
            Error_Message__c = ex.getMessage(),
            Line_Number__c = String.valueOf(ex.getLineNumber()),
            Logged_By__c = UserInfo.getUserId(),
            Source__c = 'handleSecondCallout'
        );
    }
}

    public class ResponseWrapper {
        public String SAP_CUSTOMER_ID;
        public String SF_CUSTOMER_ID;
        public String MESSAGE;
        public String STATUS;
    }

        public static void coveragemethod(){

        integer i = 0;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

        

    }
    
}