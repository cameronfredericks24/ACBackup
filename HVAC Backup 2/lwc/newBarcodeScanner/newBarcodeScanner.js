// barcodeScannerExample.js
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';

export default class NewBarcodeScanner extends LightningElement {
    myScanner;
    scanButtonDisabled = false;
    scannedBarcode = '';

    // When component is initialized, detect whether to enable Scan button
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
        this.handleBeginScanClick();
    }

    handleBeginScanClick(event) {
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';

        // Make sure BarcodeScanner is available before trying to use it
        // Note: We _also_ disable the Scan button if there's no BarcodeScanner
        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR, 
                                this.myScanner.barcodeTypes.UPC_E,
                                this.myScanner.barcodeTypes.EAN_13,
                                this.myScanner.barcodeTypes.CODE_39,
                                this.myScanner.barcodeTypes.CODE_128,
                                this.myScanner.barcodeTypes.CODE_93,
                                this.myScanner.barcodeTypes.EAN_8,
                                this.myScanner.barcodeTypes.UPC_A,
                                this.myScanner.barcodeTypes.UPC_E,

                              ],
                instructionText: 'Scan a Barcode or QR Code',
                successText: 'Scanning complete.',
                manualConfirmation: true,
                previewBarcodeData: true
            };
            this.myScanner
                .beginCapture(scanningOptions)
                .then((result) => {
                    console.log(result);

                    // Do something with the barcode scan value:
                    // - look up a record
                    // - create or update a record
                    // - parse data and put values into a form
                    // - and so on; this is YOUR code
                    // Here, we just display the scanned value in the UI
                    this.scannedBarcode = result.value;
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Successful Scan',
                            message: 'Barcode scanned successfully.',
                            variant: 'success'
                        })
                    );*/
                    const selectedEvent = new CustomEvent("handlesuccess", {
                        detail: this.scannedBarcode
                    });
                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                })
                .catch((error) => {
                    // Handle cancellation and unexpected errors here
                    console.error(error);

                    if (error.code == 'userDismissedScanner') {
                        /* User clicked Cancel
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Scanning Cancelled',
                                message:
                                    'You cancelled the scanning session.',
                                mode: 'sticky'
                            })
                        );*/
                        const selectedEvent = new CustomEvent('handleerror',{});
                        this.dispatchEvent(selectedEvent);
                    }
                    else { 
                        // Inform the user we ran into something unexpected
                        const selectedEvent = new CustomEvent('handleerror',{});
                        this.dispatchEvent(selectedEvent);
                    }
                })
                .finally(() => {
                    console.log('#finally');

                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                });
        } else {
            // BarcodeScanner is not available
            // Not running on hardware with a camera, or some other context issue
            console.log(
                'Scan Barcode button should be disabled and unclickable.'
            );
            console.log('Somehow it got clicked: ');
            console.log(event);

            // Let user know they need to use a mobile phone with a camera
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Barcode Scanner Is Not Available',
                    message:
                        'Try again from the Salesforce app on a mobile device.',
                    variant: 'error'
                })
            );
        }
    }
}