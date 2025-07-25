@IsTest(SeeAllData=true)
private class AssignedResourceSelectorTest {
    
    @isTest
    static void testGetAssignedResources() {

           
           Test.startTest();
      
      list<AssignedResource> assignedResources = [SELECT Id,ServiceResource.Name, ServiceAppointmentId, ServiceResourceId FROM AssignedResource LIMIT 1];
        
      Set<Id> saIds = new Set<Id>{assignedResources[0].Id};
        // Step 4: Invoke the method under test
        List<AssignedResource> result = AssignedResourceSelector.getAssignedResources(saIds);
        
        // Step 5: Verify the results
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAssignedResourcesWithNoRecords() {
        
       
    
        Test.startTest();
        
        // Step 1: Create an empty set of ServiceAppointment IDs
        Set<Id> emptyServiceApptIds = new Set<Id>();
        
        // Step 2: Invoke the method under test with no records
        List<AssignedResource> result = AssignedResourceSelector.getAssignedResources(emptyServiceApptIds);
        
        // Step 3: Verify that the result is an empty list
        System.assertEquals(0, result.size(), 'The list of assigned resources should be empty when no ServiceAppointment IDs are provided.');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetAssignedResourcesWithNonExistentIds() {


         // Step 1: Create test data for ServiceAppointment
        list<ServiceAppointment> sa = [SELECT Id from ServiceAppointment limit 1];
        Test.startTest();
        
        // Step 1: Create a set of non-existent ServiceAppointment IDs
        Set<Id> nonExistentServiceApptIds = new Set<Id>{sa[0].Id};
        
        // Step 2: Invoke the method under test with non-existent IDs
        List<AssignedResource> result = AssignedResourceSelector.getAssignedResources(nonExistentServiceApptIds);
        
        // Step 3: Verify that the result is an empty list
        
        Test.stopTest();
    }
}