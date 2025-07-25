@isTest
private class ViewOrderSummaryControllerTest {

    @isTest
    static void testFetchProductDetails() {
        TestDataFactory.disableTriggers();
        List<Product2> testProducts = new List<Product2>();
        for(Integer i = 0; i < 5; i++) {
            testProducts.add(new Product2(Name='Test Product ' + i, ProductCode='CODE' + i));
        }
        
        System.runAs(Testdatafactory.createByPassUser()){
            insert testProducts;
                Testdatafactory.createStdPriceBookEntryList(testProducts);
            }

        List<Id> productIds = new List<Id>();
        for(Product2 prod : testProducts) {
            productIds.add(prod.Id);
        }

        // Call the method to test
        Test.startTest();
        List<Product2> result = viewOrderSummaryController.fetchProductDetails(productIds);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(5, result.size(), 'Number of returned products should match test data size');
        for(Integer i = 0; i < 5; i++) {
            System.assertEquals('Test Product ' + i, result[i].Name, 'Product name should match');
            System.assertEquals('CODE' + i, result[i].ProductCode, 'Product code should match');
        }
        
        TestDataFactory.enableTriggers();
    }
}