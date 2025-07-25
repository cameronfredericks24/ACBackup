@isTest
public class CustomerSelectorTest {

    @testSetup
    static void setupTestData() {
        // Create test Customer records
        Customer cust1 = new Customer(
            Name = 'Customer 1',
            Customer_Code__c = 'CUST001'
        );
        Customer cust2 = new Customer(
            Name = 'Customer 2',
            Customer_Code__c = 'CUST002'
        );
        Customer cust3 = new Customer(
            Name = 'Customer 3',
            Customer_Code__c = 'CUST003'
        );

        insert new List<Customer> { cust1, cust2, cust3 };
    }

    @isTest
    static void testGetCustomerIdsByCustomerCodes() {
        // Prepare a set of customer codes to test
        Set<String> customerCodes = new Set<String> { 'CUST001', 'CUST002', 'CUST003', 'CUST999' };

        // Call the method under test
        Test.startTest();
        Map<String, Id> result = CustomerSelector.getCustomerIdsByCustomerCodes(customerCodes);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(0, result.size(), 'The result map should not be empty.');
        System.assertEquals(3, result.size(), 'The result map should contain 3 entries, as one of the codes does not exist.');

        // Verify that each customer code is mapped to the correct ID
        for (String code : new Set<String> { 'CUST001', 'CUST002', 'CUST003' }) {
            System.assert(result.containsKey(code), 'The result should contain the customer code: ' + code);
            System.assertNotEquals(null, result.get(code), 'The customer ID for code ' + code + ' should not be null.');
        }

        // Verify that the non-existent customer code does not appear in the result
        System.assert(!result.containsKey('CUST999'), 'The result should not contain the customer code: CUST999');
    }
}