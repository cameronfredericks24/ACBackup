@RestResource(urlMapping='/sap/createinvoicepayments')
global class SAPInvoicePaymentAPI {

    @HttpPost
    global static List<SAPInvoicePaymentResponseWrapper> captureInvoice() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        List<SAPInvoicePaymentResponseWrapper> responseWrappers = new List<SAPInvoicePaymentResponseWrapper>();

        String jsonReqBody = req.requestBody.toString();
        SAPInvoicePaymentRequestWrapper reqWrap = (SAPInvoicePaymentRequestWrapper) JSON.deserialize(jsonReqBody, SAPInvoicePaymentRequestWrapper.class);
        
        try {


            // Call the method to capture invoice details
            responseWrappers = SAPInvoicePaymentHelper.createInvoicePayments(reqWrap);

        } catch (Exception e) {
            System.debug('exception: ' + e.getMessage());
            System.debug('line num: ' + e.getLineNumber());

            // Handle exceptions by creating a failure response for each request item
            for (SAPInvoicePaymentRequestWrapper.PaymentDetails reqWrapItem : reqWrap.paymentDetails) {
                SAPInvoicePaymentResponseWrapper responseWrapper = new SAPInvoicePaymentResponseWrapper();
                responseWrapper.result = SAPInvoicePaymentHelper.RESP_FAILURE_RESULT;
                responseWrapper.message = 'Unable to capture invoice details: ' + e.getMessage();
                responseWrapper.invoiceNumber = reqWrapItem.invoice_Number;
                responseWrapper.paymentTransactionNumber = reqWrapItem.payment_transaction_number;
                responseWrappers.add(responseWrapper);
            }
        }

        return responseWrappers;
    }
}