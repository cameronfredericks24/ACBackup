<aura:application implements="flexipage:availableForAllPageTypes" access="global" extends="force:slds">
  <!-- To see the result easily, we are using an aura application instead of aura component. 
  But the syntax is the same-->
    	<aura:html tag="style">             
         .slds-modal__container{        
        width: 100% !important;
        max-width: 80rem !important; 
        }      
     
        .slds-modal__content {
            padding : 0.01rem !important;
            height: 100% !important;
        	max-height: 80rem !important;
        }
       .slds-modal__footer {
        display: none    
       }
    </aura:html>

  <c:otpValidationForm></c:otpValidationForm>
</aura:application>