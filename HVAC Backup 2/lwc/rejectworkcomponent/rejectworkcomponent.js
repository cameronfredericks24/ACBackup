import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import getWorkRecord from '@salesforce/apex/StartWorkController.getWorkRecord';
import getRejectReasonOptions from '@salesforce/apex/OtpController.getRejectReasonOptions';
import workorderisRejected from '@salesforce/apex/StartWorkController.isWorkOrderRejected';
import workorderisCompleted from '@salesforce/apex/StartWorkController.isWorkOrderCompleted'; 
import rejectServiceAppointment from '@salesforce/apex/StartWorkController.rejectServiceAppointment';

export default class Rejectworkcomponent extends LightningElement {
    @api recordId;
    @track showRejectReason = true;
    @track showWorkrejectedMessage = false;
    @track showWorkrejectedSuccessfullyMessage = false;
    @track rejectReason;
    @track commissioningTicketReasonOfReject;
    @track RejectReasonOptions;
    @track isOthersSelected = false;
    @track showConfirmationScreen = false;
    @track showWorkCompletedMessage = false;
    
    
    connectedCallback() {
        this.isworkOrderCompleted();
        this.fetchRejectReasonOptions();
        this.workorderisRejected();
        this.rejectReason = '';
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

    async workorderisRejected() {
        try {
            const result = await workorderisRejected({
               recordId:this.recordId
            });
            console.log('result:' +result)
            this.showWorkrejectedMessage = result;
            if(result == true){
                this.showConfirmationScreen = false;
            }
        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }

    async fetchRejectReasonOptions() {
        try {
            const result = await getRejectReasonOptions();
            if (result) {
                this.RejectReasonOptions = result.map(option => ({
                    label: option,
                    value: option
                }));
            }
        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }
    
    handleRejectReasonInput(event) {
        this.rejectReason = event.target.value;
        this.isOthersSelected = this.rejectReason === 'Others';
    }

    handleCommissioningTicketReasonInput(event) {
        this.commissioningTicketReasonOfReject = event.target.value;
        this.isOthersSelected = this.rejectReason === 'Others';
    }
    

    onnext() {
        console.log(this.rejectReason);
    if (!this.rejectReason) {
        this.showToast('','Please select a reject reason.', 'warning');
        console.log('Reject reason not selected.');
        return;
    }
    
    if (this.isOthersSelected && !this.commissioningTicketReasonOfReject) {
        this.showToast('','Please provide a reason for rejection.', 'warning');
        console.log('Commissioning ticket reason not provided for "Others" reject reason.');
        return;
    }

    this.showRejectConfirmation();
}



     showRejectConfirmation() {
        this.showConfirmationScreen = true;
    }

    handleRejectConfirmation() {
        this.rejectServiceAppt();
        //this.updateWorkStatusrejected();
        this.showConfirmationScreen = false;
    }

    handleCancelReject() {
        this.showToast('','Work order not rejected, please continue your work', 'info');
        this.showConfirmationScreen = false;
    }
    onBack(){

        // Emit custom event on success
        const backEvent = new CustomEvent('backevent', {});
      this.dispatchEvent(backEvent);

  }

  rejectServiceAppt(){
    console.log('this.rejectReason ', this.rejectReason);
     console.log('this.commissioningTicketReasonOfReject ', this.commissioningTicketReasonOfReject);

    rejectServiceAppointment({ workOrderId: this.recordId , rejectReason:this.rejectReason ,rejectComment:this.commissioningTicketReasonOfReject})
        .then(() => {
            console.log('Service appointment(s) rejected successfully.');
            this.updateWorkStatusrejected(); // Call to update the work order status after service appointment update
        })
        .catch(error => {
            console.error('Error rejecting service appointment:', error);
            this.showToast('Error', 'An error occurred while rejecting the service appointment.', 'error');
        });

  }


    updateWorkStatusrejected() {
        const fields = {
            Id: this.recordId,
            Status: 'Accepted',
            Rejected_By_Technician__c: true,
            //Reject_Reason__c: this.rejectReason,
            //Reject_Comments__c: this.commissioningTicketReasonOfReject
        };
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showWorkrejectedSuccessfullyMessage = true;
                this.showRejectReason = false;
            })
            .catch(error => {
                console.error(error);
                let errorMessage = 'An error occurred while updating the status.';
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast('Error',errorMessage, 'error');
            });
    }

    showToast(title,message, variant) {
        const toastEvent = new ShowToastEvent({
            title:title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}