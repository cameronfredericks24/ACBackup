import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent from Lightning Message Service
import validateOTP from '@salesforce/apex/OtpController.validateCanceledOTP';
import getContactEmail from '@salesforce/apex/OtpController.getContactEmailforCanceled';
import getContactPhone from '@salesforce/apex/OtpController.getContactPhone';
import getRelatedContactEmails from '@salesforce/apex/OtpController.getRelatedContactEmails';

import resetOTP from '@salesforce/apex/OtpController.resetCanceledOTP';
import sendOTP from '@salesforce/apex/OtpController.sendOTP';
import updateStatusCanceled from '@salesforce/apex/OtpController.updateStatusCanceled';
import logoResource from '@salesforce/resourceUrl/Logo';
import getCancellationReasonOptions from '@salesforce/apex/OtpController.getCancellationReasonOptions'; // Import the Apex method to fetch picklist values
import { updateRecord } from 'lightning/uiRecordApi';
import workorderisCompleted from '@salesforce/apex/StartWorkController.isWorkOrderCompleted'; 

export default class otpCancelationForm extends LightningElement {
    @api cancellationReason;
    @api comment;
    @track cancellationReasonOptions = [];
    @track showCancellationReason = false;
    @track otp;
    @track disabledVerify = true;
    @track showForm = true;
    @track showExpired = false;
    @track showSuccess = false;
    @track showError = false;
    @track showOTPAlreadyVerified = false;
    @track contactEmail;
    @track contactPhone;
    @track verified = true;
    @track otpValues = ['', '', '', ''];
    @track otpValue1='';
    @track otpValue2='';
    @track otpValue3='';
    @track otpValue4='';
     @track otpValue= '';
     @track iscompleted = false;
     @track showWorkCompletedMessage = false;
     showOTPVerification = true;
     showOtpsent=false;


     @track contactNumberOptions = [];
     @track selectedContactNumbers = [];
     @track email;
     @track phone;

     @track selectedContactEmail; // Track the selected contact email
     @track contactOptions = []; // Options for the related contact emails
     @track disable = false
     @track choosenSelectEmails ='';

    @api recordId; // This will contain the Id of the current record
    get logoUrl() {
        return logoResource;
    }

    async connectedCallback() {
        await this.fetchCancellationReasonOptions();
        //await this.proceedToOTP();
        await this.fetchContactEmail();
        await this.isworkOrderCompleted();
        await this.fetchContactPhone();
        await this.fetchRelatedContactEmails();


       
    }

    maskEmail(email) {
        if (!email) return '';
        const [localPart, domain] = email.split("@");
        const maskedLocalPart = localPart.substring(0, 2) + "******";
        return `${maskedLocalPart}@${domain}`;
    }

    maskPhone(phone) {
        
        if (!phone) return '';
        return  "******" + phone.substring(6,11 );
    }

    allMaskedEmail(){
        if(this.choosenSelectEmails!=''){
            this.email =  this.choosenSelectEmails;
        }else{
            this.email = this.contactEmail;
        }
    }

    allMaskedPhone() {
        var temp='';
        this.selectedContactNumbers.forEach(contact => {
            temp+= this.maskPhone(contact) + ' , ';
        });

        if(temp==''){
            this.phone = this.maskPhone(this.contactPhone);
        }else{
            this.phone=  temp.slice(0, -1); 
        }
    }

