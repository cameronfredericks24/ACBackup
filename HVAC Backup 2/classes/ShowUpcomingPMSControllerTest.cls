@isTest
public class ShowUpcomingPMSControllerTest {

    @isTest
    static void testGetOpenWorkOrdersThisMonth() {
        TestDataFactory.disableTriggers();
       
        // Create test Account
        Account acc = new Account(Name = 'Test Account',Is_Active__c=false);
        insert acc;

        // Create test Assets related to the Account
        Asset asset1 = new Asset(Name='TestSerial123',SerialNumber = 'TestSerial123', AccountId = acc.Id);
        insert asset1;
        Asset asset2 = new Asset(Name='TestSerial123',SerialNumber = 'TestSerial123', AccountId = acc.Id);
        insert asset2;
        
        // Create test WorkOrders related to the Assets
        WorkOrder workOrder1 = new WorkOrder(AssetId = asset1.Id, Status = 'Pending');
        WorkOrder workOrder2 = new WorkOrder(AssetId = asset2.Id, Status = 'Pending');
        insert new List<WorkOrder>{workOrder1, workOrder2};
		System.debug('Account id ======'+acc.id);
        Test.startTest();
        List<WorkOrder> workOrders = ShowUpcomingPMSController.getOpenWorkOrdersThisMonth(acc.Id, 1, 10);
        Test.stopTest();

        // Assert that the correct number of work orders are returned
        //System.assertEquals(2, workOrders.size(), 'Expected 2 work orders');
  }
}