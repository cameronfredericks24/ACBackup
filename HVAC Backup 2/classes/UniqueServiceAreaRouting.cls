public with sharing class UniqueServiceAreaRouting {
    @InvocableMethod
    public static List<List<Branch_Division__c>> fetchUniqueServiceAreaRouting(List<String> cpCodes) {
        if(cpCodes == null || cpCodes.isEmpty()) {
            return new List<List<Branch_Division__c>>();
        }

        String cpCode = cpCodes[0];

        List<Service_Area_Routing__c> serviceAreaRoutings = [
            SELECT Id, 
                   Pincode__r.Branch__c, 
                   Pincode__r.Branch__r.Branch_Code__c, 
                   Department__c, 
                   Department__r.Department_Number__c, 
                   Channel_Partner__c, 
                   Channel_Partner__r.CP_Code__c 
            FROM Service_Area_Routing__c 
            WHERE Channel_Partner__r.CP_Code__c = :cpCode
        ];

        // Create a Set to store unique pairs
        Set<String> uniquePairs = new Set<String>();

        // Iterate over the records and create unique pairs
        for(Service_Area_Routing__c sar : serviceAreaRoutings) {
            String uniquePair = sar.Pincode__r.Branch__r.Branch_Code__c + '-' + sar.Department__r.Department_Number__c;
            uniquePairs.add(uniquePair);
        }

        // Create a list to store Branch_Division__c records
        List<Branch_Division__c> branchDivisions = new List<Branch_Division__c>();

        // // Query Branch_Division__c records based on unique pairs
        // if (!uniquePairs.isEmpty()) {
        //     List<String> branchCodes = new List<String>();
        //     List<String> departmentNumbers = new List<String>();

        //     // Split unique pairs into branch codes and department numbers
        //     for (String pair : uniquePairs) {
        //         List<String> parts = pair.split('-');
        //         branchCodes.add(parts[0]);
        //         departmentNumbers.add(parts[1]);
        //     }

            branchDivisions = [
                SELECT Id, Branch__r.Branch_Code__c, Department__r.Department_Number__c 
                FROM Branch_Division__c 
                WHERE Branch_Code_Department_Number__c IN : uniquePairs
            ];
             List<List<Branch_Division__c>>  branchDivisionRecords = new List<List<Branch_Division__c>>();
             branchDivisionRecords.add(branchDivisions); 
             return branchDivisionRecords;
        }

        // Return the list of Branch_Division__c records
      
    }