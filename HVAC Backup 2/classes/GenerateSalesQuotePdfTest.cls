@isTest
public class GenerateSalesQuotePdfTest {
    @isTest
    static void testCreatePDF() {
        // Disable triggers using TestDataFactory
        TestDataFactory.disableTriggers();

        try {
            // Step 1: Create Test Data
            Id channelPartnerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Channel_Partner').getRecordTypeId();
            Id commercialCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Customer').getRecordTypeId();

            Account testAccount = new Account(
                Name = 'Test Account',
                Phone = '9901459434',
                Email__c = 'testaccount@example.com',
                BillingCountry = 'India',
                BillingState = 'Maharashtra',
                BillingPostalCode = '400001',
                BillingCity = 'Mumbai',
                BillingStreet = '123 Street',
                ShippingCountry = 'India',
                ShippingState = 'Maharashtra',
                ShippingPostalCode = '400001',
                ShippingCity = 'Mumbai',
                ShippingStreet = '123 Street',
                Is_active__c = false,
                RecordTypeId = channelPartnerRT
            );
            insert testAccount;

            testAccount.RecordTypeId = commercialCustomerRT;
            update testAccount;
 // Create a test Service Contract
        ServiceContract testServiceContract = new ServiceContract(
            name = 'Test Service Contract',
            startDate = Date.today(),
            EndDate = Date.today().addDays(90)
        );
        insert testServiceContract;
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                AccountId = testAccount.Id,
                Service_Contract__c = testServiceContract.Id
            );
            insert testOpportunity;

            Quote testQuote = new Quote(
                Name = 'Test Quote',
                OpportunityId = testOpportunity.Id,
                BillingName = testAccount.Name,
                BillingStreet = testAccount.BillingStreet,
                BillingCity = testAccount.BillingCity,
                BillingState = testAccount.BillingState,
                BillingPostalCode = testAccount.BillingPostalCode,
                BillingCountry = testAccount.BillingCountry,
                ShippingName = testAccount.Name,
                ShippingStreet = testAccount.ShippingStreet,
                ShippingCity = testAccount.ShippingCity,
                ShippingState = testAccount.ShippingState,
                ShippingPostalCode = testAccount.ShippingPostalCode,
                ShippingCountry = testAccount.ShippingCountry,
                Service_Contract__c = testServiceContract.Id
            );
            insert testQuote;

            // Step 2: Mock PDF generation
            Test.startTest();

            // Call the createPDF method
            GenerateSalesQuotePdf.createPDF(
                testQuote.Id,
                'recipient@example.com'
            );

            // Explicitly call the sendEmailAttachment method to test it
            Blob testBlob = Blob.valueOf('Test PDF content');
            ContentVersion testContentVersion = new ContentVersion(
                Title = 'Quote',
                PathOnClient = 'Quote.pdf',
                VersionData = testBlob
            );
            insert testContentVersion;

            List<ContentVersion> docList = [SELECT Id, Title FROM ContentVersion WHERE Id = :testContentVersion.Id];
            GenerateSalesQuotePdf.sendEmailAttachment(docList, 'recipient@example.com', testBlob);

            Test.stopTest();

            // Assertions
            List<QuoteDocument> quoteDocuments = [SELECT Id, QuoteId, Document FROM QuoteDocument WHERE QuoteId = :testQuote.Id];
            System.assertEquals(1, quoteDocuments.size(), 'One QuoteDocument should be created.');
            System.assertNotEquals(null, quoteDocuments[0].Document, 'QuoteDocument should contain a generated PDF.');
        } finally {
            TestDataFactory.enableTriggers();
        }
    }

    @isTest
    static void testCreatePDFAMTCoupon() {
        TestDataFactory.disableTriggers();

        try {
            Id channelPartnerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Channel_Partner').getRecordTypeId();
            Id commercialCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Customer').getRecordTypeId();

            Account testAccount = new Account(
                Name = 'Test Account',
                Phone = '9945823138',
                Email__c = 'testaccount@example.com',
                BillingCountry = 'India',
                BillingState = 'Maharashtra',
                BillingPostalCode = '400001',
                BillingCity = 'Mumbai',
                BillingStreet = '123 Street',
                ShippingCountry = 'India',
                ShippingState = 'Maharashtra',
                ShippingPostalCode = '400001',
                ShippingCity = 'Mumbai',
                ShippingStreet = '123 Street',
                Is_active__c = false,
                RecordTypeId = channelPartnerRT
            );
            insert testAccount;

            testAccount.RecordTypeId = commercialCustomerRT;
            update testAccount;

            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                AccountId = testAccount.Id
            );
            insert testOpportunity;

            Quote testQuote = new Quote(
                Name = 'Test Quote',
                OpportunityId = testOpportunity.Id,
                BillingName = testAccount.Name,
                BillingStreet = testAccount.BillingStreet,
                BillingCity = testAccount.BillingCity,
                BillingState = testAccount.BillingState,
                BillingPostalCode = testAccount.BillingPostalCode,
                BillingCountry = testAccount.BillingCountry,
                ShippingName = testAccount.Name,
                ShippingStreet = testAccount.ShippingStreet,
                ShippingCity = testAccount.ShippingCity,
                ShippingState = testAccount.ShippingState,
                ShippingPostalCode = testAccount.ShippingPostalCode,
                ShippingCountry = testAccount.ShippingCountry
            );
            insert testQuote;

            // Step 2: Prepare Invocable Method Input
            GenerateSalesQuotePdf.PDFParams pdfParams = new GenerateSalesQuotePdf.PDFParams();
            pdfParams.quoteId = testQuote.Id;
            pdfParams.recipientEmail = 'recipient@example.com';

            List<GenerateSalesQuotePdf.PDFParams> paramsList = new List<GenerateSalesQuotePdf.PDFParams> { pdfParams };

            // Step 3: Mock Future Callout and Test Invocable Method
            Test.startTest();
            GenerateSalesQuotePdf.createPDFAMTCoupon(paramsList);
             ScheduleBatchSalesQuotePDFScheduler.scheduleBatch();
       
            Test.stopTest();

        } finally {
            TestDataFactory.enableTriggers();
        }
    }
}