import { LightningElement,api,track } from 'lwc';
import getWorkOrderById from '@salesforce/apex/SendMRUpdatesDealerPortalController.getWorkOrderById';
import sendSMSCustomer from '@salesforce/apex/SendMRUpdatesDealerPortalController.sendSMSCustomer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class SendMRUpdatesDealerPortal extends LightningElement {

    @api recordId;

    @track phoneNumber;
    @track workOrder;
    @track templateName = 'WO-Creation-Customer-Product';



    connectedCallback() {

        this.getWorkOrder();
    }

    getWorkOrder(){

          getWorkOrderById({ recordId: this.recordId })
            .then(result => {
                this.workOrder = result;
                console.log(' this.workOrder - ' + JSON.stringify(this.workOrder));
                if(this.workOrder.Contact_Phone__c != null){
                    this.phoneNumber = this.workOrder.Contact_Phone__c;

                    this.sendSMS();
                 
                }
                else{
                    this.showToast('Error', 'Customer phone number not found', 'warning');

                }
            })
            .catch(error => {
                console.error('Error fetching work order:', error);
            });
    }


    sendSMS(){

          sendSMSCustomer({ phoneNumber: this.phoneNumber, templateName: this.templateName, recordId: this.recordId })
            .then(result => {

                this.showToast('Error', 'SMS sent sucessfully', 'error');

        
            })
            .catch(error => {
                this.showToast('Error', 'Unable to send SMS', 'error');
                console.error('Error fetching work order:', error);
            });






    }

      // Method to show toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }


    

}