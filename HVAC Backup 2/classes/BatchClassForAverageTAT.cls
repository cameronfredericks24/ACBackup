/*
@Author : Deepanshu Tyagi
@CreatedDate : 1st March 2024
@Description : Batch class for Average TAT for CP as Division Vise
*/
public  class BatchClassForAverageTAT   implements Database.Batchable<sObject> {
    public final String Query;
    public BatchClassForAverageTAT(String q) {
        Query=q; 
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        List<Id> accIdList = new List<Id>();                 
        if(scope.size()>0){
            for(Account acc:Scope){
                if(acc.Is_Active__c){
                    accIdList.add(acc.id);
                }
            }
            Map<id,WorkOrder> woMap =new  Map<id,WorkOrder>([ 
                select id,CP__c,caseId,Case.TAT__c,AssetId,Asset.Product_Sub_Family__r.Division_Lookup__c,
                Asset.Product_Sub_Family__c
                from workOrder 
                where CP__c=:accIdList 
                AND  (
                    RecordType.DeveloperName =: UtilityClass.getOrgConstantValue('WorkOrderRecordTypeDeveloperNameBreakdow')  
                    OR RecordType.DeveloperName =:UtilityClass.getOrgConstantValue('WorkOrderRecordTypeDeveloperNameDemo') 
                    OR RecordType.DeveloperName =:UtilityClass.getOrgConstantValue('WorkOrderRecordTypeDeveloperInstallation')  
                    OR RecordType.DeveloperName =:UtilityClass.getOrgConstantValue('WORecordTypeDeveloperRegular_Service')
                )  
                AND AssetId != null 
                AND CaseId != null
                AND Case.TAT__c != null 
                AND Asset.Product_Sub_Family__c != null 
                AND Asset.Product_Sub_Family__r.Division_Lookup__c != null
            ]);
            
            system.debug('size--->'+woMap.size());
            if(!woMap.isEmpty()){
                ///Map<Id,List<Id>> mapDivisonWithAccIdList = new Map<Id,List<Id>>();
                Set<Id> divisionIdList = new Set<id>();
                Map<String,List<integer>> mapAccWithTATList= new Map<String,List<integer>>();
                Map<String,integer> mapAccWithTotalTAT= new Map<String,integer>();
                Map<String,integer> mapAccWithAvgTAT= new Map<String,integer>();
                
                for(WorkOrder W:woMap.values()){
                    System.debug('cp--->'+W.CP__c);
                    System.debug('Divison -->'+W.Asset.Product_Sub_Family__r.Division_Lookup__c);
                    if(!mapAccWithTATList.containsKey(W.CP__c+','+W.Asset.Product_Sub_Family__r.Division_Lookup__c)){
                        mapAccWithTATList.put(W.CP__c+','+W.Asset.Product_Sub_Family__r.Division_Lookup__c,new List<Integer>{Integer.valueOf(W.Case.TAT__c)});
                    }else{
                        mapAccWithTATList.get(W.CP__c+','+W.Asset.Product_Sub_Family__r.Division_Lookup__c).add(Integer.valueOf(W.Case.TAT__c));
                    }
                    divisionIdList.add(W.Asset.Product_Sub_Family__r.Division_Lookup__c);
                    
                }
                
                System.debug(mapAccWithTATList);
                
                if(!mapAccWithTATList.isEmpty()){
                    Map<Id,Integer> mapDivisionWithThersoldValue = new Map<Id,Integer>();
                    for(Division__c d:[select id,Threshold__c from Division__c where Id=:divisionIdList]){
                        mapDivisionWithThersoldValue.put(d.id,Integer.valueOf(d.Threshold__c));
                    }
                    for(String Key :mapAccWithTATList.keySet()){
                        System.debug(key);
                        for(Integer N:mapAccWithTATList.get(Key)){
                            System.debug('number---->'+N);
                            if(!mapAccWithTotalTAT.containsKey(Key)){
                                mapAccWithTotalTAT.put(Key,N);
                            }else{
                                
                                mapAccWithTotalTAT.put(Key,mapAccWithTotalTAT.get(Key)+N);
                            }
                        }
                        
                    }
                    System.debug(mapAccWithTotalTAT);
                    for(String Key:mapAccWithTotalTAT.Keyset()){
                        mapAccWithAvgTAT.put(Key,mapAccWithTotalTAT.get(Key)/mapAccWithTATList.get(key).size());
                    }
                    System.debug(mapAccWithAvgTAT);
                    List<Account> updatedAccList = new List<Account>();
                    for(String key:mapAccWithAvgTAT.keySet()){
                        string cp=key.split(',')[0];
                        string division=key.split(',')[1];
                        if(mapAccWithAvgTAT.get(key) > mapDivisionWithThersoldValue.get(division) ) {
                            system.debug('check this----->2nd condition');
                            Account acc = new Account();
                            acc.id=cp;         
                            acc.Technician_Auto_Assignment__c='false';
                            updatedAccList.add(acc);
                        }
                        
                    }
                    // for(WorkOrder W:woMap.values()){
                    
                    //     if(mapAccWithAvgTAT.containsKey(W.CP__c+','+W.Asset.Product_Sub_Family__r.Division_Lookup__c)){
                    //         system.debug('check this----->1st condition');
                    //         System.debug(mapAccWithAvgTAT.get(W.CP__c+','+W.Asset.Product_Sub_Family__r.Division_Lookup__c));
                    //         System.debug(mapDivisionWithThersoldValue.get(W.Asset.Product_Sub_Family__r.Division_Lookup__c));
                    //     if(mapAccWithAvgTAT.get(W.CP__c+','+W.Asset.Product_Sub_Family__r.Division_Lookup__c) > mapDivisionWithThersoldValue.get(W.Asset.Product_Sub_Family__r.Division_Lookup__c)){
                    //        system.debug('check this----->2nd condition');
                    //         Account acc = new Account();
                    //         acc.id=W.CP__c;         
                    //         acc.Technician_Auto_Assignment__c='false';
                    //         updatedAccList.add(acc);
                    //     }
                    
                    //     }
                    
                    
                    
                    
                    // }
                    
                    System.debug('size----->'+updatedAccList.size());
                    if(!updatedAccList.isEmpty()){
                        update updatedAccList;
                    }
                    
                    
                    
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}