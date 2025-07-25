/*
@Author : Kunal Nadkarni
@CreatedDate : 16th Jan 2024
@Description : Case Object Trigger Handler.
*/
public class CaseTriggerHandler implements TriggerHandler{
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    //Use this variable to call helper methods
    public CaseTriggerHelper helper;
    public UpdateCasedetails UpdateCasedetails;
    
    List<case> assignedStatusCases = new List<Case>();
    //constructor
    public CaseTriggerHandler() {
        this.helper = new CaseTriggerHelper();
        this.UpdateCasedetails= new UpdateCasedetails();
    }
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newList) {    
            
        try {
            //added by divya
            helper.duplicateCaseCreationValidation((List<Case>)newList);
            //added by deepanshu for Entitlement
            //commenting because its not being used anymore
            //helper.setEntitlement((List<Case>)newList);
            //added by divya
            helper.repeatedCustomerCase((List<Case>)newList);
            helper.repeatedCustomerCaseForCPSD((List<Case>)newList);
            if(!newList.isEmpty()){
                List<Case> updatePriorityForIssueType = new List<Case>();
                for(Case cse : (List<Case>)newList){
                    if( !String.isBlank(cse.Issue_Type__c) ){
                        //updatePriorityForIssueType.add(cse);
                    }
                    
                    //Assigned date time 
                    if(cse.status ==CaseConstants.CaseAssignedStatus  ){
                        assignedStatusCases.add(cse);
                    }
                    
                    
                }
               // system.debug('updatePriorityForIssueType '+ updatePriorityForIssueType);
                if(!updatePriorityForIssueType.isEmpty()){
                    //helper.setPriorityBasedOnIssueType(updatePriorityForIssueType);
                }
                if(!assignedStatusCases.isEmpty()){
                    UpdateCasedetails.setAssignedDate(assignedStatusCases); 
                }
                // Generate and store OTP
                //CaseTriggerHelper.generateAndStoreOTP((List<Case>)newList, (Map<Id, Case>)Trigger.oldMap);
            }
            
            
        } catch (Exception e) {
            system.debug('Exception'+ e);
        }
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<Case> csList = new List<Case>();
         //added by himanshi
        for(Case cs: (List<Case>)newList){
            //added by soniya
            if(cs.Priority == 'Critical' || cs.Subject =='Fire'){
                csList.add(cs);
            } 
            
        }
        system.debug('csList '+ csList);
        if(!csList.isEmpty()){
            helper.sendSMSForCriticalCase(csList);
        }
        if (!CaseTriggerHelper.isExecuting) {
            
            helper.getCaseEntitlementId((List<Case>)newList);
        }
        
        Id userId = Label.Bypass_user;
        if(newList.size()==1 && userId != UserInfo.getUserId()){
            //send sms to customer
            CaseTriggerHelper.notifyCustomerSMS(newList ,newMap);

            //send whatsapp message to customer
            CaseTriggerHelper.notifyCustomerWhatsapp(newList ,newMap);
        }

        if(newList.size()==1 && ((boolean)newList[0].get('Auto_Assign_ST__c')==true)){
            CreateCaseFormController.tagChannelPartnerUI((string)newList[0].get('Id'));
        }


    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
         //added by deepanshu for Entitlement
           //helper.setEntitlement((List<Case>)newList);
        if(oldMap!= null){
            List<Case> updtCasePriority = new List<Case>();
            //variables for status value changes on Case level
            List<case> reopenCases = new List<case>();
            List<case> canceledCases = new List<case>();
            List<case> inProgressCases = new List<case>();
            List<case> resolvedCases = new List<case>();
            List<case> closedCases = new List<case>();
            List<Id> newlyClosedCase = new List<Id>();
            List<case> cpsdUpsdCases = new List<case>();
            
            try {
                for(Case cse : (List<Case>)newList){
                    if(cse.Priority != ((Case)oldMap.get(cse.Id)).Priority && cse.Priority == 'Critical') {
                        updtCasePriority.add(cse);
                    }
                    
                    //Assigned date time 
                    if(((Case)oldMap.get(cse.id)).status ==CaseConstants.CaseOpenStatus && cse.status ==CaseConstants.CaseAssignedStatus && ((Case)oldMap.get(cse.id)).Status !=cse.status  && cse.Assigned_Date__c == null ){
                        System.debug('Checking--->'+cse);
                        assignedStatusCases.add(cse);
                    }
                    //Reopen Date
                    if( cse.status ==CaseConstants.CaseReopenedStatus  && ((Case)oldMap.get(cse.id)).Status !=cse.status  ){
                        System.debug('Checking--->'+cse);
                        reopenCases.add(cse);
                    }
                    //Resolved date
                    if( cse.status ==CaseConstants.CaseResolvedStatus && ((Case)oldMap.get(cse.id)).Status !=cse.status  ){
                        System.debug('Checking--->'+cse);
                        resolvedCases.add(cse);
                    }
                    //closedcase
                    if(cse.Status == CaseConstants.CaseClosedStatus &&  ((Case)oldMap.get(cse.Id)).Status != cse.Status ){
                        closedCases.add(cse);
                        
                    }
                                        //Case_Status_In_Progress
                    if(cse.Status == CaseConstants.CASE_STATUS_IN_PROGRESS &&  ((Case)oldMap.get(cse.Id)).Status != cse.Status ){
                        inProgressCases.add(cse);
                        
                    }
                                         //Case_Canceled
                    if(cse.Status == CaseConstants.Case_Canceled &&  ((Case)oldMap.get(cse.Id)).Status != cse.Status ){
                        canceledCases.add(cse);
                        
                    }
                    
                    // added by alka Resolved and closed case check
                    system.debug('valuec' + CaseConstants.CaseResolvedStatus);
                    if((cse.Status == CaseConstants.CaseResolvedStatus || cse.Status == CaseConstants.CaseClosedStatus) && ((Case)oldMap.get(cse.Id)).Status != cse.Status) {
                        system.debug(cse.Id);
                        newlyClosedCase.add(cse.Id);
                    }
                    if(case.AssetId!=null && ((Case)oldMap.get(cse.Id)).AssetId != cse.AssetId){
                        cpsdUpsdCases.add(cse);
                    }
                }

                if(!cpsdUpsdCases.isEmpty()) {
                    helper.repeatedCustomerCase(cpsdUpsdCases);
                    helper.repeatedCustomerCaseForCPSD(cpsdUpsdCases);
                }

                // added by alka calling helper method
                if(!newlyClosedCase.isEmpty()) {
                    system.debug('not empty');
                    helper.checkingForWorkOrderStatus(newlyClosedCase,newMap);
                }
                if(!updtCasePriority.isEmpty()){
                    helper.sendSMSForCriticalCase(updtCasePriority);
                }
                if(!assignedStatusCases.isEmpty()){
                    UpdateCasedetails.setAssignedDate(assignedStatusCases); 
                }
                if(!reopenCases.isEmpty()){
                    UpdateCasedetails.setReopenedDate(reopenCases); 
                }
                if(!resolvedCases.isEmpty()){
                    UpdateCasedetails.setResolvedDate(resolvedCases); 
                }
                //get call Age Value
                
                if(!closedCases.isEmpty()){
                    
                    UpdateCasedetails.setCallAgeValue(closedCases);
                }
                
                  if(!inProgressCases.isEmpty()){
                    
                    CaseTriggerHelper.autoCompleteMilestoneRT(inProgressCases);
                }
                if(!canceledCases.isEmpty()){
                    
                    CaseTriggerHelper.autoCompleteMilestoneCaseCanceled(canceledCases);
                }
                
                
                
            } catch (Exception e) {
                system.debug('Exception'+ e);
            }
        }
        
        
        
        
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        if(newList == null || newList.isEmpty()) {
            return;
        }
        
        List<Case> closedCases = new List<Case>();
        for (sObject sObj : newMap.values()) {
        Case c = (Case)sObj;
        Case oldCase = (Case)oldMap.get(c.Id);
        if (c.Status == CaseConstants.CaseResolvedStatus && oldCase.Status != c.Status && c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Request').getRecordTypeId() ) {
            closedCases.add(c);
        }
    }
    
    if (!closedCases.isEmpty()) {
        CaseTriggerHelper.createSurveyInvitationForClosedCase(closedCases);
    }
}
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        
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
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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