({    
    doInit : function (component, event, helper) {
    	let urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({
      		"url": "/lightning/n/Create_Order?c__recordId="+component.get("v.recordId")+"&&c__recordType=SalesOrder",
    	});
    	urlEvent.fire();
	}
    
})