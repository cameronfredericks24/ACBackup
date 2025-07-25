public without sharing class SAPCaptureTransactionNoteHelper {
    // Constants for the response
    public static final String SUCCESS_RESPONSE_RESULT = 'Success';
    public static final String ERROR_RESPONSE_RESULT = 'Error';
    public static final ID Debit_Note_RT = Schema.SObjectType.Transaction_Note__c.getRecordTypeInfosByDeveloperName().get('Debit_Note').getRecordTypeId();

    // Main method to handle capturing Transaction Note details
    public static SAPCaptureTransactionNoteResWrapper captureTransactionNoteDetails(List<SAPCaptureTransactionNoteReqWrapper.TransactionNoteDetails> transactionNotes) {
        // Initialize the response wrapper
        SAPCaptureTransactionNoteResWrapper responseWrapper = new SAPCaptureTransactionNoteResWrapper();
        List<Transaction_Note__c> lstInsertTransactionNote = new List<Transaction_Note__c>();
        List<Transaction_Note__c> lstUpdateTransactionNote = new List<Transaction_Note__c>();
        responseWrapper.transactionNoteIDs = new List<String>();

        try {
            // Validate that the transaction notes list is not empty
            if (transactionNotes == null || transactionNotes.isEmpty()) {
                responseWrapper.result = ERROR_RESPONSE_RESULT;
                responseWrapper.message = 'No Transaction Note data provided.';
                return responseWrapper;
            }

            // Collect all transaction note names and department numbers from the request
            Set<String> transactionNoteNames = new Set<String>();
            Set<String> departmentNumbers = new Set<String>();
            for (SAPCaptureTransactionNoteReqWrapper.TransactionNoteDetails note : transactionNotes) {
                if (note.sfTransactionNoteId != null) {
                    transactionNoteNames.add(note.sfTransactionNoteId); // Now checking by Name
                }
                if (note.departmentNumber != null) {
                    departmentNumbers.add(note.departmentNumber);
                }
            }

            // Query existing Transaction Notes with the provided Names
            Map<String, Transaction_Note__c> existingTransactionNotesMap = new Map<String, Transaction_Note__c>();
            if (!transactionNoteNames.isEmpty()) {
                for (Transaction_Note__c existingTransactionNote : [
                    SELECT Id, Name, Amount__c, Invoice_No__c, Type__c, Department__c 
                    FROM Transaction_Note__c
                    WHERE Name IN :transactionNoteNames
                ]) {
                    existingTransactionNotesMap.put(existingTransactionNote.Name, existingTransactionNote);
                }
            }

            // Query Department records based on department numbers
            Map<String, Id> departmentMap = new Map<String, Id>();
            if (!departmentNumbers.isEmpty()) {
                for (Department__c dept : [
                    SELECT Id, Department_Number__c
                    FROM Department__c
                    WHERE Department_Number__c IN :departmentNumbers
                ]) {
                    departmentMap.put(dept.Department_Number__c, dept.Id);
                }
            }

            // Step 5: Iterate over each Transaction Note and process them
            for (SAPCaptureTransactionNoteReqWrapper.TransactionNoteDetails note : transactionNotes) {
                // Retrieve the department Id based on departmentNumber if it exists
                Id departmentId = departmentMap.get(note.departmentNumber);

                if (existingTransactionNotesMap.containsKey(note.sfTransactionNoteId)) {
                    // Update existing record
                    Transaction_Note__c transactionNote = existingTransactionNotesMap.get(note.sfTransactionNoteId);
                    transactionNote.Amount__c = Decimal.valueOf(note.amount);
                    transactionNote.Transaction_Note_Id__c = note.transactionNoteId;
                    transactionNote.Invoice_No__c = note.invoiceNumber;
                    transactionNote.Type__c = note.type;
                    transactionNote.Status__c = note.status;
                    transactionNote.Transaction_Note_Id__c = note.transactionNoteId;

                    // Set the Department lookup if available
                    if (departmentId != null) {
                        transactionNote.Department__c = departmentId;
                    }

                    lstUpdateTransactionNote.add(transactionNote);

                    // Add the existing transaction note Name to the response list
                    responseWrapper.transactionNoteIDs.add(transactionNote.Name);
                } else {
                    // Create new record
                    Transaction_Note__c newTransactionNote = new Transaction_Note__c();
                    newTransactionNote.SF_Transaction_Note_Id__c = note.sfTransactionNoteId;
                    newTransactionNote.Transaction_Note_Id__c = note.transactionNoteId; 
                    newTransactionNote.Amount__c = Decimal.valueOf(note.amount);
                    newTransactionNote.Invoice_No__c = note.invoiceNumber;
                    newTransactionNote.Type__c = note.type;
                    newTransactionNote.Status__c = note.status;
                    newTransactionNote.RecordTypeId = Debit_Note_RT;

                    // Set the Department lookup if available
                    if (departmentId != null) {
                        newTransactionNote.Department__c = departmentId;
                    }

                    lstInsertTransactionNote.add(newTransactionNote);
                }
            }

            if (!lstInsertTransactionNote.isEmpty()) {
                insert lstInsertTransactionNote;

                // Fetch the inserted records to get the Names and add them to the response
                List<Transaction_Note__c> insertedRecords = [
                    SELECT Id, Name
                    FROM Transaction_Note__c
                    WHERE Id IN :lstInsertTransactionNote
                ];
                for (Transaction_Note__c insertedNote : insertedRecords) {
                    responseWrapper.transactionNoteIDs.add(insertedNote.Name);
                }
            }

            if (!lstUpdateTransactionNote.isEmpty()) {
                update lstUpdateTransactionNote;
            }

            // Set successful response
            responseWrapper.result = SUCCESS_RESPONSE_RESULT;
            responseWrapper.message = 'Transaction Note details captured successfully.';

        } catch (Exception e) {
            System.debug('Error in capturing Transaction Note details: ' + e.getMessage());
            responseWrapper.result = ERROR_RESPONSE_RESULT;
            responseWrapper.message = 'Error capturing Transaction Note details: ' + e.getMessage();
        }

        return responseWrapper;
    }
}