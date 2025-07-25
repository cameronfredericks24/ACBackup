import { LightningElement, api, track , wire} from 'lwc';
import getContacts from  '@salesforce/apex/CancelCaseCustomerRequestController.getContacts'
import getWorkOrders from '@salesforce/apex/CancelCaseCustomerRequestController.getWorkOrders'
import generateOTP from '@salesforce/apex/CancelCaseCustomerRequestController.generateOTP';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import logoResource from '@salesforce/resourceUrl/Logo';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import getWorkOrdersLineItems from '@salesforce/apex/CancelCaseCustomerRequestController.getWorkOrdersLineItems';
import {CurrentPageReference} from 'lightning/navigation';

const acccolumns = 
[
{label : "Account Names" ,fieldName: "Name"},
{label : "Account Email" ,fieldName: "Email"},
{label: "Account Phone", fieldName:"Phone"}

]
const  columns =[
    {label : "Contact Names" ,fieldName: "Name"},
    {label : "Contact Email" ,fieldName: "Email"},
    {label: "Contact Phone", fieldName:"Phone"}
]



export default class CancelCaseOnCustomerRequest  extends NavigationMixin(LightningElement)  {

@api recordId;
 @track data = {};
@api accountId;
@api contacts;
@track relatedContacts={};
@track acccolumns= acccolumns;
@track columns= columns;
@track cardVisible = false;
selectedContact;
workOrderId;
workOrderLineItemId;
@track cancelReason='';
@track comments='';
@track showOTPSection = false;
@track showPage = false;
@track otpValues = ['', '', '', '', '',''];
@track otpValue1='';
@track otpValue2='';
@track otpValue3='';
@track otpValue4='';
@track otpValue5='';
@track otpValue6='';
@track otpValue= '';
@track disabledVerify = true;
@track otpGenerated =false;
@track disabledGenerate = true;



get logoUrl() {
    return logoResource;
}
constructor(){
    super();
}
connectedCallback() {
    console.log('this.recordId c',this.recordId);
    setTimeout(() => {
       
        console.log('this.recordId f',this.recordId);
        this.checkWorkOrders();
    }, 5);
     
        
}



//Check if work orders exist for the case
async checkWorkOrders(){
    //console.log('result',result);
    try{
        console.log('this.recordId s',this.recordId);
        const result = await getWorkOrders({recordId:this.recordId})
        
        console.log('result-->'+JSON.stringify(result));
        if(result ==''){
            console.log('result',result);
                
            this.showMessage('Notification','Case cannot be cancelled as work order has MR Already','success');
            this.navigateToCase();
        }
       else{
        console.log('result value',result);
                    if(result == 'No'){
                      console.log('no work order');
                    }else{
                        this.workOrderId =  result;
                    }
                    
                    
                    this.showPage = true;
                    console.log('this.workOrderId',this.workOrderId);
                    this.handleButtonClick();
            }
    }
   
   catch(error){
    console.log('error', error.body.message);
        
    this.navigateToCase();
   }
      
    }
    
    

   

    

//Method to get contacts
  handleButtonClick(){
    // Call Apex method to retrieve related contacts
    getContacts({recordId:this.recordId})
    .then(result =>{
            console.log('result', result);
            
            if(result != null){

               
                
            this.data = result;
            console.log('this.relatedContacts', this.data);
            //this.data.push(this.formatData(result));
            
            this.cardVisible = true;
            }
            
    }) .catch(error => {
        
        console.log(error);
    });
   
}


formatData(data) {
    let formattedData = [];
    data.forEach(account => {
      
     if (account.Contacts && account.Contacts.length > 0) {
            account.Contacts.forEach(contact => {
                formattedData.push({
                    id: contact.Id,
                    name: contact.Name,
                    email: contact.Email
                });
                console.log('formattedData '+ JSON.stringify(formattedData));
            });
        }
    });
    return formattedData;
}





//Method for selecting contacts
handleRowSelection(event){
        this.selectedContact = event.detail.selectedRows;
   // alert('selected rows '+ JSON.stringify(this.selectedContact[0]));

   
    console.log('selected rows'+ this.selectedContact[0].Email);
    this.showOTPSection = true;
}



//Method to generate OTP
generateOTP() {
    console.log('this.cancelReason',this.cancelReason);
    if( this.cancelReason && this.cancelReason.trim() !== ''){
        console.log(this.recordId);
        console.log(this.selectedContact[0].Email);
        //const emails = this.selectedContact.map(contact => contact.Email);
        generateOTP({ recordId:this.recordId ,email: this.selectedContact[0].EmailActual })
        .then(result => {
            this.otp = result;
            this.otpGenerated = true;
            this.disabledGenerate =false;
            this.error = undefined;
            this.showMessage('Notification','OTP sent to your Email','success');
            console.log('this.otp',this.otp);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                        title: 'Error Updating record',
                        message: error.body.message,
                        variant: 'error'
                })
        );
            this.error = error.body.message;
        });
    }else{
        this.showMessage('Notification','Please Add Cancel reason','error');
    }
    
}




