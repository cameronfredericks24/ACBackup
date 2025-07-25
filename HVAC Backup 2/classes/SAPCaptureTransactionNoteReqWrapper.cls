global class SAPCaptureTransactionNoteReqWrapper {
    public List<Transaction_Note__c> transactionNote;

    global class TransactionNoteDetails {
        public String sfTransactionNoteId;
        public String transactionNoteId;
        public String amount;
        public String invoiceNumber;
        public String type;
        public String status;
        public String departmentNumber;
    }

    // Constructor to initialize the list
    public SAPCaptureTransactionNoteReqWrapper() {
        transactionNote = new List<Transaction_Note__c>();
    }
}