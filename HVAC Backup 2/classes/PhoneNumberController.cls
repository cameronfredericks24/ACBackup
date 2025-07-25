public class PhoneNumberController {
    public String phoneNumber { get; set; }
    public List<Account> acc { get; set; }
    public Boolean accEmpty { get; set; }
    public String taskId {get; set;}
    public String selectedAccountId {get; set;}
    
    public PhoneNumberController() {
        accEmpty = false; // Initialize accEmpty to false by default
    }
    
    public PageReference redirect() {
        String phoneNumber = ApexPages.currentPage().getParameters().get('phoneNumber');
        String uniqueCallId =ApexPages.currentPage().getParameters().get('uniqueCallId');
        PageReference accPage = null;
        List<Task> newTaskList= new List<Task>();
        System.debug('phoneNumber ' + phoneNumber);
        system.debug('selected '+selectedAccountId );
        
        try {
            if (phoneNumber != null && uniqueCallId !=null) {
                // If an account with the given phone number exists, fetch it
                Task newTask = new Task();
                newTask.OwnerId = UserInfo.getUserId();
                newTask.Subject = 'Gensys caller id';
                newTask.Status = 'Open';
                newTask.CallObject= uniqueCallId; 
                newTask.Phone_Number__c = phoneNumber;
                
                acc = [SELECT Id,Name,RecordType.DeveloperName,Phone,Email__c FROM Account WHERE Phone = :phoneNumber and Is_Active__c = true];
                
                if (acc.isEmpty()) {
                    accEmpty = true;
                    newTaskList.add(newTask);
                } 
                else if (acc.size() == 1) {
                    String accountId = acc[0].Id;
                    newTask.WhatId = acc[0].Id;
                    newTaskList.add(newTask);
                    
                    PageReference accountPage = new PageReference('/' + accountId);
                    accountPage.setRedirect(true);
                    ApexPages.currentPage().setRedirect(true);
                    accPage = accountPage;
                } 
                else {
                    System.debug(acc.size());
                    system.debug('selected '+selectedAccountId );
                }
                
                Database.SaveResult[] saveResultList = Database.insert(newTaskList, false);
                
                // Iterate through saveResultList based on isSuccess capture the failed records
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Task ID: ' + sr.getId());
                        taskId = sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
            }
        } catch (Exception e) {
            System.debug(e);
        }
        
        return accPage;
    }
    public PageReference openAccount() {
         String phoneNumber = ApexPages.currentPage().getParameters().get('phoneNumber');
        String uniqueCallId =ApexPages.currentPage().getParameters().get('uniqueCallId');
         System.debug('phoneNumber ' + phoneNumber);
        system.debug('selected '+selectedAccountId );
        List<Task> newTaskList= new List<Task>();
         Task newTask = new Task();
                newTask.OwnerId = UserInfo.getUserId();
                newTask.Subject = 'Gensys caller id';
                newTask.Status = 'Open';
                newTask.CallObject= uniqueCallId; 
                newTask.Phone_Number__c = phoneNumber;
               
        if (selectedAccountId != null) {
             newTask.WhatId = selectedAccountId;
            newTaskList.add(newTask);
            if(!newTaskList.isEmpty()){
                Database.SaveResult[] saveResultList = Database.insert(newTaskList, false);
                
                // Iterate through saveResultList based on isSuccess capture the failed records
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Task ID: ' + sr.getId());
                        taskId = sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            
            PageReference pr = new PageReference('/' + selectedAccountId);
            pr.setRedirect(true);
            return pr;
        }
        
        return null;
    }
}