//Handle input for verify otp
handleInput(event) {
    const target = event.target;
    const val = target.value;
    const inputIndex = target.dataset.index;
    if (isNaN(val)) {
        target.value = "";
        return;
    }

    if (val !== "") {
            this.otpValues[inputIndex] = val;
        this.otpValues = [...this.otpValues]; // Update the tracked array to trigger reactivity
        if(inputIndex==0){
            this.otpValue1 = val;
        }
        else if(inputIndex==1){
            this.otpValue2 = val;
        }
        else if(inputIndex==2){
            this.otpValue3 = val;
        }
        else if(inputIndex==3){
            this.otpValue4 = val;
        }
        else if(inputIndex==4){
            this.otpValue5 = val;
        }

        else{
            this.otpValue6 = val;
    
        }
        if(this.otpValues[0] != '' && this.otpValues[1] !='' && this.otpValues[2] !='' && this.otpValues[3] !='' && this.otpValues[4] !='' && this.otpValues[5] !=''){
            this.disabledVerify = false
        }
        else{
            this.disabledVerify = true
        }
        const next = target.nextElementSibling;
        if (next) {
            next.focus();
        }
    }
    else{
        this.otpValues[inputIndex] = '';
        this.otpValues = [...this.otpValues]; // Update the tracked array to trigger reactivity
        if(inputIndex==0){
            this.otpValue1 = '';
        }
        else if(inputIndex==1){
            this.otpValue2 = '';
        }
        else if(inputIndex==2){
            this.otpValue3 = '';
        }
        else if(inputIndex==3){
            this.otpValue4 = '';
        }
        else if(inputIndex==4){
            this.otpValue5 = '';
        }
        else{
            this.otpValue6 = '';
    
        }
        if(this.otpValues[0] != '' && this.otpValues[1] !='' && this.otpValues[2] !='' && this.otpValues[3] !='' && this.otpValues[4] !='' && this.otpValues[5] !=''){
            this.disabledVerify = false
        }
        else{
            this.disabledVerify = true
        }
    }
}  


handleKeyUp(event) {
    const target = event.target;
    const key = event.key.toLowerCase();
    console.log('key-->'+key);
    if (key === "backspace" || key === "delete" ) {
        target.value = "";
        const prev = target.previousElementSibling;
        if (prev) {
            prev.focus();
        }
        return;
    }
    else if(key === 'arrowleft'){
        const prev = target.previousElementSibling;
        if (prev) {
            prev.focus();
        }
        return;
    }
    else if(key === "arrowright"){
        const next = target.nextElementSibling;
        if (next) {
            next.focus();
        }
        return;
    }
}



