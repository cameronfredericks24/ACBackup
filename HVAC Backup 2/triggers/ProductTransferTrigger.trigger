trigger ProductTransferTrigger on ProductTransfer (after insert ) {
    TriggerDispatcher.run(new ProductTransferTriggerHandler(), 'ProductTransferTrigger');
}