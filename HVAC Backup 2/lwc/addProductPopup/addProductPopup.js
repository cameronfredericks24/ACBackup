// addProductPopup.js
import { LightningElement, api } from 'lwc';
import processAssetConditions from '@salesforce/apex/BOMController.processAssetConditions';

export default class AddProductPopup extends LightningElement {
    // Define any properties or variables needed for the popup component
    @api bomItemDetails;
     showSerialNumberField = false;
     showSecondPopup = false;
     @api workOrderid;
    
    
    
    connectedCallback() {
        console.log('in Child',JSON.stringify(this.bomItemDetails))
        console.log('Part', +this.bomItemDetails.Part)
      
    }


    // Handle the logic when the close button is clicked
    closeModal() {
        // Dispatch a custom event to notify the parent component to close the popup
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }
     handleScanSerialNumber() {
        // Add logic here for scanning serial number
    }

    toggleSerialNumberField(event) {
        this.showSerialNumberField = event.target.checked;
    }

    showSecondPopupOnClick() {
        this.showSecondPopup = true;
    }

    closeSecondPopup() {
        this.showSecondPopup = false;
    }
    handleClick() {
        processAssetConditions({ bomId: this.bomItemDetails.BOMID, workOrderId: this.workOrderid, partNumber: this.bomItemDetails.Part })
            .then(result => {
                // Handle success
                this.assets = result;
                this.error = undefined;
            })
            .catch(error => {
                // Handle error
                this.error = error;
                this.assets = undefined;
            });
    }
}