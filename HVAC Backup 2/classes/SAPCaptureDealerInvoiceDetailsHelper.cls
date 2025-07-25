public with sharing class SAPCaptureDealerInvoiceDetailsHelper {

    public static final Id dealerRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Dealer_Invoice').getRecordTypeId();

    public static List<SAPCaptureDealerInvoiceDetailsResWrapper> createDealerInvoice(List<SAPCaptureDealerInvoiceDetailsReqWrapper.InvoiceDetails> reqWrapperListData) {

        List<SAPCaptureDealerInvoiceDetailsResWrapper> resWrapperList = new List<SAPCaptureDealerInvoiceDetailsResWrapper>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();

        // Collect all invoice numbers from the request data
        Set<String> invoiceNumbers = new Set<String>();
        for (SAPCaptureDealerInvoiceDetailsReqWrapper.InvoiceDetails invoiceData : reqWrapperListData) {
            if (invoiceData.invoiceNo != null && invoiceData.invoiceNo != '') {
                invoiceNumbers.add(invoiceData.invoiceNo);
            }
        }

        // Retrieve existing invoices in bulk to check for duplicates
        Map<String, Invoice__c> existingInvoicesMap = InvoiceSelector.getInvoicesByNumbers(invoiceNumbers);

        for (SAPCaptureDealerInvoiceDetailsReqWrapper.InvoiceDetails invoiceData : reqWrapperListData) {
            SAPCaptureDealerInvoiceDetailsResWrapper resWrapper = new SAPCaptureDealerInvoiceDetailsResWrapper();
            resWrapper.invoiceNumber = invoiceData.invoiceNo;

            // Check for duplicate invoice number
            if (existingInvoicesMap.containsKey(invoiceData.invoiceNo)) {
                resWrapper.status = 'Failed';
                resWrapper.errorMessage = 'Duplicate invoice number: ' + invoiceData.invoiceNo;
            } else {
                Invoice__c invoice = new Invoice__c();

                if (invoiceData.cpCode != null && invoiceData.cpCode != '') {
                    invoice.CP_Code__c = invoiceData.cpCode;
                }

                if (invoiceData.invoiceNo != null && invoiceData.invoiceNo != '') {
                    invoice.Invoice_No__c = invoiceData.invoiceNo;
                }

                if (invoiceData.invoiceDate != null && invoiceData.invoiceDate != '') {
                    invoice.Invoice_Date__c = Date.valueOf(invoiceData.invoiceDate);
                }

                if (invoiceData.dueDate != null && invoiceData.dueDate != '') {
                    invoice.Due_Date__c = Date.valueOf(invoiceData.dueDate);
                }

                if (invoiceData.payableOrReceivable != null && invoiceData.payableOrReceivable != '') {
                    invoice.Payable_Receivable__c = invoiceData.payableOrReceivable;
                }

                if (invoiceData.invoiceAmount != null && invoiceData.invoiceAmount != '') {
                    Decimal amount = Decimal.valueOf(invoiceData.invoiceAmount).setScale(2, RoundingMode.HALF_UP);
                    invoice.Total_Amount__c = amount;
                }

                if (invoiceData.status != null && invoiceData.status != '') {
                    invoice.Status__c = invoiceData.status;
                }

                if (invoiceData.flag != null && invoiceData.flag != '') {
                    invoice.Flag__c = invoiceData.flag;
                }

                if (invoiceData.paymentAdjusted != null) {
                    invoice.Payment_Adjusted__c = invoiceData.paymentAdjusted;
                }
                invoice.recordtypeId = dealerRecordTypeId;

                invoiceList.add(invoice);
                resWrapper.status = 'Success';
                resWrapper.errorMessage = 'Invoice created successfully';
            }

            resWrapperList.add(resWrapper);
        }

        if (!invoiceList.isEmpty()) {
            try {
                insert invoiceList;
            } catch (DmlException e) {
                // Handle bulk insert errors
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    SAPCaptureDealerInvoiceDetailsResWrapper resWrapper = new SAPCaptureDealerInvoiceDetailsResWrapper();
                    resWrapper.invoiceNumber = invoiceList[i].Invoice_No__c;
                    resWrapper.status = 'Failed';
                    resWrapper.errorMessage = 'Error in record with Invoice Number ' + invoiceList[i].Invoice_No__c + ': ' + e.getDmlMessage(i);
                    resWrapperList.add(resWrapper);
                }
            }
        }

        return resWrapperList;
    }
}