//Method to validate Input
validateInput() {
    
    const isValid = /^\d{6}$/.test(this.otpValue) && this.otpValue.trim() !== '';
        console.log('isValid');
    if (!isValid) {
        return false
    }
    return true;
}


//Capture Cancel reason
handleCancelReason(events){
    this.cancelReason = events.target.value;
    console.log('this.cancelReason '+ this.cancelReason);
   
        this.disabledGenerate =false;
    
    
    console.log('this.disabledGenerate '+ this.disabledGenerate);
}


//Verify otp sections
verifyOTP(){
    
    this.otpValue = this.otpValues[0] + this.otpValues[1] + this.otpValues[2] + this.otpValues[3] + this.otpValues[4] +this.otpValues[5]
    
    var code  =  this.otpValue;
    console.log('code '+ code);
    console.log('this.otp',this.otp);
    console.log('this.validateInput()'+ this.validateInput());
    if(code!=undefined && code!==null && this.validateInput())
    {
        if(this.otp!==code)
        {
            this.showMessage('Notification','OTP is not matching, please try again','error'); 
        }
else{
    this.showMessage('Notification','OTP verification is completed','success'); 
        //this.getWorkOrdersLineItems();
        if(this.workOrderId!=null){
            this.updateWorkOrder();
        }
        
        }
    }
}

updatecasecanceled(){
     const fields = {};
        fields['Id'] = this.recordId; //populate it with current record Id
        fields['Status'] = 'Canceled';
        fields['Case_Canceled_from_Process__c'] =true; 

        fields['Happy_Code__c']= this.otp;
        console.log('this.otp; '+ this.otp);
        console.log('this.comments; '+ this.comments);
        console.log('this.cancelReason;'+ this.cancelReason);
        fields['Cancellation_Reason__c']= this.cancelReason;
        fields['Service_Ticket_Status__c'] = 'Canceled';
        
        fields['Comments'] = this.comments;
         const recordInput = { fields };

        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: 'Record updated',
                variant: 'success'
        })
);
       this.navigateToCase();
    }).catch(error => {
        console.log('error Case'+ error.body.message);
             this.dispatchEvent(
                  new ShowToastEvent({
                title: 'Error Updating record',
                message: error.body.message,
                variant: 'error'
        })
);
});
}


//Update work order status to canceled
updateWorkOrder(){
    const fields = {};
        fields['Id'] = this.workOrderId; //populate it with current record Id
        fields['Status'] = 'Canceled'; 
        fields['OTP_Verified__c'] = true;
        
         const recordInput = { fields };
        console.log('recordInput'+  recordInput);
        updateRecord(recordInput)
        .then(() => {
            this.updatecasecanceled();
            this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: 'Record updated',
                variant: 'success'
        })
);
      
    }).catch(error => {
        console.log('error WO'+ error.body.message);
          this.dispatchEvent(
              new ShowToastEvent({
                title: 'Error Updating record',
                message: error.body.message,
                variant: 'error'
        })
);
});

  
}


//to update work order line item status to Canceled
getWorkOrdersLineItems(){
    if(this.workOrderId != null){
        getWorkOrdersLineItems({recordId:this.workOrderId})
    .then(result=>{
        if(result != null){
            this.workOrderLineItemId = result;
            const fields = {};
            fields['Id'] = this.workOrderLineItemId; //populate it with current record Id
            fields['Status'] = 'Canceled'; 
            
             const recordInput = { fields };
    
            updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record updated',
                    variant: 'success'
            })
    );
           
        }).catch(error => {
              this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Error Updating record',
                    message: error.body.message,
                    variant: 'error'
            })
    );
    });
        }
    })
    }
    
}





showMessage( t, m,type ){
    const toastEvt = new ShowToastEvent({
        title: t,
        message:m,
        variant: type
    });
    this.dispatchEvent(toastEvt);
};



navigateToCase(){
    //this.showSpinner=true;
    console.log('Navigate ');
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            actionName: 'view'
        }
    });
}

}