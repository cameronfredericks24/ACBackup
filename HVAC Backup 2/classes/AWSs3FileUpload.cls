public class AWSs3FileUpload {
    
    public static string ContentType(string fileType){
        switch on fileType.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    //@future(callout=true)
    public static void UploadDocuments(Id recordId, Id documentId) {


        // Set to store ContentDocumentcontentDocumentIds
       Set<Id> contentDocumentIds = new Set<Id>();
        
        list<API_Log__c> apiLogLst = new list<API_Log__c>();
        String baseFolder = 'Data/';
        String folderName;
        String folder;
        String fileName;
        String contentType;
        String objectType;
        
        sObject fetchedRecord;
        
        try {
            
            objectType = recordId.getSObjectType().getDescribe().getName();
            system.debug('inside s3 upload - ');
            system.debug('objectType - ' + objectType);
            
            // Using switch statement to handle different sObject types
            switch on objectType {
                when 'WorkOrder' {
                    // Logic for Work Order
                    System.debug('Processing Work Order');
                    
                    fetchedRecord = fetchRecordDynamically(objectType, recordId);
                    
                    WorkOrder wo = (WorkOrder)fetchedRecord;
                    
                    // Extract month and year from the CreatedDate of the fetched record
                    folderName = wo.CreatedDate.formatGMT('yyyy-MMMM');
                    // Concatenate folderName with base folder and WorkOrderNumber
                    folder = baseFolder  + objectType + '/' +  + folderName + '/' + wo.WorkOrderNumber + '/';
                }
                when 'WorkOrderLineItem' {
                    // Logic for Work Order Line Item
                    System.debug('Processing Work Order Line Item');
                    fetchedRecord = fetchRecordDynamically(objectType, recordId);
                    
                    WorkOrderLineItem woli = (WorkOrderLineItem)fetchedRecord;
                    
                    // Extract month and year from the CreatedDate of the fetched record
                    folderName = woli.CreatedDate.formatGMT('yyyy-MMMM');
                    // Concatenate folderName with base folder and WorkOrderNumber
                    folder = baseFolder + objectType + '/' +  folderName + '/' + woli.LineItemNumber + '/';
                    
                }
                when 'Case' {
                    // Logic for Case
                    System.debug('Processing Case');
                    fetchedRecord = fetchRecordDynamically(objectType, recordId);
                    
                    Case caseItem = (Case)fetchedRecord;
                    
                    
                    // Extract month and year from the CreatedDate of the fetched record
                    folderName = caseItem.CreatedDate.formatGMT('yyyy-MMMM');
                    // Concatenate folderName with base folder and WorkOrderNumber
                    folder = baseFolder + objectType + '/' +  + folderName + '/' + caseItem.CaseNumber + '/';
                    
                }
                when 'ReturnOrder'
                {
                    // Logic for Case
                    System.debug('Processing ReturnOrder');
                    fetchedRecord = fetchRecordDynamically(objectType, recordId);
                    
                    ReturnOrder returnOrderItem = (ReturnOrder)fetchedRecord;
                    
                    
                    // Extract month and year from the CreatedDate of the fetched record
                    folderName = returnOrderItem.CreatedDate.formatGMT('yyyy-MMMM');
                    // Concatenate folderName with base folder and WorkOrderNumber
                    folder = baseFolder + objectType + '/' +  + folderName + '/' + returnOrderItem.FGR_Number__c + '/';
                    
                }
                when 'Quote'
                {
                    // Logic for Case
                    System.debug('Processing Quote');
                    fetchedRecord = fetchRecordDynamically(objectType, recordId);
                    
                    Quote quoteItem = (Quote)fetchedRecord;
                    
                    
                    // Extract month and year from the CreatedDate of the fetched record
                    folderName = quoteItem.CreatedDate.formatGMT('yyyy-MMMM');
                    // Concatenate folderName with base folder and WorkOrderNumber
                    folder = baseFolder + objectType + '/' +  + folderName + '/' + quoteItem.QuoteNumber + '/';
                    
                }
                   when 'Asset'
                {
                    // Logic for Case
                    System.debug('Processing Asset');
                    fetchedRecord = fetchRecordDynamically(objectType, recordId);
                    
                    Asset assetItem = (Asset)fetchedRecord;
                    
                    // Extract month and year from the CreatedDate of the fetched record
                    folderName = assetItem.CreatedDate.formatGMT('yyyy-MMMM');
                    // Concatenate folderName with base folder and WorkOrderNumber
                    folder = baseFolder + objectType + '/' +  + folderName + '/' + assetItem.Component_Id__c + '/';
                    
                }
                when else {
                    // Default logic if none of the above matches
                    System.debug('Unrecognized sObject type');
                }
            }
            
            System.debug('fetchedRecord - '+ fetchedRecord);
            system.debug('folderName - '+ folderName);
            system.debug('folder - '+ folder);
            
            
            // Querying ContentDocumentLinks related to the given recordId
            for (ContentDocumentLink link : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
            
            system.debug('contentDocumentIds- '+ contentDocumentIds);
            
            // Querying latest ContentVersions related to the ContentDocumentcontentDocumentIds
            // List<ContentVersion> versions = [SELECT VersionData, Title, ContentDocumentId, FileExtension 
            //                                  FROM ContentVersion 
            //                                  WHERE ContentDocumentId = :contentDocumentIds AND IsLatest = true];
            
            
            List<ContentVersion> versions = [SELECT Id,VersionData, Title, ContentDocumentId, FileExtension,Description 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId =: documentId AND IsLatest = true];
            
            system.debug('versions size - '+ versions.size());
            
            
            // Get Named Credential for S3 endpoint
            NamedCredential named = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = 'File_Upload_S3'];
            
            String fileDescription;
            
            for (ContentVersion version : versions) {
                // Encode file content to base64
                String attachmentBody = EncodingUtil.base64Encode(version.VersionData);
                // Get current date in GMT format
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                
                // Get content type based on file extension
                contentType = ContentType(version.FileExtension);
                system.debug('contentType -- '+ contentType);
                // Construct file name
                //fileName = version.Title.toLowerCase().replace(' ', '_') + '.' + version.FileExtension;

                system.debug('Title -- '+  version.Title);


                fileName = version.Title.toLowerCase()
                    .replaceAll('[^a-zA-Z0-9]', '') // Remove all non-alphanumeric characters
                    + '.' + version.FileExtension;


                fileDescription = version.Description;
                
                system.debug(' version.FileExtension -- '+  version.FileExtension);
                system.debug(' version.Title -- '+  version.Title);
                
                system.debug(' fileName -- '+  fileName);
                
                // Construct S3 file URL
                String fileUrl = named.Endpoint + '/' + fileName;
                
                system.debug(' fileUrl -- '+  fileUrl);
                
                
                // Construct S3 endpoint for callout
                String endPoint = 'callout:File_Upload_S3/' + folder + fileName;

                system.debug(' endPoint -- '+  endPoint);

                
                // Prepare HTTP headers
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Encoding', 'UTF-8');
                headers.put('Content-type', contentType);
                headers.put('ACL', 'public-read');
                headers.put('Date', formattedDateString);
                headers.put('Connection', 'keep-alive');
                
                // Create HTTP request
                HttpRequest req = new HttpRequest();
                req.setMethod('PUT');
                req.setEndpoint(endPoint);
                req.setHeader('Content-Encoding', 'UTF-8');
                req.setHeader('Content-type', contentType);
                req.setHeader('ACL', 'public-read');
                req.setHeader('Date', formattedDateString);
                req.setHeader('Connection', 'keep-alive');
                
                // Decode base64 string to Blob
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
                req.setBodyAsBlob(pdfBlob);
                
                // Send HTTP request
                Http http = new Http();
                
                // HTTPResponse res;
                HTTPResponse res = http.send(req);
                
                // Check response status
                if (res.getStatusCode() == 200) {
                    
                    system.debug('res--'+ res.getStatusCode());
                    system.debug(res.getBody());
                   
                    
                    
                    File_URL__c fileUrlRecord = New File_URL__c();
                    fileUrlRecord.Name = fileName;
                    
                    if (fileName != null && fileName.toLowerCase().contains('invoice')) {
                        fileUrlRecord.File_Type__c = 'Invoice';
                    }
                    else if( contentType == 'video/mp4'){
                        fileUrlRecord.File_Type__c = 'Video';
                    }
                    else if( contentType == 'image/jpeg' || contentType == 'image/png'){
                        fileUrlRecord.File_Type__c = 'Image';
                    }
                    fileUrlRecord.Description__c = fileDescription;
                    
                    fileUrlRecord.URL__c = named.Endpoint + '/' + folder + fileName;
                    fileUrlRecord.Type__c = contentType;
                    if(objectType == 'WorkOrder'){
                        fileUrlRecord.Work_Order__c = recordId;
                        list<WorkOrder> woLst = WorkOrderSelector.getAssetCaseFromWO(recordId);
                        if(!woLst.IsEmpty()){
                            fileUrlRecord.Case__c = woLst[0].CaseId;
                            fileUrlRecord.Asset__c   = woLst[0].AssetId;
                            list<String> statusLSt = new list<String>{'Rejected', 'Finish Good Delivered', 'Draft', 'Canceled'};
                            
                            list<ReturnOrder> fgrRecords = [SELECT Id,Status FROM ReturnOrder WHERE Work_Order__c =: recordId AND Status NOT IN : statusLSt];
                            if(!fgrRecords.isEmpty()){
                                fileUrlRecord.Return_Order__c = fgrRecords[0].Id;
                            }
                        }
                    }
                    if(objectType == 'Case'){
                        fileUrlRecord.case__c = recordId;
                    }
                    if(objectType == 'ReturnOrder'){
                        fileUrlRecord.Return_Order__c = recordId;
                    }    

                     insert fileUrlRecord;
                    
                    if(fileUrlRecord.Work_Order__c != null){
                        System.debug('Work_Order__c: ' + fileUrlRecord.Work_Order__c);
                        WorkOrder wo = new WorkOrder();
                        wo.Id = fileUrlRecord.Work_Order__c;
                        
                        if(fileUrlRecord.Name.toLowerCase().contains('signature')){
                            wo.Image_Link__c = fileUrlRecord.URL__c;
                            
                            System.debug('fileUrlRecord.Name: ' + fileUrlRecord.Name);
                            System.debug(' wo.Image_Link__c: ' +  wo.Image_Link__c);
                            
                            DELETE fileUrlRecord;
                            //delete cdl
                            DELETE [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
                            
                        }
                        
                        UPDATE wo;
                        
                    }
                    
                    // Log API response
                    API_Log__c apiResponse = new API_Log__c();
                    // apiResponse.Response_Body__c = res.getBody();
                    apiResponse.Response_Status_Code__c = String.valueOf(res.getStatusCode());
                    //apiResponse.Request_Body__c = requestBody;
                    apiResponse.Class_Name__c = 'AWSs3FileUpload';
                    apiResponse.Method_Name__c= 'UploadDocuments';
                    apiLogLst.add(apiResponse);
                    
                    //insert apiResponse;
                }
                else{
                     system.debug('res--'+ res.getStatusCode());
                    system.debug(res.getBody());

                    Exception_Log__c exceptionLog = new Exception_Log__c();
                    exceptionLog.Error_Message__c = res.getBody();
                    exceptionLog.Logged_By__c = UserInfo.getUserId();
                    exceptionLog.Source__c = 'AWSs3FileUpload-UploadDocuments';
                    exceptionLog.Record_Id__c = recordId;

                    insert exceptionLog;


                }
            }
            
            insert apiLogLst;
            
        }
        catch (Exception e) {
            // Handle exceptions
            System.debug('Exception: ' + e.getMessage());

            Exception_Log__c exceptionLog = new Exception_Log__c();
            exceptionLog.Error_Message__c = e.getMessage();
            exceptionLog.Line_Number__c = string.valueOf(e.getLineNumber());
            exceptionLog.Logged_By__c = UserInfo.getUserId();
            exceptionLog.Source__c = 'AWSs3FileUpload-UploadDocuments';
            exceptionLog.Record_Id__c = recordId;

            
            insert exceptionLog;
        }
    }
    
    private static Map<String, List<String>> getSObjectFieldsMap() {
        Map<String, List<String>> sObjectFields = new Map<String, List<String>>();
        
        // Common field
        List<String> commonFields = new List<String>{'CreatedDate'};
        
        // Specific fields for each sObject
        List<String> workOrderFields = new List<String>(commonFields);
        workOrderFields.add('WorkOrderNumber');
        sObjectFields.put('WorkOrder', workOrderFields);
        
        List<String> caseFields = new List<String>(commonFields);
        caseFields.add('CaseNumber');
        sObjectFields.put('Case', caseFields);
        
        List<String> quoteFields = new List<String>(commonFields);
        quoteFields.add('QuoteNumber');
        sObjectFields.put('Quote', quoteFields);
        
        List<String> workOrderLineItemFields = new List<String>(commonFields);
        workOrderLineItemFields.add('LineItemNumber');
        sObjectFields.put('WorkOrderLineItem', workOrderLineItemFields);

        List<String> returnOrderFields = new List<String>(commonFields);
        returnOrderFields.add('FGR_Number__c');
        sObjectFields.put('ReturnOrder', returnOrderFields);

          List<String> assetFields = new List<String>(commonFields);
        assetFields.add('Component_Id__c');
        sObjectFields.put('Asset', assetFields);
        
        system.debug('sObjectFields - 235: ' + sObjectFields);
        
        return sObjectFields;
    }
    
    public static sObject fetchRecordDynamically(String sObjectType, Id recordId) {
        Map<String, List<String>> sObjectFields = getSObjectFieldsMap();
        
        // Check if the sObjectType is configured in the map
        if (!sObjectFields.containsKey(sObjectType)) {
            System.debug('No configuration found for sObjectType: ' + sObjectType);
            return null;
        }
        
        // Retrieve the fields and fetch the record
        List<String> fieldsToRetrieve = sObjectFields.get(sObjectType);
        return UtilityClass.getRecordById(sObjectType, fieldsToRetrieve, recordId);
    }
    
}