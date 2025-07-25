({
    handleCloseModal: function(component, event, helper) {
        // Close the containing modal
        var closeModal = $A.get("e.force:closeQuickAction");
        closeModal.fire();
    }
})