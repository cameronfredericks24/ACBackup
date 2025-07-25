({
   closeQAHelper :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    toastEvent : function(Title,Type,message) {
        var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                        title : Title,
                        message:message,
                        duration:'2000',
                        key: 'info_alt',
                        type: Type,
                        mode: 'dismissible'      
                    });
                    toastEvent.fire();
    },

getOtpStatus : function(component, event, helper) {
        //set spinner true
        component.set("v.spinner", true);
        console.log("hi start");

        // Assign server method to action variable
        var action = component.get("c.getIntialStatusOfOtp");
        var recordId = component.get('v.recordId');
        console.log("hi middle");

        // Setting parameters for server method
        action.setParams({
            recordId: recordId
        });
        console.log("hi end");

        // Callback function to get the response
        action.setCallback(this, function(response) {
            //set spinner false
            component.set("v.spinner", false);
            // Getting the response state
            var state = response.getState();
            // Check if response state is success
            if(state === 'SUCCESS') {
                console.log(' response.getReturnValue()-->'+JSON.stringify(response.getReturnValue()));
                // Getting the list of contacts from response and storing in js variable
                var responseWrapper = response.getReturnValue();
                if(responseWrapper.isSuccess){
                    component.set('v.showCmp',true);
                }
                else{
                 helper.toastEvent('Error Occured','error',responseWrapper.errorMessage);
                                    helper.closeQAHelper();

                }
            }
            else {
                // Show an alert if the state is incomplete or error
                helper.toastEvent('Error Occured','error','No response from server.Try Again');
                helper.closeQAHelper();
            }
        });
        // Adding the action variable to the global action queue
        $A.enqueueAction(action);
    },})