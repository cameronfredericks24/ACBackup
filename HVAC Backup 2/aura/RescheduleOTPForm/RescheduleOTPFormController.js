({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        console.log('recordId in aura ****' + recordId);
    },
    handleSuccess: function(component, event, helper) {
        console.log('handleSuccess');
    },
    handleSubmit: function(component, event, helper) {
        console.log('handleSubmit');
    },
     closeQA :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})