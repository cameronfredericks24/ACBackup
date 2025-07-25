// startWorkComponent.js
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import getWorkRecord from '@salesforce/apex/StartWorkController.getWorkRecord';
import workorderisCompleted from '@salesforce/apex/StartWorkController.isWorkOrderCompleted'; 

export default class StartWorkComponent extends LightningElement {
    @api recordId;
    //islocationavailable = false;
    showLocationText = false;
    showWorkStartedMessage = false;
    showWorkStartedSuccessfullyMessage = false;
   showWorkCompletedMessage = false;

    
      connectedCallback() {
        try {
           //this.updateWorkStatus();
           this.isworkOrderCompleted();
        }catch(error){
            console.log('error-->'+error.message);
        }
    }

    async isworkOrderCompleted() {
        try {
            const result = await workorderisCompleted({
               recordId:this.recordId
            });
            console.log('result:' +result)
            this.showWorkCompletedMessage = result;
            if(result == false){
                this.updateWorkStatus();
            }
        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }

    handleNoLocationFound(event){
        this.showLocationText = true;
    }

    handleLocationService(event) {
        // Handle location service response
        // For demonstration purposes, assuming location is available
        this.showLocationText = false;
        this.islocationavailable = true;
        this.updateWorkStatus(); // Update work status when location is available
    }

    updateWorkStatus() {
        // Update work status only if location is available
        /*if (this.islocationavailable) {*/
            getWorkRecord({ recordId: this.recordId })
                .then(result => {
                    const status = result.Status;
                    if (status === 'In Progress') {
                        //this.showToast('Work already started', 'info');
                        this.showWorkStartedMessage = true;
                    } else {
                        // Proceed to update work status
                        const fields = {
                            Id: this.recordId,
                            Status: 'In Progress'
                        };
                        const recordInput = { fields };

                        updateRecord(recordInput)
                            .then(() => {
                                //this.showToast('Work started successfully', 'success');
                                this.showWorkStartedSuccessfullyMessage = true;

                            })
                            .catch(error => {
                                console.error(error);
                                let errorMessage = 'An error occurred while updating the status.';
                                if (error.body && error.body.message) {
                                    errorMessage = error.body.message;
                                }
                                this.showToast(errorMessage, 'error');
                            });
                    }
                })
               /* .catch(error => {
                    console.error(error);
                    this.showToast('An error occurred while fetching record data', 'error');
                }); */
        //}
    }

    showToast(message, variant) {
        // Show toast message
        const toastEvent = new ShowToastEvent({
            title: variant === 'error' ? 'Error' : 'Success',
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}