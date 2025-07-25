public class EmailMessageHandler {
    
    @InvocableMethod
    public static void UpdateDocumentStatus(List<EmailMessage> newList){
        
        Set<Id> salesQuoteuoteIds = new Set<Id>();
        Set<Id> cpqQuoteuoteIds = new Set<Id>();
        
        Set<Id> oppIds = new Set<Id>();
        List<SBQQ__Quote__c> cpqQuotesToUpdate = new List<SBQQ__Quote__c>();
        List<Quote> salesQuotesToUpdate = new List<Quote>();
        
        
        for (EmailMessage email : newList) {
            system.debug(email.RelatedToId + ' ' + email.RelatedToId.getSObjectType() + ' '+ email.HasAttachment);
            if (email.RelatedToId != null && email.RelatedToId.getSObjectType() == SBQQ__Quote__c.sObjectType  && email.HasAttachment) {
                cpqQuoteuoteIds.add(email.RelatedToId);
            }
            else if (email.RelatedToId != null && email.RelatedToId.getSObjectType() == Quote.sObjectType && email.HasAttachment) {
                salesQuoteuoteIds.add(email.RelatedToId);
            }
            else if (email.RelatedToId != null && email.RelatedToId.getSObjectType() == Opportunity.sObjectType && email.HasAttachment) {
                oppIds.add(email.RelatedToId);
            }
        }
        
        list<Opportunity> oppToBeUpdated = New list<Opportunity>();
        
        if (!cpqQuoteuoteIds.isEmpty() || oppIds != null){
            List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__DocumentStatus__c,SBQQ__Status__c,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN :cpqQuoteuoteIds OR SBQQ__Opportunity2__c =: oppIds];
            for (SBQQ__Quote__c quote : quotes) {
                quote.SBQQ__Status__c = 'Presented';                
                cpqQuotesToUpdate.add(quote);
                Opportunity opp = New Opportunity(Id =quote.SBQQ__Opportunity2__c, StageName = 'Negotiation',SubStatus__c = 'Proposal Presented');
                oppToBeUpdated.add(opp);
            }               
        }
        if (!salesQuoteuoteIds.isEmpty() || oppIds != null) {
            List<Quote> quotes = [SELECT Id, Status, OpportunityId FROM Quote WHERE Id IN :salesQuoteuoteIds OR OpportunityId =: oppIds];
            for (Quote quote : quotes) {
                quote.Status = 'Presented';
                salesQuotesToUpdate.add(quote);
                Opportunity opp = New Opportunity(Id =quote.OpportunityId, StageName = 'Negotiation', SubStatus__c = 'Proposal Presented');
                oppToBeUpdated.add(opp);
            }
            
        }
        if(!cpqQuotesToUpdate.isEmpty()){
            system.debug('cpqQuotesToUpdate : '+ cpqQuotesToUpdate);
            update cpqQuotesToUpdate;
        } 
        if(!salesQuotesToUpdate.isEmpty()){
            system.debug('salesQuotesToUpdate : '+ salesQuotesToUpdate);
            update salesQuotesToUpdate;
        } 
        if(!oppToBeUpdated.isEmpty()){
            system.debug('oppToBeUpdated : '+ oppToBeUpdated);
            update oppToBeUpdated;
        } 
        
        system.debug('cpqQuotesToUpdate : '+ cpqQuotesToUpdate);
        system.debug('salesQuotesToUpdate : '+ salesQuotesToUpdate);
    }
    
    
}