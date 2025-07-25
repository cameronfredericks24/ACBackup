({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        helper.getOtpStatus(component, event, helper);
    },
    handleSuccess: function(component, event, helper) {
        console.log('handleSuccess');
    },
    handleSubmit: function(component, event, helper) {
        console.log('handleSubmit');
    },
     closeQA :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
   closeOnOTP :function(component, event, helper){
         // Refresh the page
        $A.get("e.force:refreshView").fire();

        $A.get("e.force:closeQuickAction").fire();
    }

})