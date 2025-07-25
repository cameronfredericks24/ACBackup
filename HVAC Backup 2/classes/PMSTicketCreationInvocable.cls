public class PMSTicketCreationInvocable {
	@invocablemethod(label='Create PMS Tickets From Button' description='Creates PMS Tickets From Button' category='Service Contract')
    public static void createPMSTicketsFromButton(List<Id> requests)
    {
        List<PMS_Event__c> pmsEventList = [SELECT Id, PMS_Tickets_Creation_Date__c, Start_Date__c, PMS_Completion_SLA__c, Service_Contract__c,
                                             Asset__c, Contact__c, Account__c, Subject__c, Asset__r.Product_Sub_Family__c, Asset__r.CP__r.CP_User__c, 
                                             Asset__r.CP__c FROM PMS_Event__c WHERE Id =: requests AND Is_Skipped__c = FALSE AND Status__c != 'Cancelled'];
        if(!pmsEventList.isEmpty()){
            SchedulePMSTicketsForContracts.createPMSTicket(pmsEventList);
        }
    }
}