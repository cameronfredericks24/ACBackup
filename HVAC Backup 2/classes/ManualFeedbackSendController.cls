public with sharing class ManualFeedbackSendController {


    @AuraEnabled(cacheable=true)
    public static string sendSurveyLink(Id workOrderId) {
        try{
            SurveyInvitationTriggerHelper helper = new SurveyInvitationTriggerHelper();

            Map<Id,Survey_Invitation__c> surveyInvitationMap=  new Map<Id, Survey_Invitation__c>([SELECT Id FROM Survey_Invitation__c WHERE Case__c IN (SELECT CaseId FROM WorkOrder WHERE Id = :workOrderId) Order By CreatedDate DESC Limit 1]);
            
            if(surveyInvitationMap.size()>0){
                List<Id> surveyInvitationIds = new List<Id>(surveyInvitationMap.keySet());
                helper.sendSurveyLinkToCustomer(surveyInvitationIds);
                return 'Survey Invitations sent successfully.';
            }else{
                return 'No Survey Invitation to send.';
            }
           
        }catch(Exception e){
            throw e;
        }     

    }
}