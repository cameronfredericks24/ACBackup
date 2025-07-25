import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent from Lightning Message Service
import validateOTP from '@salesforce/apex/OtpController.validateOTP';
import getContactEmail from '@salesforce/apex/OtpController.getContactEmail';
import getContactPhone from '@salesforce/apex/OtpController.getContactPhone';

import resetOTP from '@salesforce/apex/OtpController.resetOTP';
import resendOTP from '@salesforce/apex/OtpController.resendOTP';
import updateStatusCompleted from '@salesforce/apex/OtpController.updateStatusCompleted';
import getRelatedContactEmails from '@salesforce/apex/OtpController.getRelatedContactEmails'; // Added Apex method to fetch related contact emails
import logoResource from '@salesforce/resourceUrl/Logo';
import workorderisCompleted from '@salesforce/apex/StartWorkController.isWorkOrderCompleted';

export default class OtpValidationForm extends LightningElement {
    @track otp;
    @track disabledVerify = true;
    @track showForm = true;
    @track showExpired = false;
    @track otpSent = false;
    @track showSuccess = false;
    @track showError = false;
    @track showOTPAlreadyVerified = false;
    @track contactEmail;
    @track verified = true;
    @track otpValues = ['', '', '', ''];
    @track otpValue1 = '';
    @track otpValue2 = '';
    @track otpValue3 = '';
    @track otpValue4 = '';
    @track otpValue = '';
    @api recordId; // This will contain the Id of the current record
    @api latitude;
    @api longitude;
    @track showWorkOrderForm = true;
    @track selectedContactEmail; // Track the selected contact email
    @track contactOptions = []; // Options for the related contact emails
    @track disable = false
    @track choosenSelectEmails = '';
    @track showWorkCompletedMessage = false;
    @track contactNumberOptions = [];
    @track selectedContactNumbers = [];
    @track email;
    @track phone;

    @track isResendDisabled = false;
    @track countdown = 30;
    totalTime = 30; // Total countdown time in seconds
    timer;

    @track showSpinner = false;

    get logoUrl() {
        return logoResource;
    }

    get maskedEmail() {
        return this.maskEmail(this.contactEmail);
    }

    get maskedPhone() {

        return this.maskPhone(this.contactPhone);
    }

    allMaskedEmail() {
        if (this.choosenSelectEmails != '') {
            this.email = this.choosenSelectEmails;
        } else {
            this.email = this.contactEmail;
        }
    }

    allMaskedPhone() {
        var temp = '';
        this.selectedContactNumbers.forEach(contact => {
            temp += this.maskPhone(contact) + ' , ';
        });

        if (temp == '') {
            this.phone = this.maskPhone(this.contactPhone);
        } else {
            this.phone = temp.slice(0, -1);
        }
    }

    maskEmail(email) {
        if (!email) return '';
        const [localPart, domain] = email.split("@");
        const maskedLocalPart = localPart.substring(0, 2) + "******";
        return `${maskedLocalPart}@${domain}`;
    }

    maskPhone(phone) {

        if (!phone) return '';
        return "******" + phone.substring(7, 11);
    }


    async connectedCallback() {
        await this.isworkOrderCompleted();
        await this.fetchContactEmail();
        await this.fetchContactPhone();

        await this.fetchRelatedContactEmails();

    }

