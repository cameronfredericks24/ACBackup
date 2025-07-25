import { LightningElement,track, api } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import fetchAssetDetails from '@salesforce/apex/ProductConsumptionFSlController.fetchAssetDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ProductConsumptionFSL extends LightningElement {
    @track selectedOption;
    @track barcodeResult;
    @track nonBSLMake;
    @track nonBSLModel;
    @track type;
    showSerial=false;
    showSuccessMessage;
    @track serialNumber;
    showSuccess;
    scannedBarcode;
    @api recordId;
    bsl=false;
    nonBsl = false;
    showButton=true;
    serialType;
    autoSerial=false;
    captureSerialNumber=false;
    showSpinner=false;
    @api calledFromStartWork;
    saId;

    //Determine whether to enable the Scan button when the component is initialised.
    connectedCallback() {
        this.showButton=true;
        this.captureSerialNumber=true;
        this.myScanner = getBarcodeScanner(); 
        //isAvailable() this method Returns true when used on a supported device, and false otherwise.
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
            return;
        }
        handleBarcodeClick();
    }

    //Method To Handle Button Click To Scan
    handleBarcodeClick(event){ 
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';
        if(this.myScanner.isAvailable() || this.myScanner != null) {
            
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
                instructionText: 'Scan a QR , UPC , EAN 13, Code 39',
                successText: 'Scanning complete.'
            }; 
            this.myScanner.beginCapture(scanningOptions)
            .then((result) => { 

                // Do something with the barcode scan value you can create and update record or so on
                // Here, we just display the scanned value in the UI

                this.scannedBarcode = result.value;  
                this.serialNumber=this.scannedBarcode;
                this.showSerial=true;
                //this.captureSerialNumber=false;
                this.fetchAsset();        
               
            })
            .catch((error) => { 
                this.showSuccess=false;
                //this.showError('error',error);
            })
            .finally(() => {
                // Clean up by ending capture,
                // whether we completed successfully or had an error
                this.myScanner.endCapture();
            }); 
        }else {

            // Inform the user that they must use a mobile phone with a camera.
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'This Device does not support a scanner.',
                error : 'error'
            });
            this.dispatchEvent(event);
            this.showSuccess=false;
        }
    }


    get options() {
        return [
            { label: 'ODU', value: 'ODU' },
            { label: 'IDU', value: 'IDU' },
        ];
    }
    get serialOptions(){
        return [
            { label: 'Enter Serial Number', value: 'enterSerialNumber' },
            { label: 'Auto Generate Serial Number', value: 'autoGenerate' },
        ];
    }

    handleChange(event) {
        this.selectedOption = event.detail.value;
    }

    handleSerialChange(event) {
        this.serialType = event.detail.value;
        if(this.serialType=='autoGenerate'){
            this.autoSerial=true;
            this.showSerial=false;
        }else{
            this.autoSerial=false;
            this.showSerial=true;
        }
        this.captureSerialNumber=false;
    }

    fetchAsset() {
        console.log('serial number', this.serialNumber);
        //alert('id',this.recordId);

        this.showSpinner=true;
        var valid = true;
        var returnMsg='';

        if(valid){
            this.showButton=false;
            this.showSerial=false;

            debugger;
            var jsWrapper = {};
            jsWrapper.recordId = this.recordId;
            jsWrapper.serialNumber = this.serialNumber;
            
            fetchAssetDetails({wrapperRecordString:JSON.stringify(jsWrapper) })
            .then(result =>{
            console.log('result',result);
            if(result=='success'){
                this.showSuccessMessage = 'Product has been successfully registered.';
            }else{
                this.showSuccessMessage = 'There is something wrong in registering the product.';
            }
            
            this.showSuccess=true;
            this.showSpinner=false;
            this.calledFromStartWork=false;
            })
            .catch(error =>{
            var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
            console.log('Error', error.body.message);
            this.showSuccessMessage = errormsg;
            this.showSuccess=true;
            this.bsl=false;
            this.nonBsl=false;
            this.showSpinner=false;
            this.calledFromStartWork=false;
            });

        }else{

            this.showSpinner=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Required Fields',
                    message:returnMsg,
                    variant: 'error'
                })
            );

        }

        
    }


}