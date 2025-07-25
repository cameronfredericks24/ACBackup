import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class BarcodeScannerContainer extends LightningElement {

    scannedValue = '';
    showScanner = false;
    showMainContent = true;
    showReadOnlyInput = true;
    showBarcodeScanner = true;
   
    @api
    inputLabelValue = 'Scan Barcode or QR code';
    newValue= '';

    connectedCallback() {
        if(FORM_FACTOR == 'Small'){
            this.showBarcodeScanner = true;
        } else{
            this.showBarcodeScanner = false;
        }
    }

    getScannedValue(event){
        this.scannedValue = event.detail;
        this.showMainContent = true;
        this.showScanner = false;
        this.showReadOnlyInput = true;

            const selectedSerial = new CustomEvent("selectedserial", {
            detail: this.scannedValue
        });
        this.dispatchEvent(selectedSerial);

        //event to parent
    }

    handleBeginScanClick(){
        this.scannedValue = '';
        this.showScanner = true;
        this.showMainContent = false;
    }

    handleErrorResult(){
        this.showScanner = false;
        this.showMainContent = true;
        this.showReadOnlyInput = false;

        const inputField = this.template.querySelector('lightning-input[data-id="myInput"]');
        inputField.setCustomValidity('Enter the serial number manually');
        inputField.reportValidity();
        inputField.focus();
    }

    handleValueChange(event){
        
        const selectedEvent = new CustomEvent("scanfinish", {
            detail: event.target.value
        });
        this.dispatchEvent(selectedEvent);
    }

}