    async isworkOrderCompleted() {
        try {
            const result = await workorderisCompleted({
                recordId: this.recordId
            });
            console.log('result:' + result)
            this.showWorkCompletedMessage = result;
            if (this.showWorkCompletedMessage == true) {
                this.showWorkOrderForm = false;
            }

        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }

    async fetchContactEmail() {
        try {
            const result = await getContactEmail({ recordId: this.recordId });
            console.log('result-->' + JSON.stringify(result));
            if (result.isSuccess) {
                debugger;
                this.contactEmail = result.ContactEmail;
                this.email = this.contactEmail;
                this.otpSent = result.isOTPAvailable;
                if (result.OTPVerified) {
                    this.showOTPAlreadyVerified = false;
                    this.showForm = false;
                }
                if (result.workType == 'Breakdown') {
                    // this.showWorkOrderForm=true;
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
            console.log('result-->' + JSON.stringify(result));
            if (result.isSuccess) {
                debugger;
                this.contactPhone = result.ContactPhone;
                this.phone = this.maskPhone(this.contactPhone);
                this.otpSent = result.isOTPAvailable;
                if (result.OTPVerified) {
                    this.showOTPAlreadyVerified = false;
                    this.showForm = false;
                }
                if (result.workType == 'Breakdown') {
                    // this.showWorkOrderForm=true;
                }
                // Handle error
            }
        } catch (error) {
            console.error('Error fetching contact email', error);
            // Handle error
        }
    }
    async fetchRelatedContactEmails() {
        try {
            // Call Apex method to get related contact emails
            const result = await getRelatedContactEmails({ workOrderId: this.recordId });
            // Format the response to match combobox options structure
            /* this.contactOptions = result.map(contact => {
                 return {
                     key: contact.Email,
                     value: contact.Email
                 };
             });*/

            this.contactNumberOptions = [];
            var count = 0;

            result.forEach(contact => {
                console.log('contact', contact);
                console.log('contact', contact.Account.RecordType.DeveloperName);
                if (contact.Account.RecordType.DeveloperName == 'Residential_Customer') {
                    if (count == 0) {
                        console.log('here');
                        var record = {};
                        record.key = this.maskPhone(contact.Account.Phone) + ' - ' + contact.Account.Name;
                        record.value = contact.Account.Phone;
                        this.contactNumberOptions.push({ value: record.key, key: record.value });

                        if (contact.Account.Secondary_Phone_No__c != null) {
                            var recordSec = {};
                            recordSec.key = this.maskPhone(contact.Account.Secondary_Phone_No__c) + ' - ' + contact.Account.Name;
                            recordSec.value = contact.Account.Secondary_Phone_No__c;
                            this.contactNumberOptions.push({ value: recordSec.key, key: recordSec.value });
                        }

                        this.contactOptions.push({ value: contact.Account.Email__c, key: contact.Account.Email__c });

                        count++;
                    }
                }
                if (contact.Id != null) {
                    var record = {};
                    record.key = this.maskPhone(contact.Phone) + ' - ' + contact.Name;
                    record.value = contact.Phone;
                    this.contactNumberOptions.push({ value: record.key, key: record.value });

                    if (contact.OtherPhone != null) {
                        var recordSec = {};
                        recordSec.key = this.maskPhone(contact.OtherPhone) + ' - ' + contact.Name;
                        recordSec.value = contact.OtherPhone;
                        this.contactNumberOptions.push({ value: recordSec.key, key: recordSec.value });
                    }

                    this.contactOptions.push({ value: contact.Email, key: contact.Email });

                }
            });

            console.log('this.contactNumberOptions', this.contactNumberOptions);

            setTimeout((function () { this.template.querySelector(".statusclass").onRefreshClick(); }).bind(this), 500);
            setTimeout((function () { this.template.querySelector(".statusNumberclass").onRefreshClick(); }).bind(this), 500);
        } catch (error) {
            // Handle error
            console.error('Error fetching related contact emails', error);
        }
    }
    handleEmailNameChange(event) {
        console.log('contact change', event);
        this.choosenSelectEmails = '';
        let changeEvent = event.detail;
        event.detail.forEach((currentItem, index) => {
            if (index == 0) {
                this.choosenSelectEmails = currentItem.key;
            }
            else {
                this.choosenSelectEmails = this.choosenSelectEmails + ',' + currentItem.key;
            }
        });
        console.log(JSON.stringify(this.choosenSelectEmails));
    }

    handleContactNumberChange(event) {
        console.log('contact change', event);
        var selectedContacts = [];
        let changeEvent = event.detail;
        event.detail.forEach((currentItem, index) => {
            selectedContacts.push(currentItem.key);
        });
        this.selectedContactNumbers = selectedContacts;
        console.log('selectedContactnumbers', selectedContacts);

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
            if (inputIndex == 0) {
                this.otpValue1 = val;
            }
            else if (inputIndex == 1) {
                this.otpValue2 = val;
            }
            else if (inputIndex == 2) {
                this.otpValue3 = val;
            }
            else {
                this.otpValue4 = val;

            }
            if (this.otpValues[0] != '' && this.otpValues[1] != '' && this.otpValues[2] != '' && this.otpValues[3] != '') {
                this.disabledVerify = false
            }
            else {
                this.disabledVerify = true
            }
            const next = target.nextElementSibling;
            if (next) {
                next.focus();
            }
        }
        else {
            this.otpValues[inputIndex] = '';
            this.otpValues = [...this.otpValues]; // Update the tracked array to trigger reactivity
            if (inputIndex == 0) {
                this.otpValue1 = '';
            }
            else if (inputIndex == 1) {
                this.otpValue2 = '';
            }
            else if (inputIndex == 2) {
                this.otpValue3 = '';
            }
            else {
                this.otpValue4 = '';

            }
            if (this.otpValues[0] != '' && this.otpValues[1] != '' && this.otpValues[2] != '' && this.otpValues[3] != '') {
                this.disabledVerify = false
            }
            else {
                this.disabledVerify = true
            }
        }
    }
    handleKeyUp(event) {
        const target = event.target;
        const key = event.key.toLowerCase();
        console.log('key-->' + key);
        if (key === "backspace" || key === "delete") {
            target.value = "";
            const prev = target.previousElementSibling;
            if (prev) {
                prev.focus();
            }
            return;
        }
        else if (key === 'arrowleft') {
            const prev = target.previousElementSibling;
            if (prev) {
                prev.focus();
            }
            return;
        }
        else if (key === "arrowright") {
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
        console.log('Show Spinner' + this.showSpinner);
        this.showSpinner = true;
        console.log('Show Spinner' + this.showSpinner);

        this.otpValue = this.otpValues[0] + this.otpValues[1] + this.otpValues[2] + this.otpValues[3];
        console.log('this.otpValue-->' + this.otpValue);
        console.log('this.validateInput()-->' + this.validateInput());
        if (this.validateInput()) {
            try {
                // Add latitude and longitude values here
                const latitude = this.latitude;
                const longitude = this.longitude;
                const result = await validateOTP({ otp: this.otpValue, recordId: this.recordId, latitude: latitude, longitude: longitude });
                console.log('result-->' + JSON.stringify(result));
                if (!result.isSuccess) {
                    console.error('No contact email found');
                    if (result.isExpired) {
                        this.showExpired = true;
                        this.showSpinner = false;

                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: 'Otp is Expired ! Please click Resend HappyCode to generate new one',
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);

                        this.showForm = false;
                    } else if (result.isInvalid) {
                        this.showError = true;
                        this.showSpinner = false;

                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: result.errorMessage,
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                    } else {
                        this.showError = true;
                        this.showSpinner = false;

                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: result.errorMessage,
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                    }
                } else {
                    this.contactEmail = result.ContactEmail;
                    this.showSuccess = false;
                    this.showForm = false;
                    const updateResult = await updateStatusCompleted({ recordId: this.recordId, status: 'Completed', otpVerified: this.verified, latitude: latitude, longitude: longitude });
                    // this.iscompleted = true;
                    // this.showWorkOrderForm = false;
                    //const toastEvent = new ShowToastEvent({
                    //title: 'Success!',
                    //message: 'OTP Verified successfully.',
                    //variant: 'success'
                    //});  
                    //this.dispatchEvent(toastEvent);
                    if (updateResult === 'success') {

                        const myEvent = new CustomEvent("otpsuccess", {
                            detail: {
                                otpSuccess: true,
                            },
                        });
                        this.dispatchEvent(myEvent);
                        this.iscompleted = true;
                        this.showWorkOrderForm = false;

                        this.showSpinner = false;
                        const toastEvent = new ShowToastEvent({
                            title: 'Success!',
                            message: 'Ticket completed successfully',
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);

                    }

                    else {
                        this.showError = true;
                        this.showSpinner = false;

                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to complete the Ticket - ' + updateResult,
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(toastEvent);


                    }
                    // setTimeout(() => {
                    //     const myEvent = new CustomEvent("otpsuccess", {
                    //         detail: {
                    //             otpSuccess: true,
                    //         },
                    //     });
                    //     this.dispatchEvent(myEvent);
                    // }, 2000);
                }
            } catch (error) {
                console.error('Error fetching contact email', error);
                this.showSpinner = false;

                // Handle error
            }
        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter 4 Digit OTP.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }

    handleAddAlternateNumber(event) {
        this.alternateNumber = event.target.value;
    }
    handleContactChange(event) {
        this.selectedContactEmail = event.target.value;
    }

       get progressStyle() {
        let progressPercentage = ((this.totalTime - this.countdown) / this.totalTime) * 100;
        return `width: ${progressPercentage}%;`;
    }

  async resendOTP() {
        try {
            this.isResendDisabled = true;
            this.countdown = 30;
            this.startTimer();

            console.log(this.choosenSelectEmails);
            await resendOTP({ 
                recordId: this.recordId, 
                selectedEmails: this.choosenSelectEmails ? this.choosenSelectEmails : '', 
                phoneNumbers: this.selectedContactNumbers.length > 0 ? this.selectedContactNumbers : [] 
            });

            this.allMaskedEmail();
            this.allMaskedPhone();

            const toastEvent = new ShowToastEvent({
                title: 'Success!',
                message: 'Happy Code resent successfully.',
                variant: 'success'
            });
            this.dispatchEvent(toastEvent);
        } catch (error) {
            console.error('Error resending OTP', error);
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to resend Happy Code. Please try again.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            
            // Enable the button immediately in case of failure
            this.isResendDisabled = false;
            clearInterval(this.timer);
        }
    }

    startTimer() {
            let interval = 1000;
            this.timer = setInterval(() => {
                if (this.countdown > 0) {
                    this.countdown--;
                    this.progressValue = (283 * this.countdown) / this.totalTime; // Adjust progress bar
                } else {
                    this.isResendDisabled = false;
                    clearInterval(this.timer);
                }
            }, interval);
        }


   async resetOTP() {
    try {
        const result = await resetOTP({
            recordId: this.recordId,
            selectedEmails: this.choosenSelectEmails,
            phoneNumbers: this.selectedContactNumbers.length > 0 ? this.selectedContactNumbers : []
        });

        if (result === 'Success') {
            // Handle success scenario
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
        } else {
            // Handle failure scenario
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Failed to reset OTP. Please check if any task/approval is pending.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    } catch (error) {
        console.error('Error resetting OTP', error);

        // Handle unexpected error
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'An unexpected error occurred. Please contact support.',
            variant: 'error'
        });
        this.dispatchEvent(toastEvent);
    }
}


    handleNext() {
        debugger;
        this.template.querySelector('[data-id="workOrderForm"]').submit();
    }

    handleSuccess(event) {
        debugger;
        this.showWorkOrderForm = false;
    }

    handleFormError(event) {
        debugger;
        var errorMessage = 'An error occurred while trying to update the record. Please try again.'
        if (event.detail.detail != null && event.detail.detail != '') {
            errorMessage = event.detail.detail;
        }
        this.showToast(errorMessage, 'Error');
    }

    // Handle child component's submit event
    handleChildSubmit() {
        // Toggle the visibility of showWorkOrderForm
        this.showWorkOrderForm = !this.showWorkOrderForm;
    }

    showToast(message, type) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


}