        async isworkOrderCompleted() {
        try {
            const result = await workorderisCompleted({
               recordId:this.recordId
            });
            console.log('result:' +result)
            this.showWorkCompletedMessage = result;
        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }

    async fetchCancellationReasonOptions() {
        try {
            const result = await getCancellationReasonOptions();
            if (result) {
                // Format the data into label-value pairs for combobox options
                this.cancellationReasonOptions = result.map(option => ({
                    label: option,
                    value: option
                }));
            }
        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }

    handleCancellationReasonInput(event) {
        this.cancellationReason = event.target.value;
    }
     onnext(){
          this.showCancellationReason = false;
            this.showOTPVerification = true;
     }

    async fetchContactEmail() {
        try {
            const result = await getContactEmail({ recordId: this.recordId });
            console.log('result-->'+JSON.stringify(result));
            if (result.isSuccess) {
                this.contactEmail = result.ContactEmail;
                this.email = this.contactEmail;
                 if (result.OTPVerified) {
                    this.showOTPAlreadyVerified = false;
                    this.showForm = false;
                 }
                // Handle error
            }
        } catch (error) {
            console.error('Error fetching contact email', error);
            // Handle error
        }
    }

    async fetchContactPhone() {
        try {
            const result = await getContactPhone({ recordId: this.recordId });
            console.log('result-->'+JSON.stringify(result));
            if (result.isSuccess) {
                debugger;
                this.contactPhone = result.ContactPhone;
                this.phone = this.maskPhone(this.contactPhone);
                this.otpSent = result.isOTPAvailable;
                 if (result.OTPVerified) {
                    this.showOTPAlreadyVerified = false;
                    this.showForm = false;
                 }
                 if(result.workType=='Breakdown'){
                   // this.showWorkOrderForm=true;
                 }
                // Handle error
            }
        } catch (error) {
            console.error('Error fetching contact email', error);
            // Handle error
        }
    }

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
            else{
                this.otpValue4 = val;
     
            }
            if(this.otpValues[0] != '' && this.otpValues[1] !='' && this.otpValues[2] !='' && this.otpValues[3] !=''){
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
            else{
                this.otpValue4 = '';
     
            }
            if(this.otpValues[0] != '' && this.otpValues[1] !='' && this.otpValues[2] !='' && this.otpValues[3] !=''){
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
    validateInput() {
        const isValid = /^\d{4}$/.test(this.otpValue) && this.otpValue.trim() !== '';

        if (!isValid) {
            // Perform error handling or display error message
            // For example, show an error toast message
          

            return false
        }
        return true;
    }
     async validateOTP() {
    this.otpValue = this.otpValues[0] + this.otpValues[1] + this.otpValues[2] + this.otpValues[3];
         console.log('this.otpValue-->'+this.otpValue);
         console.log('this.validateInput()-->'+this.validateInput());
         if(this.validateInput()) {
                try {
                const result = await validateOTP({ otp:this.otpValue , recordId: this.recordId });
                console.log('result-->'+JSON.stringify(result));
                if (!result.isSuccess) {
                    console.error('No contact email found');
                    if(result.isExpired){
                        this.showExpired = true;
                         const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Otp is Expired ! Please click reset OTP to generate new one',
                variant: 'error'
            });
                        this.showForm = false;
                    } else if(result.isInvalid){
                        this.showError = true;
                    }
                    const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: result.errorMessage,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                    // Handle error
                } else {
                    this.contactEmail = result.ContactEmail;
                    this.showSuccess = false;
                    this.showForm = false;
                    await updateStatusCanceled({ recordId: this.recordId , status : 'Canceled', otpVerified : this.verified, cancellationreason:this.cancellationReason, comment:this.comment });
                    this.iscompleted = true;
                    //const toastEvent = new ShowToastEvent({
                    //title: 'Success!',
                    //message: 'OTP Verified successfully.',
                    //variant: 'success'
                //});  
                //this.dispatchEvent(toastEvent);
                setTimeout(() => {
                    const myEvent = new CustomEvent("otpsuccess", {
                        detail: {
                            otpSuccess: true,
                        },
                    });
                    this.dispatchEvent(myEvent);
                }, 2000);
               
            } 
            }catch (error) {
                console.error('Error fetching contact email', error);
                // Handle error
            }
        }
        else{
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter 4 Digit OTP.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
       
    }

    async sendOTP() {
        try {
          

        // Call the Apex method to send new OTP
        await sendOTP({ recordId: this.recordId, electedEmails: this.choosenSelectEmails ? this.choosenSelectEmails:'', phoneNumbers: this.selectedContactNumbers.length>0 ? this.selectedContactNumbers : []  });
        // Display a toast message indicating that the OTP has been sent successfully
        this.allMaskedEmail();
        this.allMaskedPhone();
        const newToastEvent = new ShowToastEvent({
            title: 'Success!',
            message: 'New OTP sent successfully.',
            variant: 'success'
        });
        this.dispatchEvent(newToastEvent);
        this.showOtpsent = true;
        } catch (error) {
            console.error('Error resending OTP', error);
            // Handle error
            // Display an error toast message if resending OTP fails
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to resend OTP. Please try again.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }
    async resendOTP() {
        try {
            // Call the Apex method to resend OTP
            await resendOTP({ recordId: this.recordId, selectedEmails: this.choosenSelectEmails ? this.choosenSelectEmails:'', phoneNumbers: this.selectedContactNumbers.length>0 ? this.selectedContactNumbers : []  });
            // Display a toast message indicating that the OTP has been resent successfully
            this.allMaskedEmail();
            this.allMaskedPhone();
            const toastEvent = new ShowToastEvent({
                title: 'Success!',
                message: 'OTP resent successfully.',
                variant: 'success'
            });
            this.dispatchEvent(toastEvent);

        // Call the Apex method to send new OTP
        //await sendOtp({ recordId: this.recordId });
        // Display a toast message indicating that the OTP has been sent successfully
        /*const newToastEvent = new ShowToastEvent({
            title: 'Success!',
            message: 'New OTP sent successfully.',
            variant: 'success'
        });
        this.dispatchEvent(newToastEvent);*/
        } catch (error) {
            console.error('Error resending OTP', error);
            // Handle error
            // Display an error toast message if resending OTP fails
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to resend OTP. Please try again.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }

    async resetOTP() {
    try {
        await resetOTP({ recordId: this.recordId, selectedEmails: this.choosenSelectEmails ? this.choosenSelectEmails:'', phoneNumbers: this.selectedContactNumbers.length>0 ? this.selectedContactNumbers : []  });
        // Display a toast message indicating that the OTP has been reset successfully
        this.allMaskedEmail();
        this.allMaskedPhone();
        const toastEvent = new ShowToastEvent({
            title: 'Success!',
            message: 'OTP reset successfully.',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
        // Reset form and display form
        this.showExpired = false;
        this.showSuccess = false;
        this.showError = false;
        this.showForm = true;
        this.otpValue1 = '';
        this.otpValue2 = '';
        this.otpValue3 = '';
        this.otpValue4 = '';
        this.otpValue = '';
        this.otpValues = [];
    } catch (error) {
        console.error('Error resetting OTP', error);
        // Handle error
        // Display an error toast message if resetting OTP fails
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'Failed to reset OTP. Please try again.',
            variant: 'error'
        });
        this.dispatchEvent(toastEvent);
    }
}

handleBackClick(event) {
    // Emit custom event on back click
    const backClick = new CustomEvent('backclick', {});
    this.dispatchEvent(backClick);
}

async fetchRelatedContactEmails() {
    try {
        // Call Apex method to get related contact emails
        const result = await getRelatedContactEmails({ workOrderId: this.recordId });
        // Format the response to match combobox options structure
        console.log('result',result);
        /*this.contactOptions = result.map(contact => {
            return {
                key: contact.Email,
                value: contact.Email
            };
        });*/

        this.contactNumberOptions = [];
        var count=0;

        result.forEach(contact => {
            console.log('contact',contact);
            console.log('contact',contact.Account.RecordType.DeveloperName);
            if(contact.Account.RecordType.DeveloperName == 'Residential_Customer'){
                if(count==0){
                    console.log('here');
                    var record={};
                    record.key= this.maskPhone(contact.Account.Phone) + ' - ' + contact.Account.Name ;
                    record.value= contact.Account.Phone;
                    this.contactNumberOptions.push({ value: record.key, key: record.value});

                    if(contact.Account.Secondary_Phone_No__c!=null){
                        var recordSec={};
                        recordSec.key= this.maskPhone(contact.Account.Secondary_Phone_No__c) + ' - ' + contact.Account.Name ;
                        recordSec.value= contact.Account.Secondary_Phone_No__c;
                        this.contactNumberOptions.push({ value: recordSec.key, key: recordSec.value});
                    }

                    this.contactOptions.push({ value: contact.Account.Email__c, key: contact.Account.Email__c});
                  
                    count++;
                }
            }
            if(contact.Id!=null){
                var record={};
                record.key= this.maskPhone(contact.Phone) + ' - ' +contact.Name;
                record.value= contact.Phone;
                this.contactNumberOptions.push({ value: record.key, key: record.value});

                if(contact.OtherPhone!=null){
                    var recordSec={};
                    recordSec.key= this.maskPhone(contact.OtherPhone) + ' - ' + contact.Name ;
                    recordSec.value= contact.OtherPhone;
                    this.contactNumberOptions.push({ value: recordSec.key, key: recordSec.value});
                }

                this.contactOptions.push({ value: contact.Email, key: contact.Email});

            }                  
        });


        console.log('this.contactNumberOptions',this.contactNumberOptions);

        setTimeout((function () {this.template.querySelector(".statusclass").onRefreshClick(); }).bind(this), 500);
        setTimeout((function () {this.template.querySelector(".statusNumberclass").onRefreshClick(); }).bind(this), 500);
    } catch (error) {
        // Handle error
        console.error('Error fetching related contact emails', error);
    }
}
    handleEmailNameChange(event){
        console.log('contact change',event);
    this.choosenSelectEmails = '';
    let changeEvent = event.detail;
    event.detail.forEach((currentItem, index) => {
        if(index == 0){
            this.choosenSelectEmails = currentItem.key;
        }
        else
        {
            this.choosenSelectEmails = this.choosenSelectEmails + ',' + currentItem.key;
        }
    });
    console.log(JSON.stringify(this.choosenSelectEmails));
    }

    handleContactNumberChange(event){
    console.log('contact change',event);
    var selectedContacts = [];
    let changeEvent = event.detail;
    event.detail.forEach((currentItem, index) => {
        selectedContacts.push(currentItem.key);
    });
    this.selectedContactNumbers = selectedContacts;
    console.log('selectedContactnumbers',selectedContacts);

    }

}