@isTest
public class BulkWorkOrderPMSControllerTest {   

    @isTest
    static void testCallMethod() {
        TestDataFactory.disableTriggers(); // Disable triggers
        try {
            System.debug('Starting testCallMethod');

            // Arrange
            BulkWorkOrderPMSController controller = new BulkWorkOrderPMSController();

            Map<String, Object> args = new Map<String, Object>{
                'ListMap' => new List<Map<String, String>>{
                    new Map<String, String>{
                        'PMS_Maintenance_Date__c' => '2024-06-06'
                    }
                },
                'mapOfAPiAndFields' => new Map<String, String>{
                    'PMS_Maintenance_Date__c' => 'PMS_Maintenance_Date__c'
                },
                'mapOfAPiAndDataType' => new Map<String, String>{
                    'PMS_Maintenance_Date__c' => 'Date'
                }
            };

            // Act
            Test.startTest();
            List<GenericFileUploaderController.fileResultWrapper> results = controller.call('WorkOrderCreationMethod', args);
            Test.stopTest();

            System.debug('Results from call method: ' + results);

            // Assert
            System.assertEquals(1, results.size(), 'There should be one result from the call method');
            for (GenericFileUploaderController.fileResultWrapper result : results) {
                System.debug('Result ID: ' + result.Id + ', UploadingMessage: ' + result.UploadingMessage);
                System.assertNotEquals(null, result.Id, 'The result ID should not be null');
            }
        } finally {
            TestDataFactory.enableTriggers(); // Re-enable triggers
        }

        System.debug('Finished testCallMethod');
    }
}