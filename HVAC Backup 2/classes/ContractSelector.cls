/*
@Author : Abhijeet Ojha
@CreatedDate : 2th April 2024
@Object : Service Contract
*/
public without sharing class  ContractSelector {
/*
@Author : Abhijeet Ojha
@CreatedDate : 2th April 2024
@Description : Get the Service Contract Id by Contract Number 
*/
public static Id getContractIdByContractNumber(String contNum) {
    try {
        List<ServiceContract> contracts = [SELECT Id,ContractNumber
                                    FROM ServiceContract 
                                    WHERE ContractNumber = :contNum 
                                    LIMIT 1];
        if (!contracts.isEmpty()) {
            return contracts[0].Id;
        }
        return null; // Return null if no matching contract is found
    } catch(Exception e) {
        throw e;
    }
}

/*
@Author : Abhijeet Ojha
@CreatedDate : 2th April 2024
@Description : Get the Contract Number, Id by Contract Numbers
*/
public static Map<String, Id> getContractIdsByContractNumbers(Set<String> contNumbers) {
    Map<String, Id> contractIdsMap = new Map<String, Id>();
    for (ServiceContract contract : [
        SELECT Id, SAP_Contract_Number__c FROM ServiceContract WHERE SAP_Contract_Number__c IN :contNumbers
    ]) {
        system.debug('contract -- '+ contract);
        contractIdsMap.put(contract.SAP_Contract_Number__c, contract.Id);
    }
            system.debug('contractIdsMap -- '+ contractIdsMap);

    return contractIdsMap;
}

}