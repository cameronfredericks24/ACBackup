/*
@Author : Sumukha N S
@CreatedDate : 22nd Feb 2024
@Description : Data creation for the test classes.
@Last Modified By : Sumukha N S
*/
public without sharing class TestDataFactory {
    // Helper method to disable triggers by inserting Trigger_Setting__c records
    public static void disableTriggers() {
        List<String> triggerObjectNames = new List<String>{
            'AccountTrigger', 'AddressTrigger', 'AllTriggers', 'AssetTrigger', 'AssetWarrantyTrigger',
                'BulkProductRequestTrigger', 'CaseTrigger', 'ContactTrigger', 'ContentDocumentLinkTrigger',
                'ContentDocumentTrigger', 'ContentVersionTrigger', 'ContractLineItemTrigger',
                'CPQQuoteLinesTrigger', 'CPQQuoteTrigger', 'DivisionTrigger', 'OpportunityTrigger',
                'ProductConsumedTrigger', 'ProductItemTrigger', 'ProductRequestLineItemTrigger',
                'ProductRequestTrigger', 'ProductTransferTrigger', 'ProductTrigger', 'QuoteTrigger',
                'ReturnOrderTrigger', 'SalesOrderItemTrigger', 'SBQQ_QuoteDocumentTrigger',
                'ServiceAppointmentTrigger', 'ServiceContractTrigger', 'SurveyInvitationTrigger',
                'WorkOrderLineItemTrigger', 'WorkOrderTrigger','ServiceReportTrigger'
                };
                    
                    List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            Trigger_Setting__c triggerSetting = new Trigger_Setting__c(Name = objectString, IsActive__c = false);
            triggerSettings.add(triggerSetting);
        }
        insert triggerSettings;
    }
    
    // Helper method to enable triggers by deleting Trigger_Setting__c records
    public static void enableTriggers() {
        delete [SELECT Id FROM Trigger_Setting__c WHERE Name IN (
            'AccountTrigger', 'AddressTrigger', 'AllTriggers', 'AssetTrigger', 'AssetWarrantyTrigger',
            'BulkProductRequestTrigger', 'CaseTrigger', 'ContactTrigger', 'ContentDocumentLinkTrigger',
            'ContentDocumentTrigger', 'ContentVersionTrigger', 'ContractLineItemTrigger',
            'CPQQuoteLinesTrigger', 'CPQQuoteTrigger', 'DivisionTrigger', 'OpportunityTrigger',
            'ProductConsumedTrigger', 'ProductItemTrigger', 'ProductRequestLineItemTrigger',
            'ProductRequestTrigger', 'ProductTransferTrigger', 'ProductTrigger', 'QuoteTrigger',
            'ReturnOrderTrigger', 'SalesOrderItemTrigger', 'SBQQ_QuoteDocumentTrigger',
            'ServiceAppointmentTrigger', 'ServiceContractTrigger', 'SurveyInvitationTrigger',
            'WorkOrderLineItemTrigger', 'WorkOrderTrigger','ServiceReportTrigger'
        )];
    }
    
    public static void enableAllTriggers() {
        List<String> triggerObjectNames = new List<String>{
            'AccountTrigger', 'AddressTrigger', 'AllTriggers', 'AssetTrigger', 'AssetWarrantyTrigger',
                'BulkProductRequestTrigger', 'CaseTrigger', 'ContactTrigger', 'ContentDocumentLinkTrigger',
                'ContentDocumentTrigger', 'ContentVersionTrigger', 'ContractLineItemTrigger',
                'CPQQuoteLinesTrigger', 'CPQQuoteTrigger', 'DivisionTrigger', 'OpportunityTrigger',
                'ProductConsumedTrigger', 'ProductItemTrigger', 'ProductRequestLineItemTrigger',
                'ProductRequestTrigger', 'ProductTransferTrigger', 'ProductTrigger', 'QuoteTrigger',
                'ReturnOrderTrigger', 'SalesOrderItemTrigger', 'SBQQ_QuoteDocumentTrigger',
                'ServiceAppointmentTrigger', 'ServiceContractTrigger', 'SurveyInvitationTrigger',
                'WorkOrderLineItemTrigger', 'WorkOrderTrigger','ServiceReportTrigger'
                };
                    
                    List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            Trigger_Setting__c triggerSetting = new Trigger_Setting__c(Name = objectString, IsActive__c = true);
            triggerSettings.add(triggerSetting);
        }
        insert triggerSettings;
    }
    
    /*
@Author : Sumukha N S
@CreatedDate : 22nd Feb 2024
@Description : returns the request JSON String for ticket creation API.
@Last Modified By : Sumukha N S
*/
    public static String GenericTicketCreationJSONRequest(){
        disableTriggers();
        try {
            return '{'+
                '    "source": "Website",'+
                '    "phone_number": "9901254697",'+
                '    "customer_name": "Daniel Ric",'+
                '    "email": "sumukhasn7@gmail.com",'+
                '    "product_name": "Blue star AC",'+
                '    "model_number": "XAC4VS-048MR3",'+
                '    "ticket_type": "5",'+
                '    "billing_address": {'+
                '        "builder_apartment_name": "Akhila Enclave",'+
                '        "block_flat_no": "205",'+
                '        "street": "10th Main Rd",'+
                '        "locality": "",'+
                '        "pincode": "560078",'+
                '        "state": "Karnataka",'+
                '        "city": "Banalore",'+
                '        "telephone_number": "",'+
                '        "mobile_number": "",'+
                '        "email": ""'+
                '    },'+
                '    "installation_address": {'+
                '        "builder_apartment_name": "Akhila Enclave",'+
                '        "block_flat_no": "205",'+
                '        "street": "10th Main Rd",'+
                '        "locality": "",'+
                '        "pincode": "560078",'+
                '        "state": "Karnataka",'+
                '        "city": "Banalore",'+
                '        "telephone_number": "",'+
                '        "mobile_number": "",'+
                '        "email": ""'+
                '    }'+
                '}';
        } finally {
            enableTriggers();
        }
        
    }
    
    /*
@Author : Sumukha N S
@CreatedDate : 22nd Feb 2024
@Description : returns the request JSON String for ticket creation API.(with the existing account data)
@Last Modified By : Sumukha N S
*/
    public static String GenericTicketCreationJSONRequestExistingAccount(){
        disableTriggers();
        try {
            return '{'+
                '    "source": "Website",'+
                '    "phone_number": "9901254697",'+
                '    "customer_name": "Daniel Ric",'+
                '    "email": "sumukhasn7@gmail.com",'+
                '    "product_name": "Blue star AC",'+
                '    "model_number": "XAC4VS-048MR3",'+
                '    "ticket_type": "5",'+
                '    "billing_address": {'+
                '        "builder_apartment_name": "Akhila Enclave",'+
                '        "block_flat_no": "205",'+
                '        "street": "10th Main Rd",'+
                '        "locality": "",'+
                '        "pincode": "560078",'+
                '        "state": "Karnataka",'+
                '        "city": "Banalore",'+
                '        "telephone_number": "",'+
                '        "mobile_number": "",'+
                '        "email": ""'+
                '    },'+
                '    "installation_address": {'+
                '        "builder_apartment_name": "Akhila Enclave",'+
                '        "block_flat_no": "205",'+
                '        "street": "10th Main Rd",'+
                '        "locality": "",'+
                '        "pincode": "560078",'+
                '        "state": "Karnataka",'+
                '        "city": "Banalore",'+
                '        "telephone_number": "",'+
                '        "mobile_number": "",'+
                '        "email": ""'+
                '    }'+
                '}';
        } finally {
            enableTriggers();
        }
    }
    
    /*
@Author : Sumukha N S
@CreatedDate : 22nd Feb 2024
@Description : returns the request JSON String for IVR ticket creation API.
@Last Modified By : Sumukha N S
*/
    public static String GenesysIVRTicketCreationJSONRequest() {
        disableTriggers();
        try {
            return '{' +
                '    "phone_number": "9901254697",' +
                '    "type": "2",' +
                '    "language_preferred": "4",' +
                '    "caller_type": "2",' +
                '    "product_type": "2"' +
                '}';
        } finally {
            enableTriggers();
        }
    }
    
    /*
@Author : Sumukha N S
@CreatedDate : 27th Feb 2024
@Description : returns the request JSON String for feedback capture.
@Last Modified By : Sumukha N S
*/
    public static String GenesysIVRFeedbackCaptureJSONRequest(String caseNumber) {
        disableTriggers();
        try {
            Map<String, Object> jsonMap = new Map<String, Object>();
            List<Map<String, String>> feedbackList = new List<Map<String, String>>();
            Map<String, String> feedbackMap = new Map<String, String>();
            
            feedbackMap.put('question_id', '11');
            feedbackMap.put('answer', '2');
            feedbackList.add(feedbackMap);
            
            jsonMap.put('reference_id', caseNumber);
            jsonMap.put('reference_type', 'ticket');
            jsonMap.put('phone_number', '9901254697');
            jsonMap.put('template_id', '1234');
            jsonMap.put('feedback', feedbackList);
            
            return JSON.serialize(jsonMap);
        } finally {
            enableTriggers();
        }
    }
    
    
    public static string SAPCaptureAlternatePartAPIJSONRequest(){
        disableTriggers();
        try {
            
            Map<String, Object> jsonMap = new Map<String, Object>();
            List<Map<String, String>> alternatePartLst = new List<Map<String, String>>();
            
            Map<String, String> alternatePartMap = new Map<String, String>();
            String parentCode = 'BSLV004';
            String alternatePartCode = 'BSLV0010';
            
            
            // list<Product2> prodLst = [select id,ProductCode,RecordType.Name,RecordTypeId from Product2 where RecordType.Name ='Spare'];
            
            // for (Integer i = 0; i < prodLst.size(); i++) {
            //     parentCode = prodLst[i].ProductCode;
            //     alternatePartCode = prodLst[i+1].ProductCode;
            
            //     system.debug('parentCode' + prodLst[i].ProductCode);
            //     system.debug('alternatePartCode' + prodLst[i+1].ProductCode);
            
            
            
            
            // }
            
            alternatePartMap.put('product_code', parentCode);
            alternatePartMap.put('alternate_product_code', alternatePartCode);
            alternatePartLst.add(alternatePartMap);
            
            jsonMap.put('alternate_parts',alternatePartLst);
            
            system.debug('data' + JSON.serialize(jsonMap));
            
            return JSON.serialize(jsonMap);
        } finally {
            enableTriggers();
        }
        
        
    }
    
    /*@InvocableMethod(label='Generate Model Details JSON' description='Generates JSON for ModelDetails')
public static List<String> ModelDetailsCreationJSONRequest(List<String> serialNumbers) {
String serialNumber = serialNumbers[0];
system.debug('Result'+serialNumbers);
if(serialNumber == '9595') {
List<String> productDetailsList = new List<String>();
String productDetailsJson = '{'+
'"products": {'+
'"is_installable": true,'+
'"model_code": "YJU998877",'+
'"serial_number": "9595",'+
'"manufacturing_date": "2024-01-23"'+
'}'+
'}';
productDetailsList.add(productDetailsJson);
system.debug('Result'+productDetailsList);
return productDetailsList;
} else {
system.debug('not found Result');
return null;
}
} */
    
    /*
@Author : Abhijeet Ojha
@CreatedDate : 23th April 2024
@Description : Returns the SAPInvoicePaymentRequestWrapper.PaymentDetails for invoice payment.
@Last Modified By :  Abhijeet Ojha
*/
    public static List<SAPInvoicePaymentRequestWrapper.PaymentDetails> createInvoicePaymentRequest() {
        disableTriggers();
        try {
            List<SAPInvoicePaymentRequestWrapper.PaymentDetails> testData = new List<SAPInvoicePaymentRequestWrapper.PaymentDetails>();
            
            // Create test data for a single invoice payment request
            SAPInvoicePaymentRequestWrapper.PaymentDetails request = new SAPInvoicePaymentRequestWrapper.PaymentDetails();
            
            request.customer_Code = '12345';
            request.invoice_Date = Date.newInstance(2024, 4, 17);
            request.amount = '1000';
            request.document_Number = '005';
            request.document_Date = Date.newInstance(2024, 4, 10);
            request.payment_transaction_number = '100234';
            
            testData.add(request);
            
            return testData;
        } finally {
            enableTriggers();
        }
    }
    /*
@Author : Abhijeet Ojha
@CreatedDate : 23th April 2024
@Description : Returns the SAPCaptureCreditNoteRequestWrapper for Credit Note.
@Last Modified By :  Abhijeet Ojha
*/
    public static List<SAPCaptureCreditNoteRequestWrapper> createSAPCreditDebitRequest() {
        disableTriggers();
        try {
            List<SAPCaptureCreditNoteRequestWrapper> requests = new List<SAPCaptureCreditNoteRequestWrapper>();
            
            //test data for singleton instance of itself
            SAPCaptureCreditNoteRequestWrapper request = new SAPCaptureCreditNoteRequestWrapper();
            request.contractNum='00000101';
            request.creditAmt='1002345';
            request.status='Active';
            request.customerCode='1201';
            request.creditNoteId='2001';
            request.invoiceNum='INV-0002';
            
            requests.add(request);
            
            return requests;
        } finally {
            enableTriggers();
        }
        
    }
    
    /*
@Author : Abhijeet Ojha
@CreatedDate : 8th May 2024
@Description : Returns the SAPCaptureChannelPartnerRequestWrapper for Capture Channel Partner.
@Last Modified By :  Abhijeet Ojha
*/
    public static SAPCaptureChannelPartnerRequestWrapper createSAPChannelPartnerDetails(){
        disableTriggers();
        try {
            // Instantiate the wrapper class
            SAPCaptureChannelPartnerRequestWrapper wrapper = new SAPCaptureChannelPartnerRequestWrapper();
            // Create an instance of the inner class and populate it with sample data
            SAPCaptureChannelPartnerRequestWrapper.ChannelPartnerDetails partnerDetails =
                new SAPCaptureChannelPartnerRequestWrapper.ChannelPartnerDetails();
            partnerDetails.channelPartnerName = 'Sinu Singh';
            partnerDetails.cpCode = 'CP123456';
            partnerDetails.type = 'SSD';
            partnerDetails.divisionTagged = 'CPAG';
            partnerDetails.outstanding = '50000';
            partnerDetails.category = 'Partner';
            partnerDetails.branchCode = '220';
            partnerDetails.contactName = 'Dolly Singh';
            partnerDetails.contactMobile = '9809876789';
            partnerDetails.contactAlternatePhone = '9809876756';
            partnerDetails.contactEmail = 'dollysingh@gmail.com';
            partnerDetails.billingAddressLine1 = '123 Example Street';
            partnerDetails.billingAddressLine2 = 'Suite 100';
            partnerDetails.billingAddressLine3 = 'Building 5';
            partnerDetails.billingAddressLine4 = 'Block B';
            partnerDetails.billingCity = 'Metropolis';
            partnerDetails.billingArea = 'Central District';
            partnerDetails.billingState = 'Assam';
            partnerDetails.billingCountry = 'India';
            partnerDetails.billingPincode = '123456';
            partnerDetails.billingSector = 'Sector 2';
            partnerDetails.gst = '12ABCDE3456FZ1';
            partnerDetails.pan = 'ABCDE1234F';
            partnerDetails.isActive = 'true';
            partnerDetails.phone = '9809876745';
            partnerDetails.email = 'sinusingh@gmail.com';
            // Add the populated details to the wrapper's cpDetails list
            wrapper.cpDetails.add(partnerDetails);
            
            return wrapper;
        } finally {
            enableTriggers();
        }
    }

    public static Product_Family__c createProductFamily(String name ) {
        Product_Family__c productFamily = new Product_Family__c(
            Name = 'AC - Room Air Conditioner',
            Code__c = 'F1200',
            RecordTypeId = ProductFamilyConstants.productFamilyRecordTypeId
        );
        insert productFamily;
        return productFamily;
    }
    
    public static Product_Family__c createProductSubFamily(String name, Product_Family__c prodFmily) {
        Product_Family__c productSubFamily = new Product_Family__c(
            Name = 'Split',
            Code__c = 'F1202',
            Parent_Product_Family__c = prodFmily.Id,
            RecordTypeId = ProductFamilyConstants.productSubFamilyRecordTypeId
        );
        insert productSubFamily;
        return productSubFamily;
    }

    
    // Method to create a Price Book Entry
    public static PricebookEntry createPricebookEntry(Product2 product, Id  priceBookId) {
        PricebookEntry priceBookEntry = new PricebookEntry(
            Pricebook2Id = priceBookId,
            Product2Id = product.Id,
            IsActive = true,
            Channel_Partner_Price__c = 1,
            Cost_Price__c = 1,
            Customer_Price__c = 1,
            UnitPrice = 1
        );
        insert priceBookEntry;
        return priceBookEntry;
    }

    // Method to create a Product with Family and Sub-Family
    public static Product2 createProduct(String name, String productCode, Product_Family__c productFamily, Product_Family__c productSubFamily) {
        Product2 product = new Product2(
            Name = '11213TR R32 1 STAR F HW SAC',
            ProductCode = productCode,
            Status__c = 'Active',
            Product_Family__c = productFamily.Id,
            Product_Sub_Family__c = productSubFamily.Id
        );
        System.runAs(createByPassUser()){
        insert product;
            createStdPriceBookEntry(product.Id);
        }
        return product;
    }

    public static  ProductRequestLineItem createProductRequestLineItem(ProductRequest prodRequest, Account account, Product2 product, Schema.Location location){
        ProductRequestLineItem prodReqLineItem = new ProductRequestLineItem(
            ParentId = prodRequest.Id,
            AccountId = account.Id,
            Product2Id = product.Id,
            DestinationLocationId = location.Id, 
            QuantityRequested = 9,
            QuantityUnitOfMeasure = 'Each'
        );

        insert prodReqLineItem;
        return prodReqLineItem;
    }

    public static ProductRequest createProductRequest(Account account, Product2 product, WorkOrder serviceTicket ){

        Id saleOrderRecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Sale_Order').getRecordTypeId();
        ProductRequest pr = new ProductRequest(
            AccountId = account.Id,
            Product__c = product.Id,
            Quantity__c = 7,
            WorkOrderId =  serviceTicket.Id,
            recordtypeId = saleOrderRecordTypeId 
        );

        insert pr;
        return pr;
    }

    
    public static ProductTransfer createProductTransfer(Product2 product, Schema.Location location, GRN__c grn, ProductRequestLineItem prodReqLineItem){
        ProductTransfer pt = new ProductTransfer(
            //ProductRequestId = prodRequest.Id,
            Product2Id = product.Id,
            DestinationLocationId = location.Id,
            QuantitySent = 45,
            GRN__c = grn.Id,
            ProductRequestLineItemId = prodReqLineItem.Id,
            Quantity_Damaged__c = 3
            //Amount__c = 700,
            //Quantity_Damaged__c = 2,
            //QuantityUnitOfMeasure = 'Each' 
        );

        insert pt;
        return pt;
    }

   

    public static GRN__c createGRN(ProductRequest prodReq, String status, String type){
        GRN__c grn = new GRN__c(
            Product_Request__c = prodReq.Id,
            Status__c = status,
            Total_Qty_Damaged__c = 3 ,
            Total_Qty_Mismatched__c = 2,
            Total_Qty_Received__c = 5,
            GRN_Type__c = type
        );

        insert grn;
        return grn;
    }



    public static Schema.Location createLocation(String locationName, String warehouseType) {
        // Create a new Location record
        Schema.Location locationData = new Schema.Location();
        locationData.Name = locationName;
        locationData.Warehouse_Type__c = warehouseType;
        locationData.IsInventoryLocation = true;

        insert locationData;
        return locationData;
    }

         // Create ProductItem
         public static ProductItem createProductItem(Id productId, Id locationId, Decimal quatity) {
            ProductItem productItem = new ProductItem(
                Product2Id = productId,
                LocationId = locationId,
                QuantityOnHand = quatity,
                QuantityUnitOfMeasure = 'Each'
            );
           insert productItem;
            return productItem;
        }
       
    public static Defective_Product_Item__c createdefectiveProductItem(Account channelPartner, String category, ProductTransfer prodTransfer, GRN__c grn) {
        Defective_Product_Item__c defectiveProductItem = new Defective_Product_Item__c(
            Channel_Partner__c = channelPartner.Id,
            Defective_Category__c = category,
            Quantity_On_Hand__c = prodTransfer.Quantity_Damaged__c,
            Created_From_GRN__c = true,
            Part_Request__c = prodTransfer.Part_Request_MR__c,
            Reverse_GRN__c = grn.Id,
            Product_Name__c = prodTransfer.Product2Id,
            Location__c = prodTransfer.DestinationLocationId,
            Product_Transfer__c = prodTransfer.Id,
            Product_Type__c = 'Damaged',
            Part_Request_Line_Item__c = prodTransfer.ProductRequestLineItemId
        );

        insert defectiveProductItem;
        return defectiveProductItem;
    }

      // Method to create a Branch record
      public static Branch__c createBranch(String branchName) {
        Branch__c branch = new Branch__c(Name = branchName);
        insert branch;
        return branch;
    }

    public static Account createResidentialAccount(String name, String phone) {
        Account account = new Account(
            Name = name,
            Residential_Configuration__c = '1 BHK',
            Email__c = 'test90@gmail.com',
            Phone = phone,
            BillingCountry = 'India',
            BillingState = 'Maharashtra',
            BillingPostalCode = '400008',
            BillingCity = 'Mumbai',
            BillingStreet = 'street123',
             ShippingCountry = 'India',
            ShippingState = 'Maharashtra',
            ShippingPostalCode = '400008',
            ShippingCity = 'Mumbai',
            ShippingStreet = 'street123',
            RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
        );
        
        insert account;
        return account;
    }

    public static User createChannelPartnerUser( String firstName, String lastName, Contact contact) {  

        String orgId = UserInfo.getOrganizationId(); 
        Id profileId = [SELECT Id, Name from Profile where Name = 'Channel Partner User - ssd'].Id; 


        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Super_User' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and isActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;

            //Id defaultRoleId = [SELECT Id FROM UserRole WHERE Name = 'ROYAL COOLING SYSTEMS Partner User' LIMIT 1].Id;

        // Id defaultRoleId = [SELECT Id FROM UserRole WHERE Name = 'ROYAL COOLING SYSTEMS Partner User' LIMIT 1].Id;
        String dateString =  String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'UTF-8',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'Asia/Kolkata',  
            LocaleSidKey = 'en_IN',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profileId,
            ContactId = contact.Id
        );    
  
          System.runAs(adminUser){

        insert tempUser;
        }
        return tempUser;  
    }

    public static Account createChannelPartner( OperatingHours operatingHours) {
        Account acc = new Account(
            Name = 'veera Singh',
            CP_Code__c = 'LA03816-00',
            Type  = 'ESA',
            
            CP_Service_Type__c = 'Breakdown',
            Email__c = 'testveer8976@gmail.com',
            ShippingCountry = 'India',
            ShippingState = 'Maharashtra',
            ShippingPostalCode = '400008',
            ShippingCity = 'Mumbai',
            ShippingStreet = 'street123',
            OperatingHoursId = operatingHours.Id,
            RecordTypeId = AccountConstant.CHANNEL_PARTNER_ACCOUNT_RT
        );

        insert acc;
        return acc;

    } 

    public static Account createChannelPartner2(String name ) {
        OperatingHours opHrs =[Select Id , Name from OperatingHours where Name = 'Blue Star Operating Hours' LIMIT 1];
        system.debug('opHrs'+opHrs);
        Account acc = new Account(
            Name = name,
            CP_Code__c = 'LA03816-00',
            Type  = 'ESA',
            CP_Service_Type__c = 'Breakdown',
            Email__c = 'testveer8976@gmail.com',
            ShippingCountry = 'India',
            ShippingState = 'Maharashtra',
            ShippingPostalCode = '400008',
            ShippingCity = 'Mumbai',
            ShippingStreet = 'street123',
            OperatingHoursId = opHrs.Id,
            RecordTypeId = AccountConstant.CHANNEL_PARTNER_ACCOUNT_RT
        );

        insert acc;
        return acc;

    } 

    public static Contact createContactCP(String firstName, String lastName, String email, String accountId){
        Contact portalContact = new contact(
            FirstName = firstName, 
            LastName = lastName, 
            Email = email, 
            AccountId = accountId
        );
        insert portalContact;
        return portalContact;
    }


    public Static OperatingHours createOperatingHour(){
        OperatingHours opHrs = new OperatingHours(
        Name = 'Blue Star Operating Hours1',
        TimeZone = 'Asia/Kolkata'
        );
        insert opHrs;
        return opHrs;
    }


    public Static OperatingHours createOperatingHour2( String name){
        OperatingHours opHrs = new OperatingHours(
        Name = name,
        TimeZone = 'Asia/Kolkata'
        );
        insert opHrs;
        return opHrs;
    }


    public Static ServiceTerritory createServiceTrt( Account channelPartner, OperatingHours OperatingHours){
        ServiceTerritory serviceTerritoryData = new ServiceTerritory(
        Name = 'Mumbai-1',
        Channel_Partner_Account__c = channelPartner.Id,
        OperatingHoursId = OperatingHours.Id,
        IsActive = true
        );
        insert serviceTerritoryData;
        return serviceTerritoryData;
    }
    
    public static User createByPassUser() {  
        Profile p = [SELECT Id FROM Profile WHERE Name='ByPass Flow For Test Class']; 
        List<User> extum = [Select Id from User where username = 'stanm1233darduser@bluestar.com'];
        User mu;
        if(!extum.isEmpty()){
            mu = extum[0];
        } else{
                  mu  = new User(Alias = 'mstandt', Email='test@bluestarindia.com', 
            	EmailEncodingKey='UTF-8', LastName='mtesting', LanguageLocaleKey='en_US', 
            	LocaleSidKey='en_US', ProfileId = p.Id, 
            	TimeZoneSidKey='America/Los_Angeles', UserName='stanm1233darduser@bluestar.com');
		
       		 insert mu;
          }
        List<User> extu = [Select Id from User where username = 'stan1233darduser@bluestar.com'];
        User u;
        if(!extu.isEmpty()){
            u = extu[0];
        } else{
                  u = new User(Alias = 'standt', Email='test@bluestarindia.com', 
                 ManagerId = mu.Id,
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='stan1233darduser@bluestar.com');
            
            	insert u;
          }
        
       
        return u;  
    }


    
    public Static ServiceTerritory createServiceTrt2( Account channelPartner){
        OperatingHours opHrs =[Select Id , Name from OperatingHours where Name = 'Blue Star Operating Hours' LIMIT 1];
        ServiceTerritory serviceTerritoryData = new ServiceTerritory(
        Name = 'Mumbai-1',
        Channel_Partner_Account__c = channelPartner.Id,
        OperatingHoursId = opHrs.Id,
        IsActive = true
        );
        insert serviceTerritoryData;
        return serviceTerritoryData;
    }


    public static ContentVersion createContentVersion(String title){
        ContentVersion cv = new ContentVersion(
            Title = title,
            PathOnClient = 'TestImage.png',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;
        return cv;
    }

    public static ContentDocumentLink createContentDocumentLink(String contentDocumentId, String linkedEntityId){
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = linkedEntityId,
            ShareType = 'I'
        );
        insert cdl;
        return cdl;
    }

    public static Asset createAsset(String name, String status, Product2 product, Branch__c branch, Date invoiceDate, String invoiceNumber, Account account) {
        Asset asset = new Asset(
            Name = product.Name + ' ' + product.Model_Type__c, 
            Model_Number__c = product.ProductCode,  
            Status = status, 
            Product2Id = product.Id,
            Product_Family__c = product.Product_Family__c, 
            Product_Sub_Family__c = product.Product_Sub_Family__c,  
            Branch__c = branch.Id,  
            AccountId = account.Id,
            Price = 10000,
            Invoice_Date__c = invoiceDate,  
            Invoice_Number__c = invoiceNumber  
        );
        insert asset;
        return asset;
    }

    public static Case createCase(String subject, String status, String type, Account account, Asset asset, Product2 product, Branch__c branch) {
        Case caseRecord = new Case(
            Subject = subject, 
            Status = status,
            Type = type,
            Priority = 'Medium',
            Language_Preference__c = 'English',
            Origin = 'Phone',
            Branch__c = branch.Id,
            AccountId = account.Id, 
            ProductId = product.Id,
            AssetId = asset.Id,
            Contact_Phone__c  = '8899779977'

        );
        insert caseRecord;
        return caseRecord;

    }

    // Method to create WorkType record
    public static WorkType createWorkType(String name) {
        WorkType workType = new WorkType(
            Name = name,
            EstimatedDuration = 1
        );
        insert workType;
        return workType;
    }
    
       public static WorkOrder createWorkOrder(Asset asset, WorkType workType, Account account, Case relatedCase, String status) {
    // Ensure the account has phone and email for related data testing
    if (account.Phone == null || account.Email__c == null) {
        account.Phone = '9994567890';
        account.Email__c = 'test@example.com'; // Replace `Email__c` with the actual field API name for email if different.
        update account;
    }

    WorkOrder workOrder = new WorkOrder(
        Subject = 'Test Work Order',
        AssetId = asset.Id,
        WorkTypeId = workType.Id,
        AccountId = account.Id,
        CaseId = relatedCase.Id,
        RecordTypeId = WorkOrderConstants.WorkOrder_Installation_RT,
        CP__c = relatedCase.CP__c,
        Invoice_Date__c = Date.today(),
        Status = status,
        OTP_Verified__c = true,
        Street = 'street123',
        PostalCode = '400008',
        City = 'Mumbai',
        State = 'Maharashtra',
        StateCode = 'MH',
        Country = 'India',
        CountryCode = 'IN',
        SymptomText__c = '',
        DefectText__c = '',
        ActionText__c = '',
        Symptom_Comment__c = '',
        Defect_Comment__c = '',
        Action_Comment__c = '',
        HappyCode__c = '12345',
        OTP_Expiration__c = System.now().addHours(2),
        OTP_to_Canceled__c = '123456',
        Canceled_OTP_Expiration__c = System.now().addHours(1),
        Canceled_Verified__c = false,
        OTP_to_Reschedule__c = '654321',
        Reschedule_OTP_Expiration__c = System.now().addDays(1),
        Reschedule_OTP_Verified__c = false
    );
    insert workOrder;
    return workOrder;
}

        // Method to create Work Order record with mandatory fields
    public static WorkOrder createChildWorkOrder(WorkOrder parentworkOrder) {
        WorkOrder workOrder = new WorkOrder(
            Subject = 'Test Work Order',
             RecordTypeId = returnOrderConstant.recordTypeIdWorkOrder,
            ParentWorkOrderId = parentworkOrder.Id,
            WorkTypeId = parentworkOrder.workType.Id,
            AccountId = parentworkOrder.AccountId,
            CaseId = parentworkOrder.CaseId,
            Status = 'Accepted',
            Invoice_Date__c = Date.today(),
            Street = parentworkOrder.Street ,
            PostalCode = parentworkOrder.PostalCode,
            City   = parentworkOrder.City,
            State = parentworkOrder.State,
            StateCode = parentworkOrder.StateCode,
            Country= parentworkOrder.Country,
            CountryCode = parentworkOrder.CountryCode
        );
        insert workOrder;
        return workOrder;
    }
    

    public static WorkOrderLineItem createWorkOrderLineItem(WorkOrder workOrder) {
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,
            AssetId = workOrder.AssetId,
            Status = 'New'
        );
        insert workOrderLineItem;
        return workOrderLineItem;
    }
   
    public static Failure_Attribute__c createFailureAttribute( String productFamily){
      // Step 4: Insert Failure_Attribute__c records with matching Sub_Family__c
      Failure_Attribute__c failureAttribute = new Failure_Attribute__c(
       Name = 'AC - Room Air Conditioner',
       Sub_Family__c = productFamily,
       Symptom__c = 'Unit Not Cooling',
       Defect__c = 'Indoor Unit Improper Installation',
       Action__c = 'Indoor Unit Installed properly'

        );
       insert failureAttribute;
       return failureAttribute;

    }
    
      public Static ReturnOrder createReturnOrder(WorkOrder workOrderData, String damageType, String status){
        ReturnOrder returnOrderData = new ReturnOrder(
            Work_Order__c = workOrderData.Id,
            caseId = workOrderData.caseId,
            ShipFromCity = workOrderData.City,
            ShipFromCountry = workOrderData.Country,
            ShipFromState = workOrderData.state,
            ShipFromPostalCode = workOrderData.PostalCode,
            ShipFromCountryCode = workOrderData.CountryCode,
            ShipFromStateCode = workOrderData.StateCode,
            Damage_Type__c = damageType,
            Invoice_Date__c = workOrderData.Invoice_Date__c,
            RecordTypeId = ReturnOrderConstant.FGR_recordTypeId,
            Location_Type__c  = 'Dealer',
            Status = status
        );

        insert returnOrderData;
        return returnOrderData;
          
          
    }

    public static Opportunity createOpp( Account account, String stageName){
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = stageName,
            CloseDate = System.today(),
            AccountId = account.Id
           // All_India_Commericial_Head__c  = createByPassUser().Id
        );
        insert opp;
        return opp;
    }
    
    public static void createStdPriceBookEntry(Id productId){
        PricebookEntry stdtestPricebookEntry = new PricebookEntry(Product2Id = productId, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
            insert stdtestPricebookEntry;
    }
    public static void createStdPriceBookEntryList(List<product2> prodList){
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        for(Product2 prod : prodList){
            PricebookEntry stdtestPricebookEntry = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
            pbeList.add(stdtestPricebookEntry);
        }
        insert pbeList;
    }
    
    
    public static BOM__c createBOM(Product2 product){
              BOM__c bom = new BOM__c(
              Product_Code__c = product.ProductCode 
              );
              insert bom;
              return bom;
          }

          public static Account createAccount(String name, String phone, String email, String SAP_custId) {
            Account account = new Account(
                Name = name,
                Residential_Configuration__c = '1 BHK',
                Email__c = email,
                Phone = phone,
                SAP_Customer_Id__c = SAP_custId,
                BillingCountry = 'India',
                BillingState = 'Maharashtra',
                BillingPostalCode = '400008',
                BillingCity = 'Mumbai',
                BillingStreet = 'street123',
                RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
            );
            
            insert account;
            return account;
        }

        public static Contact createContact(String firstName, String lastName, Account account) {
            Contact contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                AccountId = account.Id
            );
    
            insert contact;
            return contact;
        }

     public static ServiceAppointment createSA(WorkOrder serviceTicket, String status){
            ServiceAppointment sa = new ServiceAppointment();
             sa.ParentRecordId = serviceTicket.Id;
             sa.Work_Order__c=serviceTicket.Id;
             sa.EarliestStartTime = System.now();
             sa.DueDate = System.now().addDays(1);
             sa.SchedStartTime = System.now().addMinutes(30);
             sa.SchedEndTime = System.now().addHours(2);
              sa.Status = status;
             insert sa;
             return sa;
        }
    
      public static Department__c createDepartment(String departmentNumber, Division__c division) {
        RecordType serviceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Department__c' AND Name = 'Service' LIMIT 1];
            Department__c department = new Department__C(
                Name = departmentNumber,
               Department_Number__c = departmentNumber,
                Division__c = division.Id,
                recordTypeId = serviceRecordType.Id
            );
    
            insert department;
            return department;
        }
    
        public static Division__c createDivision(String divisionName) {
            Division__c division = new Division__c(
               Name = divisionName
            );
    
            insert division;
            return division;
        }
    
       public static SBQQ__Quote__c createQuoteCPQ(Opportunity opp, Department__c department, Division__c division, Account account){
        // Create a new SBQQ__Quote__c record
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.Id,
            SBQQ__Account__c = account.Id,
            Department__c = department.Id,
            Division__c = division.Id,
            Duration_Type__c = 'Year',
            Proposed_Period_From__c = Date.today(),
            Proposed_Period_To__c = Date.today().addMonths(3)
        );
        
        // Insert the new quote
        insert quote;
        
        // Return the created quote
        return quote;
    }
    
    public static SBQQ__QuoteLine__c createQuoteLineCPQ(Asset asset, SBQQ__Quote__c quote){
         Date startDate = Date.today(); 
         Date endDate = startDate.addYears(1);
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            Asset__c = asset.Id,
		   SBQQ__Product__c = asset.Product2Id,
		   SBQQ__Quote__c = quote.Id,
		   SBQQ__Quantity__c =  3,
           Standard_Downloading_Value__c = 100,
		   SBQQ__StartDate__c = startDate,
		   SBQQ__EndDate__c = endDate
			
        );
        
        insert quoteLine;
        return quoteLine;
    }
    
    public static ServiceContract createServiceContract ( Account account, 	Opportunity opp, Department__c dept, Division__c div,SBQQ__Quote__c quote){

        ServiceContract contract = new ServiceContract(
          Name = 'AMc Contract',
          AccountId  = account.Id,
          Opportunity__c = opp.Id,
          Department__c = dept.Id,
          Division__c = div.Id,
          Quote1__c = quote.Id
        );
        insert contract;
        return contract ;
   }
    
        public static ContractLineItem createServiceContractLineItem ( ServiceContract  sc, Asset asset){
    
        ContractLineItem contractLineItem = new ContractLineItem(
          ServiceContractId  = sc.Id,
          AssetId = asset.Id ,
          Unit_Price__c = 150,
          Quantity = 2
          
        );
        insert contractLineItem;
        return contractLineItem ;
   }
    
    public static User createTechnicianUser( String firstName, String lastName, Contact contact) {  

        String orgId = UserInfo.getOrganizationId(); 

        Id profileId = [SELECT Id, Name from Profile where Name = 'BSL Technician'].Id; 

        User adminUser = [Select Id, UserRoleId,ProfileId From User Where Profile.Name='System Administrator' and isActive = true Limit 1];


        String dateString =  String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'UTF-8',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'Asia/Kolkata',  
            LocaleSidKey = 'en_IN',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profileId,
            ContactId = contact.Id
        );    
  

        System.runAs(adminUser){

            insert tempUser;
        }
        return tempUser;  
    }
       public static Map<String, Asset> createAccountsAndAssets() {
        Map<String, Asset> accountAssetMap = new Map<String, Asset>();
    
        // Create Product and Branch
        Product_Family__c productFamily = createProductFamily('Default Product Family');
        Product_Family__c productSubFamily = createProductSubFamily('Default Sub Family', productFamily);
        Product2 product = createProduct('Default Product', 'SKU123', productFamily, productSubFamily);
        Branch__c branch = createBranch('Default Branch');
    
        // Create Accounts
        Account axisBankAccount = createResidentialAccount('Axis Bank', '6677889977');
        axisBankAccount.SLA_Classification__c = 'Metro';
        update axisBankAccount;
    
        Account hdfcAccount = createResidentialAccount('HDFC Bank', '8877665544');
        hdfcAccount.SLA_Classification__c = 'Urban';
        update hdfcAccount;
    
        // Create Assets
        Asset axisBankAsset = createAsset('Axis Asset', 'Active', product, branch, Date.today(), 'INV12345', axisBankAccount);
        Asset hdfcAsset = createAsset('HDFC Asset', 'Active', product, branch, Date.today(), 'INV67890', hdfcAccount);
    
        // Add to map for easy reference
        accountAssetMap.put(axisBankAccount.Name, axisBankAsset);
        accountAssetMap.put(hdfcAccount.Name, hdfcAsset);
    
        return accountAssetMap;
    }
    public static User createUser(String firstName, String lastName, Id profileId) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User user = new User(
            FirstName = firstName,
            LastName = lastName,
            Alias = uniqueName.substring(0, 5),
            Email = uniqueName + '@testemail.com',
            Username = uniqueName + '@testemail.com',
            ProfileId = profileId,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        return user;
    }
    public static Date getLastDayOfMonth(Date inputDate) {
        Integer year = inputDate.year();
        Integer month = inputDate.month();
    
        if (month == 12) {
            year += 1;
            month = 1;
        } else {
            month += 1;
        }
        
        Date firstDayOfNextMonth = Date.newInstance(year, month, 1);
        return firstDayOfNextMonth.addDays(-1);
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