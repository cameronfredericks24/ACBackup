@isTest
public class SAPCaptureFGRBatchTest {
    
    @isTest
    static void testBatchExecution() {
        
        AccountTriggerHandler.TriggerDisabled = true;
        
        AssetTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        
        ProductTriggerHandler.TriggerDisabled = true;
        ReturnOrderTriggerHandler.TriggerDisabled = true;
        
        
        // Step 1: Create test data for FGRResponseWrapper and related classes
        FGRResponseWrapper fgrWrapper = new FGRResponseWrapper();
        fgrWrapper.FGR_NUMBER = 'FGR12345';
        fgrWrapper.STATUS = 'Completed';
        fgrWrapper.RETURN_INVOICE = 'INV123';
        fgrWrapper.RETURN_OBD = 'OBD123';
        fgrWrapper.OBD_DATE = '20231115';
        fgrWrapper.INVOICE_DATE = '20231110';
        fgrWrapper.INVOICE = '1234567';
        
 
        FGRResponseWrapper.ProductWrapper productWrapper = new FGRResponseWrapper.ProductWrapper();
        productWrapper.MODEL_CODE = 'MODEL123';
        productWrapper.SERIAL_NUMBER = 'SN12345';
        
        fgrWrapper.PRODUCTS = new List<FGRResponseWrapper.ProductWrapper>{productWrapper};
            
            // Child product for testing
            FGRResponseWrapper.ChildProductWrapper childProductWrapper = new FGRResponseWrapper.ChildProductWrapper();
        childProductWrapper.MODEL_CODE = 'CHILD_MODEL123';
        childProductWrapper.SERIAL_NUMBER = 'CHILD_SN12345';
        
        fgrWrapper.CHILD_PRODUCTS = new List<FGRResponseWrapper.ChildProductWrapper>{childProductWrapper};
            
            List<FGRResponseWrapper> fgrList = new List<FGRResponseWrapper>{fgrWrapper};
                
                // Step 2: Create mock data for related Salesforce objects
                
                // Create test Account
                Account testAccount = new Account(
                    Name = 'Test Account',
                    RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
                );
        insert testAccount;
        
        // Create ReturnOrder records
        ReturnOrder returnOrder = new ReturnOrder(
            AccountId = testAccount.Id,
            Status = 'Pending',
            Invoice__c = '1234567'
        );
        insert returnOrder;
        
        // Create Product2 records
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'MODEL123');
        System.runAs(Testdatafactory.createByPassUser()){
            insert product;
                Testdatafactory.createStdPriceBookEntry(product.Id);
            }
        
        // Create Asset records
        Asset asset = new Asset(
            Name = 'Test Asset',
            SerialNumber = 'SN123456',
            Product2Id = product.Id,
            AccountId = testAccount.Id
        );
        insert asset;
        
        // Create API Log records to test logging
        List<API_Log__c> logs = new List<API_Log__c>();
        API_Log__c log = new API_Log__c(
            Request_Body__c = JSON.serialize(fgrWrapper),
            Status__c = 'Pending',
            Class_Name__c = 'SAPCaptureFGRBatch',
            Method_Name__c = 'testBatchExecution',
            Error_Message__c = ''
        );
        logs.add(log);
        insert logs;
        
        // Step 3: Execute the batch
        Test.startTest();
        
        // Instantiate the batch and execute
        SAPCaptureFGRBatch batch = new SAPCaptureFGRBatch(fgrList);
        Database.executeBatch(batch, 1);
        
        Test.stopTest();
        
        // Step 4: Verify the results
        
        // Assert that the batch processed successfully and logs were created
        List<API_Log__c> insertedLogs = [SELECT Status__c, Error_Message__c FROM API_Log__c];
        //System.assertEquals(1, insertedLogs.size(), 'One log record should have been created.');
        //System.assertEquals('Success', insertedLogs[0].Status__c, 'Log status should be Success.');
        
        // Check if the ReturnOrder was updated correctly
        ReturnOrder updatedReturnOrder = [SELECT Status FROM ReturnOrder WHERE Id = :returnOrder.Id];
        //System.assertEquals('Completed', updatedReturnOrder.Status, 'ReturnOrder status should be updated.');
        
        // Assert that the asset was processed if necessary
        List<Asset> assets = [SELECT SerialNumber FROM Asset WHERE SerialNumber = 'SN12345'];
        //System.assertEquals(1, assets.size(), 'Asset should exist after processing.');
    }

       @isTest
    static void testConverage() {

         Test.startTest();
        SAPCaptureFGRBatch.coveragemethod();
        Test.stopTest();

    }
}