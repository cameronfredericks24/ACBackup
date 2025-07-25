public without sharing class SAPCaptureContractDetailsHandler {
 
    public static list<SAPCaptureContractDetailsResponseWrapper> captureContract (List<SAPCaptureContractDetailsRequestWrapper> reqWrapLst) {

        Map<String, Id> contractIdsMap = new Map<String, Id>(); // Map of SAP contract number to ServiceContract ID
        Map<Id, String> contractIdVsNumberMap = new  Map<Id, String>(); // Map of ServiceContract ID to SAP contract number

        list<ServiceContract> contractLst = new list<ServiceContract>();
        list<SAPCaptureContractDetailsResponseWrapper> responseWrapperLst = new list<SAPCaptureContractDetailsResponseWrapper>();

        try {
            // Collect all AMC contract numbers from the request
            Set<String> amcContractNumbers = new Set<String>();
            for(SAPCaptureContractDetailsRequestWrapper reqWrap: reqWrapLst) {
                amcContractNumbers.add(reqWrap.sap_contract_number);
            }

            // Retrieve all contract IDs by their contract numbers
            contractIdsMap = ContractSelector.getContractIdsByContractNumbers(amcContractNumbers);

            // Create a reverse map for contractId -> SAP contract number for easy lookup later
            for (String sapContractNumber : contractIdsMap.keySet()) {
                contractIdVsNumberMap.put(contractIdsMap.get(sapContractNumber), sapContractNumber);
            }

            // Iterate over the request wrappers and update the contracts
            for(SAPCaptureContractDetailsRequestWrapper reqWrap: reqWrapLst) {
                system.debug('reqWrap - ' + reqWrap);

                SAPCaptureContractDetailsResponseWrapper responseWrapper = new SAPCaptureContractDetailsResponseWrapper();

                if (contractIdsMap.containsKey(reqWrap.sap_contract_number)) {
                    ServiceContract contractRecord = new ServiceContract();
                    contractRecord.Id = contractIdsMap.get(reqWrap.sap_contract_number);
                    if(!String.isBlank(reqWrap.amount)){
                        contractRecord.SAP_Contract_Modification_Amount__c = Decimal.valueOf(reqWrap.amount);
                    }
                    contractRecord.SAP_End_Date__c = Date.valueOf(reqWrap.end_date);

                    contractLst.add(contractRecord);
                } else {
                    responseWrapper.result = 'Failure';
                    responseWrapper.message = 'Unable to find contract number in SF';
                    responseWrapper.sap_contract_number = reqWrap.sap_contract_number;  
                    responseWrapperLst.add(responseWrapper);
                }
            }

            // Perform the bulk update of contracts
            Database.SaveResult[] updatedResults = Database.update(contractLst, false); // false for partial success

            // Iterate over the save results to handle both success and failure cases
            for (Database.SaveResult sr : updatedResults) {
                SAPCaptureContractDetailsResponseWrapper responseWrapper = new SAPCaptureContractDetailsResponseWrapper();

                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error while updating contract: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }

                    responseWrapper.result = 'Failure';
                    responseWrapper.message = 'Unable to capture contract details';
                    responseWrapper.sap_contract_number = contractIdVsNumberMap.get(sr.getId()); // Use the contractId -> SAP contract number map
                } else {
                    responseWrapper.result = 'Success';
                    responseWrapper.message = 'Contract details updated successfully';
                    responseWrapper.sap_contract_number = contractIdVsNumberMap.get(sr.getId()); // Use the contractId -> SAP contract number map
                }

                responseWrapperLst.add(responseWrapper);
            }

            system.debug('responseWrapperLst - ' + responseWrapperLst);
            return responseWrapperLst;

        } catch (Exception e) {
            system.debug('Error - ' + e.getMessage());
            system.debug('Error line - ' + e.getLineNumber());

         
            SAPCaptureContractDetailsResponseWrapper responseWrapper = new SAPCaptureContractDetailsResponseWrapper();
            responseWrapper.result = 'Failure';
            responseWrapper.message = 'Error occurred: ' + e.getMessage();
            responseWrapper.sap_contract_number = null;
            responseWrapperLst.add(responseWrapper);
            return responseWrapperLst;
        }
    }
}