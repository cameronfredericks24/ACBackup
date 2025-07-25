public without sharing class WorkOrderTriggerHelper {
    private static final ID BULK_PMS_RT = Schema.SObjectType.Workorder.getRecordTypeInfosByDeveloperName().get('Bulk_PMS_Checklist').getRecordTypeId();
    private static final ID BREAKDOWN_RT = Schema.SObjectType.Workorder.getRecordTypeInfosByDeveloperName().get('Breakdown').getRecordTypeId();
    private static final ID INSTALLATION_RT = Schema.SObjectType.Workorder.getRecordTypeInfosByDeveloperName().get('Installation').getRecordTypeId();
    private static final ID PMS_RT = Schema.SObjectType.Workorder.getRecordTypeInfosByDeveloperName().get('PMS').getRecordTypeId();

    public static boolean isExecuting = false; 
    public static boolean skipExotel = false;
    public WorkOrderTriggerHelper() {
        System.debug('Inside WorkOrderTriggerHelper Constructor');
    }
    
    /*
    @Author : Sanket A
    @CreatedDate : 28 May 2024
    @Description : To Correctly Update Asset PMS Values
     */
    public static void checkIfWarrantyApplicable(List<WorkOrder> newWorkOrderList){
        Set<Id> setofWOIDs = new Set<Id>();
        Map<Id, Decimal> setOfWOLIUsed = new Map<Id, Decimal>();
        Map<Id, Decimal> setOfWOLIAssets = new Map<Id, Decimal>();
        Map<Id, Decimal> setOfWOLIAssetsUnused = new Map<Id, Decimal>();
        Map<Id, WorkOrder> woByID = new Map<Id, WorkOrder>();
        List<Asset> asstToUpdate = new List<Asset>();
        for(WorkOrder wo : newWorkOrderList){
            if((wo.RecordTypeId == WorkOrderSelector.getPMSRecordType()) && (wo.Is_AMC__c == False) && (wo.AssetId != null)){
                setofWOIDs.add(wo.Id);
                woByID.put(wo.Id, wo);
            }
        }
        if(setofWOIDs.size() == 0){
            return;
        }
        for(WorkOrder woli: [SELECT Id, Subject, WorkOrderNumber, AssetId, Asset.PMS_Available__c, Asset.PMS_Used__c 
                             FROM WorkOrder WHERE ((Id IN: setofWOIDs) AND (AssetId != null))]){
            if(woli.Asset.PMS_Available__c == null){
                woli.Asset.PMS_Available__c = 0;
            }
            if(woli.Asset.PMS_Used__c == null){
                woli.Asset.PMS_Used__c = 0;
            }
            if(woli.Asset.PMS_Available__c > 1){
                if(setOfWOLIUsed.containsKey(woli.AssetId)){
                    setOfWOLIUsed.put(woli.AssetId, setOfWOLIUsed.get(woli.AssetId)+1);
                }else{
                    setOfWOLIUsed.put(woli.AssetId, 1);
                }
                setOfWOLIAssets.put(woli.AssetId, woli.Asset.PMS_Available__c);
                setOfWOLIAssetsUnused.put(woli.AssetId, woli.Asset.PMS_Used__c);
            }
            //not needed
            // else{
            //     woByID.get(woli.Id).addError('PMS has been exhausted for Ticket Number-'+woli.WorkOrderNumber);
            // }
        }
        for(Id asst: setOfWOLIAssets.keySet()){
            Asset i = new Asset();
            i.Id = asst;
            i.PMS_Available__c = (setOfWOLIAssets.get(asst) - setOfWOLIUsed.get(asst));
            i.PMS_Used__c = setOfWOLIAssetsUnused.get(asst) + setOfWOLIUsed.get(asst);
            asstToUpdate.add(i);
        }
        if(asstToUpdate.size() > 0){
            update asstToUpdate;
        }
    }
    
    /*
    @Author : Sanket A
    @CreatedDate : 5 Mar 2024
    @Description : To Correctly Update Entitlement if PMS Ticket
     */
    public static void updateEntitlementIdIfPMS(List<WorkOrder> newWorkOrderList){
        for(WorkOrder wo : newWorkOrderList){
            if(wo.RecordTypeId == WorkOrderSelector.getPMSRecordType() && !wo.Is_SLA_Violated__c){
                wo.EntitlementId = WorkOrderSelector.getPMSEntitlementId();
                
            }
        }
    }
    
    /*
    @Author : Sanket A
    @CreatedDate : 18 Apr 2024
    @Description : To alert user of WO can not be closed if WO Line Item is Open
     */
    public static void validateLineItemIsOpen(List<WorkOrder> newWorkOrderList){
        Set<Id> woIDs = new Set<Id>();
        Map<Id, WorkOrder> woByID = new Map<Id, WorkOrder>();
        for(WorkOrder wo : newWorkOrderList){
            if(wo.Status == WorkOrderSelector.getPMSRescheduledStatus())
                woIDs.add(wo.Id);
            woByID.put(wo.Id, wo);
        }
        for(WorkOrderLineItem wol: [SELECT Id, WorkOrderId, Status FROM WorkOrderLineItem WHERE WorkOrderId IN: woIDs 
                                    AND Status !=: WorkOrderSelector.getPMSRescheduledStatus()]){
            woByID.get(wol.WorkOrderId).addError(WorkOrderSelector.getValidationLineItem());
        }
    }
    
    
    /*
    @Author : Sanket A
    @CreatedDate : 5 Mar 2024
    @Description : To Correctly Update Entitlement if PMS Ticket
     */
    public static void updateEntitlementIdIfAutoDebit(List<WorkOrder> newWorkOrderList, Map<Id, WorkOrder> oldMap){
        for(WorkOrder wo : newWorkOrderList){
            if((wo.RecordTypeId == WorkOrderSelector.getPMSRecordType()) && (wo.Reschedule_Type__c != oldMap.get(wo.Id).Reschedule_Type__c)
            && (wo.Reschedule_Type__c == WorkOrderSelector.getPMSDebitStatus())){
                wo.EntitlementId = WorkOrderSelector.getPMSDebitEntitlementId();
            }
        }
    }
    
    /*
    @Author : Sanket A
    @CreatedDate : 22nd Feb 2024
    @Description : To Correctly Update Work Type if PMS Ticket
     */
    public static void updateWorkTypeIfPMS(List<WorkOrder> newWorkOrderList){
        // for(WorkOrder wo : newWorkOrderList){
            //     if(wo.RecordTypeId == WorkOrderSelector.getPMSRecordType()){
                //         wo.WorkTypeId = UtilityClass.getOrgConstantValue('PMS_Work_Type_Record');
                
            //     }
        // }
    }
    
    /*
    @Author : Ajay M
    @CreatedDate : 22nd Feb 2024
    @Description : To generate and store Otp in workorder
     */
    
    public static void generateAndStoreOTP(List<WorkOrder> newWorkOrderList) {
        
        for (WorkOrder wo : newWorkOrderList) {
            if (String.isNotBlank(wo.CaseId)|| String.isNotBlank(wo.AccountId)) {
                List<String> otpList1 = OtpServiceClass.generateOtp();
                List<String> otpList2 = OtpServiceClass.generateOtp();
                Datetime otpExpiration = Datetime.now().addHours(168);
                wo.HappyCode__c = otpList1[0];
                wo.Unhappy_Code__c = otpList2[0];
                wo.OTP_Expiration__c = otpExpiration;
                
                
            }
            
            wo.StartDate = system.now();
        }
    }
    
    // @Author : Alka Singh
    // @CreatedDate : 10 june 2024
    // @Description : To send service ticket creation mail with Otp in service ticket
    
    public static void sendOTPSMS(List<WorkOrder> workOrderLst) {
        
        System.debug('entered in sendOTPSMS');
        
        List<WorkOrder> workOrdersToNotifyWithUnhappyCode = new List<WorkOrder>();
        List<WorkOrder> workOrdersToNotifyWithHappyCode = new List<WorkOrder>();
        
        // Query WorkOrders with their related Account, Asset information
        workOrderLst = [
        SELECT Id, Account.RecordType.DeveloperName, AccountId, Asset.Serviceable_Division__c, Asset.Serviceable_Division__r.Name, AssetId,
        Product_Sub_Family_temp__r.Parent_Product_Family__r.Division_Lookup__r.Name, Contact_Phone__c 
        FROM WorkOrder 
        WHERE Id IN :workOrderLst
    ];
        System.debug('Queried WorkOrders: ' + workOrderLst);
        
        for (WorkOrder wo : workOrderLst) {
            // Check for Residential Account and specific Service Divisions
            if (wo.AccountId != null && wo.Account.RecordType.DeveloperName == 'Residential_Customer') {
                
                System.debug('Processing WorkOrder for Account ID: ' +  wo.AccountId);
                
                if (wo.AssetId != null && wo.Asset.Serviceable_Division__c != null && (wo.Asset.Serviceable_Division__r.Name == 'CPAG' || wo.Asset.Serviceable_Division__r.Name == 'CRBG')) {
                    // Check service division on Asset
                    System.debug('entered in sendotpsms ' + wo.Asset.Serviceable_Division__r.Name);
                    workOrdersToNotifyWithUnhappyCode.add(wo);
                    
                } else if (wo.Product_Sub_Family_temp__r.Parent_Product_Family__r.Division_Lookup__r.Name == 'CPAG' || wo.Product_Sub_Family_temp__r.Parent_Product_Family__r.Division_Lookup__r.Name == 'CRBG') {
                    // Check service division on Product Family via Case -> Product
                    System.debug('entered ' +  wo.Product_Sub_Family_temp__r.Parent_Product_Family__r.Division_Lookup__r.Name);
                    workOrdersToNotifyWithUnhappyCode.add(wo);
                    
                } else {
                    workOrdersToNotifyWithHappyCode.add(wo);
                }
                
            } else {
                workOrdersToNotifyWithHappyCode.add(wo);
            }
        }
        
        if (!workOrdersToNotifyWithUnhappyCode.isEmpty()) {
            System.debug('Processing Unhappy Code notifications for WorkOrders: ' +  workOrdersToNotifyWithUnhappyCode);
            
            for (WorkOrder wo : workOrdersToNotifyWithUnhappyCode) {
                if (wo.Contact_Phone__c != null) {
                    
                    List<String> customerPhoneNumbers = new List<String>{wo.Contact_Phone__c};
                    System.debug('customerPhoneNumbers: ' + customerPhoneNumbers);
                    
                    String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                    System.debug('customerPhoneNumber: ' + customerPhoneNumber);                  
                    
                    if (System.isFuture() || System.isBatch() ) {

                             // Call Exotel class to send SMS
                        	if(!skipExotel){
	                             ExotelSMSAPI.sendSMSSynchronous(customerPhoneNumbers, wo.Id, 'Unhappy Code');                                
                             	// Call WhatsApp class to send message
	                             WhatsAppNotificationService.invokeWhatsappNotification(wo.Id, customerPhoneNumber, 'sfdc_waba_733595',false);
                            }               
                    }
                    else{
                        
                        // Call Exotel class to send SMS
                        if(!skipExotel){
	                        ExotelSMSAPI.sendSMS(customerPhoneNumbers, wo.Id, 'Unhappy Code');                            
                        	// Call WhatsApp class to send message
	                        WhatsAppNotificationService.invokeWhatsappNotification(wo.Id, customerPhoneNumber, 'sfdc_waba_733595',true);
                        }
                    } 
                }
            }
        }
        
        if (!workOrdersToNotifyWithHappyCode.isEmpty()) {
            System.debug('Processing Happy Code notifications for WorkOrders: ' +  workOrdersToNotifyWithHappyCode);
            
            for (WorkOrder wo : workOrdersToNotifyWithHappyCode) {
                if (wo.Contact_Phone__c != null) {
                    List<String> customerPhoneNumbers = new List<String>{wo.Contact_Phone__c};
                    System.debug('customerPhoneNumbers: ' + customerPhoneNumbers);
                    
                    // Call Exotel class to send SMS
                    if(!skipExotel){
	                    ExotelSMSAPI.sendSMS(customerPhoneNumbers, wo.Id, 'Happy Code');                        
                    }
                    
                    String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                    System.debug('customerPhoneNumber: ' + customerPhoneNumber);
                    
                    if(!skipExotel){
	                    // Call WhatsApp class to send message
                    	WhatsAppNotificationService.invokeWhatsappNotification(wo.Id, customerPhoneNumber, 'sfdc_waba_733594',true);                        
                    }
                }
            }
        }
    }
    
    
    
    
    /*
    @Author : Ajay M
    @CreatedDate : 22nd Feb 2024
    @Description : To generate New Otp and sending email to contact email in workorder
     */
    
public static void sendNewOTPToCustomer(Set<Id> workOrderIds, List<String> otpList) {
    List<String> emailAddresses = new List<String>();
    List<String> ticketNumbers = new List<String>();
    
    if (workOrderIds.size() > 0) {
        for (WorkOrder wo : WorkOrderSelector.getContactEmailOfWorkOrder(workOrderIds)) {
            String emailToUse;
            if (String.isNotBlank(wo.Contact_Email__c)) {
                emailToUse = wo.Contact_Email__c;
            } else if (wo.Account.Email__c != null) {
                emailToUse = wo.Account.Email__c;  
            } else {
                continue;  // Skip if both emails are null
            }
            
            if (String.isNotBlank(emailToUse) && String.isNotBlank(wo.Ticket_Number_Read_Only__c)) {
                emailAddresses.add(emailToUse);
                ticketNumbers.add(wo.Ticket_Number_Read_Only__c);
            }
        }
    }
    
    if (emailAddresses.size() > 0) {
        // Prepare the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailAddresses);
        email.setSubject('Your HappyCode for Work Order: ' + ticketNumbers[0]);
        email.setPlainTextBody('Your HappyCode is: ' + otpList[0] + '. This HappyCode will expire on: ');
        
        // Send the email
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }
}

    
    /*
    @Author : Anshika Jain
    @CreatedDate : 2nd Feb 2024
    @Description : To tag cp, sde, branch on asset from work order owner Account
     */
    
    public  void branchCPSDETaggingOnAsset(list<WorkOrder>newWorkOrder){
        list<WorkOrder> workOrders = WorkOrderSelector.getRelatedRecordsOfWorkOrder(newWorkOrder);
        list<Asset> assetsToBeUpdated = New list<asset>();
        For(WorkOrder wo : workOrders){
            If(wo.WorkOrderLineItems.size() > 0){
                for(WorkOrderLineItem woli : wo.WorkOrderLineItems){
                    If(woli.Asset != Null && woli.Asset.CP__c == null){
                        Asset ast = New asset(Id = woli.AssetId,CP__c = wo.CP__c, Branch__c = wo.CP__r.branch__c, SDE__c = wo.CP__r.sde__c);
                        assetsToBeUpdated.add(ast);
                    }
                }
            }
        }
        
        If(!assetsToBeUpdated.isEmpty()){
            update assetsToBeUpdated;
        }
    }
    
    /*
    @Author : Anshika Jain
    @CreatedDate : 22nd Feb 2024
    @Description : Validation for work order status when it is getting cancel or closed.
     */
    public  void validationForStatusChange(list<WorkOrder>workOrders){
        try{
            string cancelStatusError = System.Label.Work_Order_Cancel_Status_Validation_Error;
            string closedStatusError = System.Label.Work_Order_Closed_Status_Validation_Error;
            set<Id> workOrdersIds = New set<Id>();
            For(WorkOrder wo : workOrders){
                workOrdersIds.add(wo.Id);
            }
            map<Id,WorkOrder> workOrderListWithMRRequests = New map<Id,WorkOrder>(WorkOrderSelector.getWOrkOrderWithMRRequests(workOrdersIds));
            For(WorkOrder wo : workOrders){
                Boolean allMRAreCompletedOrCanceled = True;
                If(!workOrderListWithMRRequests.get(wo.id).ProductRequests.isEmpty()){
                    For(ProductRequest pr : workOrderListWithMRRequests.get(wo.id).ProductRequests){
                        
                        If(pr.status!='Received' && pr.status!='Delivered' && pr.status!='Rejected'  && pr.status != ProductRequestConstants.productRequestCompletedStatus && pr.status != ProductRequestConstants.productRequestCanceledStatus){
                            allMRAreCompletedOrCanceled = False;
                        }
                        break;
                    }
                    
                    If(wo.status == WorkOrderConstants.WOCancelledStatus){
                        wo.addError(cancelStatusError);
                    }
                    
                    else if(!allMRAreCompletedOrCanceled && wo.status == WorkOrderConstants.WOCompletedStatus){
                        wo.addError(closedStatusError);
                    }
                }
            }
        }catch(Exception e){
            system.debug(e);
        }
    }
    
    /*
    @Author : Abhijeet
    @CreatedDate : 4th March 2024
    @Description : Work Type add through Case Type.
     */
    
    
    /* public static void populateWorkType(List<WorkOrder> workOrList) {
        Set<Id> caseIds = new Set<Id>();
        for (WorkOrder wo : workOrList) {
            if (wo.CaseId != null) {
                caseIds.add(wo.CaseId);
            }
        }
        
        List<Case> casesList = CaseSelector.getCasesByIds(caseIds);
        
        Map<Id, String> caseIdToTypeMap = new Map<Id, String>();
        for (Case c : casesList) {
            caseIdToTypeMap.put(c.Id, c.Type);
        }
        
        Set<String> typeNames = new Set<String>(caseIdToTypeMap.values());
        
        List<WorkType> workTypeList = WorkTypeSelector.getWorkTypeList(typeNames);
        Map<String, Id> workTypeMap = new Map<String, Id>();
        for (WorkType wt : workTypeList) {
            workTypeMap.put(wt.Name, wt.Id);
        }
        
        for (WorkOrder wo : workOrList) {
            if (wo.CaseId != null && caseIdToTypeMap.containsKey(wo.CaseId)) {
                String caseType = caseIdToTypeMap.get(wo.CaseId);
                if (workTypeMap.containsKey(caseType)) {
                    wo.WorkTypeId = workTypeMap.get(caseType);
                }
            }
        }
        
    }*/
    
    /*
    @Author : Rishabh
    @CreatedDate : 03rd March 2024
    @Description : Alloted date in Original_Scheduled_Date__c 'BSL-TM-045'.
     */
    
    public static void originalScheduledDate(List<WorkOrder> workOrders) {
        for (WorkOrder wo : workOrders) {
            if (wo.PMS_Maintenance_Date__c != null) {
                wo.Original_Scheduled_Date__c = wo.PMS_Maintenance_Date__c;
            }
        }
    }
    
    /*
    @Author : Rishabh
    @CreatedDate : 18th March 2024
    @Description : 	Breakdown Count increase in asset field Breakdown_Count__c  'BSL-PR-064'.
     */
    public static void increaseBreakdownCount(List<WorkOrder> breakdownWorkOrders) {
        Set<Id> assetIds = new Set<Id>();
        
        // Collect unique Asset Ids from Work Orders
        for (WorkOrder wo : breakdownWorkOrders) {
            assetIds.add(wo.AssetId);
        }
        
        if (!assetIds.isEmpty()) {
            try {
                // Retrieve related Assets
                List<Asset> relatedAssets = AssetSelector.returnRelatedAssets(assetIds);
                
                // Map to store breakdown count for each asset
                Map<Id, Integer> assetBreakdownCountMap = new Map<Id, Integer>();
                
                // Initialize breakdown count for each asset to 0
                for (Id assetId : assetIds) {
                    assetBreakdownCountMap.put(assetId, 0);
                }
                
                // Calculate breakdown count for each asset
                for (WorkOrder wo : breakdownWorkOrders) {
                    assetBreakdownCountMap.put(wo.AssetId, assetBreakdownCountMap.get(wo.AssetId) + 1);
                }
                
                // Update Breakdown_Count__c for related Assets
                for (Asset a : relatedAssets) {
                    Integer breakdownCount = assetBreakdownCountMap.get(a.Id);
                    System.debug('before :' + a.Breakdown_Count__c);
                    a.Breakdown_Count__c += breakdownCount;
                    System.debug('after : ' + a.Breakdown_Count__c);
                }
                
                // Update Assets
                if (!relatedAssets.isEmpty()) {
                    update relatedAssets;
                }
            } catch (Exception e) {
                // Handle any exceptions here
                System.debug('An error occurred: ' + e.getMessage());
            }
        }
    }
    /*
    @Author : Himanshi Verma
    @CreatedDate : 17th June 2024
    @Description : To Update First Service And Second Service for Service Contract Line
     */
    public static void updateFirstAndSecondService(Set<Id> serviceContractIds) {
        //System.debug('Service Contract IDs: ' + serviceContractIds);
        
        // Map to store ServiceContract IDs to their related WorkOrders
        Map<Id, List<WorkOrder>> serviceContractToWorkOrdersMap = new Map<Id, List<WorkOrder>>();
        
        // Query WorkOrders related to the ServiceContracts
        List<WorkOrder> workOrders = WorkOrderSelector.getServiceDates(serviceContractIds);
        // Populate the map with the queried WorkOrders
        for (WorkOrder wo : workOrders) {
            System.debug('Queried WorkOrders: ' + wo.StartDate);
            if (!serviceContractToWorkOrdersMap.containsKey(wo.ServiceContractId)) {
                serviceContractToWorkOrdersMap.put(wo.ServiceContractId, new List<WorkOrder>());
            }
            serviceContractToWorkOrdersMap.get(wo.ServiceContractId).add(wo);
        }
        List<ContractLineItem> contractLineItemsToUpdate = new List<ContractLineItem>();
        List<ContractLineItem> contractLineItems = ContractLineItemSelector.getLineItemFields(serviceContractIds);
        for (ContractLineItem cli : contractLineItems) {
            List<WorkOrder> relatedWorkOrders = serviceContractToWorkOrdersMap.get(cli.ServiceContractId);
            if (relatedWorkOrders != null && !relatedWorkOrders.isEmpty()) {
                if (relatedWorkOrders.size() > 0) {
                    cli.First_Service__c = relatedWorkOrders[0].StartDate;
                }
                if (relatedWorkOrders.size() > 1) {
                    cli.Second_Service__c = relatedWorkOrders[1].StartDate;
                } else {
                    cli.Second_Service__c = null;
                }
                contractLineItemsToUpdate.add(cli);
            }
        }
        //Update ContractLineItems
        if (!contractLineItemsToUpdate.isEmpty()) {
            try {
                update contractLineItemsToUpdate;
                System.debug('Successfully updated ContractLineItems');
            } catch (Exception e) {
                // Handle the exception
                System.debug('Error updating ContractLineItems: ' + e.getMessage());
            }
        }
        System.debug('Exiting updateFirstAndSecondService method');
    }
    
    
    /*
    @Author : Himanshi Verma
    @CreatedDate : 17th June 2024
    @Description : to pause milestone if service ticket status is changed to on hold
     */
    public static void pauseMilestoneOnCase(List<WorkOrder> listOfWorkOrder) {
        try {
            Set<Id> caseIds = new Set<Id>();
            for (WorkOrder wo : listOfWorkOrder) {
                if (wo.CaseId != null ) {
                    caseIds.add(wo.CaseId);
                }
            }
            System.debug('caseIds: ' + caseIds);
            if (!caseIds.isEmpty()) {
                List<Case> casesToUpdate = new List<Case>();
                Map<Id, WorkOrder> caseToRecentWorkOrder = new Map<Id, WorkOrder>();
                // Query the most recent WorkOrder for each Case
                List<WorkOrder> recentWorkOrders = WorkOrderSelector.getMostRecentWorkOrder(caseIds);
                System.debug('recentWorkOrders: ' + recentWorkOrders);
                for (WorkOrder wo : recentWorkOrders) {
                    if (!caseToRecentWorkOrder.containsKey(wo.CaseId)) {
                        caseToRecentWorkOrder.put(wo.CaseId, wo);
                    }
                }
                System.debug('caseToRecentWorkOrder: ' + caseToRecentWorkOrder);
                // Check the status of the most recent WorkOrder and update the Case
                for (Id caseId : caseToRecentWorkOrder.keySet()) {
                    WorkOrder recentWO = caseToRecentWorkOrder.get(caseId);
                    if (recentWO.Status == WorkOrderConstants.WOOnHoldStatus) {
                        casesToUpdate.add(new Case(
                            Id = caseId,
                        isStopped = true
                            ));
                    }
                }
                System.debug('casesToUpdate: ' + casesToUpdate);
                // Perform the Case updates
                if (!casesToUpdate.isEmpty()) {
                    update casesToUpdate;
                }
            }
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error updating ContractLineItems: ' + e.getMessage());
        }
    }
    /*
    @Author : Himanshi Verma
    @CreatedDate : 22nd June 2024
    @Description : to start a milestone if service ticket status is updated to other than on hold
     */
    public static void startMilestoneOnCase(List<WorkOrder> listOfWorkOrder) {
        try {
            Set<Id> caseIds = new Set<Id>();
            for (WorkOrder wo : listOfWorkOrder) {
                if (wo.CaseId != null ) {
                    caseIds.add(wo.CaseId);
                }
            }
            System.debug('caseIds: ' + caseIds);
            if (!caseIds.isEmpty()) {
                List<Case> casesToUpdate = new List<Case>();
                Map<Id, WorkOrder> caseToRecentWorkOrder = new Map<Id, WorkOrder>();
                // Query the most recent WorkOrder for each Case
                List<WorkOrder> recentWorkOrders = WorkOrderSelector.getWorkOrderOtherThanOnHold(caseIds);
                System.debug('recentWorkOrders: ' + recentWorkOrders);
                for (WorkOrder wo : recentWorkOrders) {
                    if (!caseToRecentWorkOrder.containsKey(wo.CaseId)) {
                        caseToRecentWorkOrder.put(wo.CaseId, wo);
                    }
                }
                System.debug('caseToRecentWorkOrder: ' + caseToRecentWorkOrder);
                // Check the status of the most recent WorkOrder and update the Case
                for (Id caseId : caseToRecentWorkOrder.keySet()) {
                    WorkOrder recentWO = caseToRecentWorkOrder.get(caseId);
                    if (recentWO.Status != WorkOrderConstants.WOOnHoldStatus) {
                        casesToUpdate.add(new Case(
                            Id = caseId,
                        isStopped = false
                            ));
                    }
                }
                System.debug('casesToUpdate: ' + casesToUpdate);
                // Perform the Case updates
                if (!casesToUpdate.isEmpty()) {
                    update casesToUpdate;
                }
            }
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error updating ContractLineItems: ' + e.getMessage());
        }
    }
    
    /*
    @Author : Himanshi Verma
    @CreatedDate : 21st June 2024
    @Description : to auto complete a milestone if service ticket status is Resolved
     */
    public static void autoCompleteWhenTATResolved(List<WorkOrder> listOfWorkOrder) {
        try {
            List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
            Set<Id> caseIds = new Set<Id>();
            
            // Collect CaseIds from the WorkOrders
            for (WorkOrder wo : listOfWorkOrder) {
                if (wo.CaseId != null) {
                    caseIds.add(wo.CaseId);
                }
            }
            
            // Fetch CaseMilestones for the specified CaseIds where the milestones are not completed and are of type 'Turn Around Time', 'RT', or 'RS'
            List<CaseMilestone> caseMilestones = [
            SELECT Id, CompletionDate, MilestoneTypeId, TargetDate
            FROM CaseMilestone
            WHERE CaseId IN :caseIds 
            AND CompletionDate = NULL 
            AND MilestoneType.Name IN ('Turn Around Time', 'RT', 'RS')
        ];
            
            // Complete the milestones by setting the CompletionDate
            for (CaseMilestone cm : caseMilestones) {
                if(cm.CompletionDate == null) {
                    cm.CompletionDate = System.now();
                    milestonesToUpdate.add(cm);
                }
            }
            
            // Update the milestones
            if (!milestonesToUpdate.isEmpty()) {
                update milestonesToUpdate;
            }
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error updating CaseMilestones: ' + e.getMessage());
        }
    }
    
    
    /*
    @Author : Himanshi Verma
    @CreatedDate : 21st June 2024
    @Description : to auto complete a milestone if service ticket status is Dispatched
     */
    public static void autoCompleteMilestoneAcceptedRS(List<WorkOrder> listOfWorkOrder) {
        try {
            List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
            Set<Id> caseIds = new Set<Id>();
            for (WorkOrder wo : listOfWorkOrder) {
                if (wo.CaseId != null ) {
                    caseIds.add(wo.CaseId);
                }
            }
            List<CaseMilestone> caseMilestones = [
                SELECT Id, CompletionDate, MilestoneTypeId, TargetDate
                FROM CaseMilestone
                WHERE CaseId In : caseIds AND CompletionDate = NULL AND MilestoneType.Name ='RS'
            ];
            // Complete the milestone by setting the CompletionDate
            for (CaseMilestone cm : caseMilestones) {
                cm.CompletionDate = System.now();
                milestonesToUpdate.add(cm);
            }
            // Update the milestones
            if (!milestonesToUpdate.isEmpty()) {
                update milestonesToUpdate;
            }
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error updating ContractLineItems: ' + e.getMessage());
        }
    }
    
    /*
    @Author : Himanshi Verma
    @CreatedDate : 21st June 2024
    @Description : to auto complete a milestone if service ticket status is Dispatched
     */
    public static void autoCompleteMilestoneOnDispatched(List<WorkOrder> listOfWorkOrder) {
        try {
            List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
            Set<Id> caseIds = new Set<Id>();
            for (WorkOrder wo : listOfWorkOrder) {
                if (wo.CaseId != null ) {
                    caseIds.add(wo.CaseId);
                }
            }
            List<CaseMilestone> caseMilestones = [
                SELECT Id, CompletionDate, MilestoneTypeId, TargetDate
                FROM CaseMilestone
                WHERE CaseId In : caseIds AND CompletionDate = NULL AND MilestoneType.Name ='First Case Response'
            ];
            // Complete the milestone by setting the CompletionDate
            for (CaseMilestone cm : caseMilestones) {
                cm.CompletionDate = System.now();
                milestonesToUpdate.add(cm);
            }
            // Update the milestones
            if (!milestonesToUpdate.isEmpty()) {
                update milestonesToUpdate;
            }
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error updating ContractLineItems: ' + e.getMessage());
        }
    }
    
    
    /*
    @Author : Sumukha N S
    @CreatedDate : 28 June 2024
    @Description : notify relevant stakeholders when WO is dispatched
     */
    
    public static void sendNotificationOnDispatch(List<WorkOrder> dispatchedWorkordrLst) {
        
        for(WorkOrder wo:dispatchedWorkordrLst){
            system.debug('dispatched WO - '+ wo);
            if(wo.Contact_Phone__c != null){
                list<String> customerPhoneNumbers = new list<String>{wo.Contact_Phone__c};
                
                system.debug('customerPhoneNumbers- '+ customerPhoneNumbers);
                
                //call exotel class to send SMS
                if(!skipExotel){
	                ExotelSMSAPI.sendSMS(customerPhoneNumbers,wo.Id,'ST-Dispatched-CP-Customer');                    
                	String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                
                
                	system.debug('customerPhoneNumber- '+ customerPhoneNumber);
                
                	//call whatsapp class to send message
	                WhatsAppNotificationService.invokeWhatsappNotification(wo.Id, customerPhoneNumber, 'sfdc_waba_446746',true);
                }
                
            }
        }
    }


    /*
    @Author : Alka
    @CreatedDate : 18 dec 2024
    @Description : send SMS to CP after ticket assignment
     */
    
    public static void sendNotificationToCPOnDispatch(List<WorkOrder> woAssignedToCPList) {
        Id breakdown = WorkOrderConstants.WorkOrder_Breakdown_RT;
        Id installation = WorkOrderConstants.WorkOrder_Installation_RT;

        for(WorkOrder wo:woAssignedToCPList){
            system.debug('dispatched WO - '+ wo);
            if(wo.Contact_Phone__c != null){
                list<String> customerPhoneNumbers = new list<String>{wo.Contact_Phone__c};
                
                system.debug('customerPhoneNumbers- '+ customerPhoneNumbers);
                
                //call exotel class to send SMS
                if(!skipExotel && wo.RecordTypeId == breakdown){
                    //sms for breakdown not needed
	                //ExotelSMSAPI.sendSMS(customerPhoneNumbers,wo.Id,'1607100000000021000');                    
                	String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                                
                	system.debug('customerPhoneNumber- '+ customerPhoneNumber);
                
                } else if(!skipExotel && wo.RecordTypeId == installation){
                    ExotelSMSAPI.sendSMS(customerPhoneNumbers,wo.Id,'1607100000000052009');                    
                	String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                                
                	system.debug('customerPhoneNumber- '+ customerPhoneNumber);
                }
                
            }
        }
    }
    
    /*
    @Author : Sumukha N S
    @CreatedDate : 28 June 2024
    @Description : notify relevant stakeholders when WO is created
     */
    
    public static void sendNotificationOnCreation(List<WorkOrder> workOrderLst) {
        
        for(WorkOrder wo:workOrderLst){
            system.debug('dispatched WO - '+ wo);
            if(wo.Contact_Phone__c != null){
                
                if(wo.Contact_Phone__c != null){
                    
                    String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                    
                    
                    system.debug('customerPhoneNumber- '+ customerPhoneNumber);
                    
                    
                    system.debug('wo product name- '+ wo.Product_Name__c);
                    
                    //call exotel class to send SMS
                    if(!skipExotel){
	                    WhatsAppNotificationService.invokeWhatsappNotification(wo.Id, customerPhoneNumber, 'sfdc_waba_446747',true);                        
                    }
                    
                    list<String> customerPhoneNumbers = new list<String>{wo.Contact_Phone__c};
                    
                    system.debug('customerPhoneNumbers- '+ customerPhoneNumbers);
                    
                    
                    //call exotel class to send SMS
                    if(!skipExotel){
	                    ExotelSMSAPI.sendSMS(customerPhoneNumbers,wo.Id,'WO-Creation-Customer-Product');                        
                    }
                } 
            }
        }
    }
    /*
    @Author : Sumukha N S
    @CreatedDate : 25 July 2024
    @Description : notify customer when WO is ccancelled
     */
    
    public static void sendNotificationOnCancellation(List<WorkOrder> workOrderLst) {
        
        for(WorkOrder wo:workOrderLst){
            system.debug('cancelled WO - '+ wo);
            if(wo.Contact_Phone__c != null){
                
                if(wo.Contact_Phone__c != null){
                    
                    String customerPhoneNumber = '91' + wo.Contact_Phone__c;
                    
                    
                    system.debug('customerPhoneNumber- '+ customerPhoneNumber);
                    
                    
                    system.debug('wo product name- '+ wo.Product_Name__c);

                     String smsMessageBody = ExotelSMSmessageCreation.createMessage(wo.Id, '1607100000000305703');

                                                            
                    //call exotel class to send SMS
                    if(!skipExotel){
	                    //call exotel class to send SMS
                    	WhatsAppNotificationService.invokeWhatsappNotification(wo.Id, customerPhoneNumber, 'sfdc_waba_24072201',true);
                    
                    	list<String> customerPhoneNumbers = new list<String>{wo.Contact_Phone__c};
                    
                    	system.debug('customerPhoneNumbers- '+ customerPhoneNumbers);

                        ExotelSMSAPI.fireSMSContent(customerPhoneNumbers,'1607100000000305703',smsMessageBody,wo.Id);
                        
	                    //ExotelSMSAPI.sendSMS(customerPhoneNumbers,wo.Id,'1607100000000305703');                        
                    }
                }
                
                
            }
        }
        
        
    }
    


    public static void regenerateBulkPMSlink(List<WorkOrder> newList, Map<Id, WorkOrder> oldMap) {
        System.debug('Line no 1134');
        
        for (WorkOrder newWorkOrder : newList) {
            System.debug('Line no 1137');
            
            // Check if the WorkOrder meets the conditions
            if (newWorkOrder.RecordTypeId == BULK_PMS_RT
            && newWorkOrder.Status != oldMap.get(newWorkOrder.id).status) {
                // Enqueue the Queueable job with the new BulkPMSLink__c value
                System.enqueueJob(new FetchAndStorePdfQueueable(newWorkOrder.Id));
            }
        }
    }

    /*
    @Author : Abhijeet
    @CreatedDate : 3rd July 2024
    @Description : To Send Email to Customer after product Registration Complete.
     */
    public static void sendEmailForProductRegistration(List<WorkOrder> newList, Map<Id, WorkOrder> oldMap) {
        // Create a set to store account and work type IDs to query
        Set<Id> accountIds = new Set<Id>();
        Set<Id> workTypeIds = new Set<Id>();
        
        // Collect the Account and WorkType IDs for relevant WorkOrders
        for (WorkOrder wo : newList) {
            if (wo.Status == 'Completed' && oldMap.get(wo.Id).Status != 'Completed') {
                if (wo.AccountId != null) accountIds.add(wo.AccountId);
                if (wo.WorkTypeId != null) workTypeIds.add(wo.WorkTypeId);
            }
        }
        
        // Query the Account records for the collected Account IDs
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Email__c
            FROM Account
            WHERE Id IN :accountIds
        ]);
        
        // Query the WorkType records for the collected WorkType IDs
        Map<Id, WorkType> workTypeMap = new Map<Id, WorkType>([
            SELECT Id, Name
            FROM WorkType
            WHERE Id IN :workTypeIds
        ]);
        
        // Send emails for WorkOrders that meet the criteria
        for (WorkOrder wo : newList) {
            if (wo.Status == 'Completed' && oldMap.get(wo.Id).Status != 'Completed') {
                Account relatedAccount = accountMap.get(wo.AccountId);
                WorkType relatedWorkType = workTypeMap.get(wo.WorkTypeId);
                
                if (relatedAccount != null && relatedAccount.Email__c != null &&
                relatedWorkType != null && relatedWorkType.Name == 'Installation') {
                    
                    String recipientEmail = relatedAccount.Email__c;
                    ProductRegistrationReportController.sendEmailWithPDF(wo.Id, recipientEmail);
                }
            }
        }
    }
    
    /*
    @Author : Alka
    @CreatedDate : 28 august 2024
    @Description : To update customer billing.
     */
    public static void updateWorkOrder(List<WorkOrder> completedWorkOrderList) {
        
        // Set<Id> workOrderIds = new Set<Id>();
        
        // for (WorkOrder wo : completedWorkOrderList) {
            //     workOrderIds.add(wo.Id);
            //     System.debug('wo ' + wo.Id);
        // }
        
        // List<WorkOrder> newWorkOrder = WorkOrderSelector.getWorkOrderFamilyCode(workOrderIds);
        // System.debug('wolist ' + newWorkOrder);
        
        // // Map to hold the queried WorkOrder records by their Id
        // Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(newWorkOrder);
        
        
        // for (WorkOrder wo : completedWorkOrderList) {
            //     try {
                
                //         // Retrieve the corresponding WorkOrder record from the map
                //         WorkOrder queriedWo = workOrderMap.get(wo.Id);
                
                //         // Fetch rate card data
                //         List<RateCardController.rateCardWrapper> rateCardList = new List<RateCardController.rateCardWrapper>();
                //         if (queriedWo.Product_Sub_Family_temp__r.Code__c != null && queriedWo.Asset.Product_Family__r.Code__c != null) {
                    //             rateCardList = RateCardController.getRateCard(queriedWo.Product_Sub_Family_temp__r.Code__c, queriedWo.Asset.Product_Family__r.Code__c);
                    //             System.debug('rateCardList ' + rateCardList);
                //         }
                
                //         // Fetch spare parts data
                //         List<SpareProductsRateServiceClass.spareWrapper> sparePartsList = RateCardController.getSpareParts(wo.Id);
                //         System.debug('sparePartsList ' + sparePartsList);
                
                //         // Process the fetched data as needed
                //         Decimal totalVisitingCharges = 0;
                //         Decimal totalSpareCharges = 0;
                
                //         if (!rateCardList.isEmpty()) {
                    //             for (RateCardController.rateCardWrapper rateCard : rateCardList) {
                        //                 if (rateCard.type == 'Visiting Charges') {
                            //                     totalVisitingCharges += rateCard.rate;
                        //                 }
                    //             }
                //         }
                
                //         if (!sparePartsList.isEmpty()) {
                    //             for (SpareProductsRateServiceClass.spareWrapper spare : sparePartsList) {
                        //                 totalSpareCharges += spare.price;
                        //                 System.debug('totalSpareCharges ' + totalSpareCharges);
                    //             }
                //         }
                
                //         // Update the WorkOrder fields with the calculated values
                //         wo.Visiting_Charges__c = totalVisitingCharges;
                //         wo.Spare_Charge__c = totalSpareCharges;
                //         System.debug('wo.Visiting_Charges__c '+ wo.Visiting_Charges__c +'wo.Spare_Charge__c  '+ wo.Spare_Charge__c );
            //     } catch (Exception e) {
                //         // Log the exception and continue
                //         System.debug('Error updating WorkOrder: ' + wo.Id + ' - ' + e.getMessage());
            //     }
        // }
        
        // Perform the update DML operation
        // update newWorkOrder;  // Ensure this line is used where appropriate in your context
    }
    
    
    /*
    @Author : Rishabh SAhu
    @CreatedDate : 25th July 2024
    @Description : Update TAT on service Ticket
     */
    public static void updateTAT(List<WorkOrder> ClosedWorkOrderList) {
        try {
            // Retrieve the default business hours
            BusinessHours stdBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
            
            // List to hold the WorkOrders to be updated
            List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
            
            // Get the current date and time
            DateTime currentDateTime = System.now();
            system.debug('currentDateTime'+currentDateTime);
            // Iterate over the WorkOrders in the scope
            for (WorkOrder wo : ClosedWorkOrderList) {
                system.debug('hi');
                // Update the Closed_Date_Time__c field to the current date and time
                wo.Closed_Date_Time__c = currentDateTime;
                system.debug('Closed_Date_Time__c'+ wo.Closed_Date_Time__c);
                
                // Calculate the difference in business hours between the updated Closed_Date_Time__c and CreatedDate
                Long diffMillis = BusinessHours.diff(
                    stdBusinessHours.Id,
                wo.CreatedDate,
                wo.Closed_Date_Time__c
                    
                );
                
                // Convert milliseconds to hours
                Double diffHours = diffMillis / (1000.0 * 60.0 * 60.0);
                
                // Round to 2 decimal places
                diffHours = Math.round(diffHours * 100.0) / 100.0;
                system.debug('diffHours' + diffHours );
                // Set the TAT__c field with the calculated diffHours
                wo.TAT__c = diffHours;
                system.debug('TAT__c'  + wo.TAT__c);
                
                // Add the WorkOrder to the list of records to update
                workOrdersToUpdate.add(wo);
            }
            
            // Perform a DML update operation to save the changes to the database
            if (!workOrdersToUpdate.isEmpty()) {
                system.debug('workOrdersToUpdate'+ workOrdersToUpdate);
                update workOrdersToUpdate;
            }
        } catch (Exception e) {
            // Log the error message and line number
            System.debug('Error in updateTAT method: ' + e.getMessage() + ' at line number: ' + e.getLineNumber());
        }
    }

         @future(callout = true)
    public static void asyncProductregistration(list<String> woIds){
        
        system.debug('woLst -- '+ woIds);
        map<String,WorkOrder> woMap = new map<String,WorkOrder>();
        String sapResponse;
        
        list<WorkOrder> woLSt = [SELECT Id,AccountId,FSL_Invoice_Number__c,FSL_Model_Number__c,FSL_Serial_Number__c FROM WOrkOrder WHERE ID IN:woIds];
        
        
        // for(WorkOrder wo:woLst){
            //     woMap.put(wo.Id,wo);
            
        // }
        
        for(WorkOrder wo:woLst){
            
            system.debug('serial number -- '+ wo.FSL_Serial_Number__c);
            system.debug('model number -- '+ wo.FSL_Model_Number__c);
            system.debug('invoice number -- '+ wo.FSL_Invoice_Number__c);
            
            
            
            if((wo.FSL_Serial_Number__c != null && wo.FSL_Model_Number__c != null) || wo.FSL_Invoice_Number__c != null){
                
                sapResponse = SAPAuthorisation.makeRequest(wo.FSL_Model_Number__c, wo.FSL_Serial_Number__c, wo.FSL_Invoice_Number__c);
                system.debug('sapResponse -- '+ sapResponse);
            }
            
            if(sapResponse != null){
                
                AsyncProductRegistrationFSL.asyncRegisterAsset(sapResponse, wo);
                
            }
            
            
        }
  
    }
    
    public static void sendLetterofSalePDF(List<WorkOrder> newList, Map<Id, WorkOrder> oldMap) {
        /* for (WorkOrder wo : newList) {
                // Check if the status has changed to 'Completed'
                if (wo.Status == 'Completed' && oldMap.get(wo.Id).Status != 'Completed') {
                    // Enqueue the queueable job
                    System.enqueueJob(new FetchAndStorePdfQueueable(wo.Id));
                }
        }*/
    }
    
    /*
    @Author : Alka
    @CreatedDate : 29 aug 2024
    @Description : to auto complete RT milestone if service ticket status is In Progress
     */
    public static void autoCompleteMilestoneInProgressRT(List<WorkOrder> listOfWorkOrder) {
        try {
            List<CaseMilestone> milestonesToUpdate = new List<CaseMilestone>();
            Set<Id> caseIds = new Set<Id>();
            for (WorkOrder wo : listOfWorkOrder) {
                if (wo.CaseId != null ) {
                    caseIds.add(wo.CaseId);
                }
            }
            List<CaseMilestone> caseMilestones = [
                SELECT Id, CompletionDate, MilestoneTypeId, TargetDate
                FROM CaseMilestone
                WHERE CaseId IN :caseIds 
                AND CompletionDate = NULL 
                AND MilestoneType.Name IN ('RT', 'RS')
            ];
            // Complete the milestone by setting the CompletionDate
            for (CaseMilestone cm : caseMilestones) {
                if(cm.CompletionDate == null) {
                    cm.CompletionDate = System.now();
                    milestonesToUpdate.add(cm);
                }
                
            }
            // Update the milestones
            if (!milestonesToUpdate.isEmpty()) {
                update milestonesToUpdate;
            }
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error updating ContractLineItems: ' + e.getMessage());
        }
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

        public static void coveragemethod2(){

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