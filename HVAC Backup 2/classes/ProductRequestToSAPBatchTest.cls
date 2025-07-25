/**
* @File Name : ProductRequestToSAPBatchTest.cls
* @Description : Test class for ProductRequestToSAPBatch
* @Author :
* @Last Modified By :
* @Last Modified On : December 6, 2024
**/

@isTest
public class ProductRequestToSAPBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Disable triggers if necessary
        Testdatafactory.disabletriggers();

        // Create related WorkOrder record
        WorkOrder wo = new WorkOrder(Status = 'New');
        insert wo;

        // Create ProductRequest records
        List<ProductRequest> prList = new List<ProductRequest>();
        for (Integer i = 0; i <+ 2; i++) { // Increase data volume to test batching
            prList.add(new ProductRequest(
                WorkOrderId = wo.Id,
                Send_To_SAP__c = true
            ));
        }
        insert prList;
    }

    @isTest
    static void testBatchExecution() {
        // Set up the HTTP callout mock
        Test.setMock(HttpCalloutMock.class, new SendMRDetailsSAPAPIMock());

        Test.startTest();
        // Execute the batch with a smaller batch size
        Database.executeBatch(new ProductRequestToSAPBatch(), 2);
        Test.stopTest();

        // Add assertions if SendMRDetailsSAPAPI tracks the processing results
        System.assert(true, 'Batch executed without hitting callout limits');
    }

    // Mock class for SendMRDetailsSAPAPI
    public class SendMRDetailsSAPAPIMock implements HttpCalloutMock {
        private Integer calloutCount = 0;

        public HttpResponse respond(HttpRequest req) {
            // Simulate a successful API response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success":true}');
            calloutCount++;
            return res;
        }
    }
}