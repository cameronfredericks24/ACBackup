import { LightningElement , track, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSMSTemplates from '@salesforce/apex/SMSNotificationController.getSMSTemplates';
import sendSMS from '@salesforce/apex/SMSNotificationController.sendSMS';
import getMessage from '@salesforce/apex/SMSNotificationController.getMessage';
import getPhoneNumbers from '@salesforce/apex/SMSNotificationController.getPhoneNumbers';

export default class SMSNotification extends LightningElement {
selectedValue = ''; // Default selected value
textValue = ''; // Default value
options = [];
phoneOption = [];
// inputData = [];
@api recordId;
phoneNumber;
templateName;
show= false;
showComponent = true;
// tempData=[];
previousPhoneNumber = '';
contactAvailable = false;

    @wire(getSMSTemplates, { recordId: '$recordId' })
    wiredOptions({ error, data }) {
        if (data) {
        // this.tempData = data;
        this.options = data.map(option => ({ label: option.Name, value: option.Name }));
        } else if (error) {
            console.error('Error fetching options:', error);
        }
    }
    @wire(getPhoneNumbers, { recordId: '$recordId' })
    wiredPhoneOptions({ error, data }) {
       if (data) {
          for (let key in data) {
                this.phoneOption.push({ label: data[key] + ' ' + key, value: key });
            }
              if (this.phoneOption.length > 0) {
                  this.contactAvailable=true;
             }
            else{
                this.contactAvailable=false;
            }
        } else if (error) {
                console.error('Error fetching options:', error);
        }
    }
    handleSelectTemplate(event) {
    try {
        // this.inputData = [];
        this.selectedValue = event.detail.value;
        this.show = true;
        this.textValue = '';
        // const selectedOption = this.tempData.find(option => option.Name === this.selectedValue);
        // if (selectedOption) {
        // var selectedOptionValue = selectedOption.Template_Data__c;
        // // console.log('Data received:', selectedOptionValue);
        // }
        } 
    catch (error) 
        {
            console.error('An error occurred:', error.message);
        }
        // const vars = selectedOptionValue.split('#var#');
        // // Generate inputData for each occurrence of #var#
        // for (let i = 0; i < vars.length - 1; i++) {
        //     this.inputData.push({
        //         key: i,
        //         label: `var ${i + 1}`,
        //         value: '', // You can set a default value if needed
        //     });
        // }
        getMessage({templateName : this.selectedValue, recordId: this.recordId})
            .then(result => {
                this.textValue = result;
            })
            .catch(error => {
                 console.error('Error sending SMS:', error);
            });
    }
    handleSend(event) {
        if (!this.phoneNumber) {
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'Please select a phone number',
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
        return;
        }

        if (!this.selectedValue) {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select an SMS template',
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        sendSMS({phoneNumber: this.phoneNumber , recordId: this.recordId , templateName : this.selectedValue})
        .then(result => {
            console.log('SMS sent successfully:', result);
           if(result != null && result === 'success'){
           const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'SMS Sent Successfully.',
                    variant: 'success',
            });
            this.dispatchEvent(toastEvent);
            // Dispatch an event to notify the Aura component to close itself and its containing modal
                const closeEvent = new CustomEvent('closemodal');
                this.dispatchEvent(closeEvent);
             this.showComponent = false;
        }
        })        
        .catch(error => {
             let errorMessage = 'Unknown error'; // Default error message
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                } else if (error.message) {
                    errorMessage = error.message;
                }
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error',                    
                });
                this.dispatchEvent(toastEvent);
                const closeEvent = new CustomEvent('closemodal');
                this.dispatchEvent(closeEvent);
                this.showComponent = false;
              console.error('Error sending SMS:', error);
        });
    }
    // handleSelectPhoneNumber(event) {// For single SMS
    // try {
    //     const checkboxValue = event.target.value;
    //     const isChecked = event.target.checked;
    //     if (isChecked) {
    //        this.template.querySelectorAll('lightning-input').forEach(checkbox => {
    //             if (checkbox.value !== checkboxValue) {
    //                 checkbox.checked = false;
    //                 if (this.phoneNumber === checkbox.value) {
    //                     this.phoneNumber = '';
    //                 }
    //             }
    //         });
    //          this.phoneNumber = checkboxValue;
    //         this.previousPhoneNumber = checkboxValue;
    //     } else {
    //         if (this.previousPhoneNumber === checkboxValue) {
    //             this.phoneNumber = '';
    //         }
    //         this.previousPhoneNumber = '';
    //     }
    //     } catch (error) {
    //         console.error('An error occurred:', error.message);
    //     }
    // }
   handleSelectPhoneNumber(event) {//Bulk Phone
    try {
        const checkedValue = event.target.value;
        const isChecked = event.target.checked;

        if (isChecked) {
             if (this.phoneNumber && this.phoneNumber !== '') {
                this.phoneNumber += ', ' + checkedValue;
            } else {
                this.phoneNumber = checkedValue;
            }
        } else {
            if (this.phoneNumber && this.phoneNumber !== '') {
                const phoneNumbersArray = this.phoneNumber.split(', ');
                const index = phoneNumbersArray.indexOf(checkedValue);
                if (index !== -1) {
                    phoneNumbersArray.splice(index, 1);
                }
                 this.phoneNumber = phoneNumbersArray.join(', ');
            }
        }

        console.log('Checked value:', this.phoneNumber);
    } catch (error) {
        console.error('An error occurred:', error.message);
    }
}

    renderedCallback() {
    try {
        const styleElement = document.createElement('style');
        styleElement.innerText = `
        .textarea-container .slds-textarea{
        min-height: 100px !important;
        }
        .button-container {
        text-align: center;
        }
        .checkbox .slds-checkbox {
        margin-top: 14px;
           flex-wrap: wrap;
         display: flex;
        }
        }
        `;
        const head = document.head || document.getElementsByTagName('head')[0];
        head.appendChild(styleElement);
        }
        catch (error) {
        console.error('An error occurred:', error.message);
    }
    }  
}