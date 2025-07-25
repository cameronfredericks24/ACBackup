import { LightningElement,track, api } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import fetchAssetDetails from '@salesforce/apex/AssetCheckFSlController.fetchAssetDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AssetCheckFSL extends LightningElement {
    @track selectedOption;
    @track barcodeResult;
    @track nonBSLMake;
    @track nonBSLModel;
    @track type;
    showSerial=false;
    showSuccessMessage;
    showErrorMessage;
    @track serialNumber;
    showSuccess;
    showError=false;
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
    islocationavailable=false;
    @track currentLocation;
    @track latitude;
    @track longitude;

    //Determine whether to enable the Scan button when the component is initialised.
    connectedCallback() {
        this.showButton=true;
        this.captureSerialNumber=true;
        this.myScanner = getBarcodeScanner(); 
        //isAvailable() this method Returns true when used on a supported device, and false otherwise.
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }

        if(this.calledFromStartWork){
            this.saId=this.recordId;
        }
    }

    renderedCallback() {
       // alert('record id',this.recordId);
    }

    handleLocation(event){
        //('event',event);
        //alert('event',event.detail);
        //alert('event',event.detail.detail);
        this.currentLocation = event.detail;
       
    }

    handleLocationService(event){
        this.currentLocation = event.detail;
        this.latitude = this.currentLocation.coords.latitude;
        this.longitude = this.currentLocation.coords.longitude;
        this.showButton=true;
        this.captureSerialNumber=true;
    }

    bslClick(){
        this.bsl=true;
        this.nonBsl=false;
        this.showButton=false;
        this.captureSerialNumber=true;
    }

    nonBslClick(){
        this.bsl=false;
        this.nonBsl=true;
        this.showButton=false;
        this.autoSerial=true;
       // this.captureSerialNumber=true;
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
                instructionText: 'Scan a QR , UPC , EAN 13, Code 39, CODE 128, CODE 93, EAN 8, UPC A, UPC_E',
                successText: 'Scanning complete.'
            }; 
            this.myScanner.beginCapture(scanningOptions)
            .then((result) => { 
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

        //check Validation 
        if(this.bsl){
            if(this.serialNumber=='' || this.serialNumber==undefined || this.serialNumber==null){
                valid=false;
            }

            returnMsg = 'Please enter the Serial Number.'
        }

        if(this.nonBsl){
            var fields = ''
            if(!this.autoSerial && ( this.serialNumber=='' || this.serialNumber==undefined || this.serialNumber==null)){
                valid=false;
                fields+='Serial Number, ';
            }
            if(this.nonBSLMake == '' || this.nonBSLMake==undefined || this.nonBSLMake==null){
                valid= false;
                fields+='Non Bsl Make, ';
            }
            if(this.nonBslModel == '' || this.nonBSLModel==undefined || this.nonBSLModel==null){
                valid = false;
                fields+='Non Bsl Model, ';
            }
            if(this.selectedOption == '' || this.selectedOption == undefined || this.selectedOption==null){
                valid=false;
                fields+='Type, ';
            }
            returnMsg = 'Please enter '+fields+'.';
        }

        if(valid){
            this.showButton=false;
            this.showSerial=false;

            debugger;
            var jsWrapper = {};
            jsWrapper.recordId = this.recordId;
            jsWrapper.serialNumber = this.serialNumber;
            jsWrapper.bsl = !this.nonBsl;
            jsWrapper.nonBslMake = this.nonBSLMake;
            jsWrapper.nonBslModel = this.nonBSLModel;
            jsWrapper.nonBslType = this.selectedOption;
            jsWrapper.latitude = this.latitude;
            jsWrapper.longitude = this.longitude;
            if(this.calledFromStartWork){
                jsWrapper.calledFromStartWork = true; 
            }else{
                jsWrapper.calledFromStartWork = false;
            }
            
            this.bsl=false;
            this.nonBsl=false;

            fetchAssetDetails({wrapperRecordString:JSON.stringify(jsWrapper) })
            .then(result =>{
            console.log('result',result);
            if(result=='success'){
                this.showSuccessMessage = 'Asset Succesfully Tagged.';
                this.showSuccess=true;
            }else{
                this.showErrorMessage = result;
                this.showError=true;
            }
            //this.showSuccessMessage = result;           
           
            this.showSpinner=false;
            this.calledFromStartWork=false;
            this.showButton=false;
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

    handleNonBSLMakeChange(event) {
        this.nonBSLMake = event.target.value;
    }

    handleNonBSLModelChange(event) {
        this.nonBSLModel = event.target.value;
    }

    get typeoptions() {
        return [
                 { label: 'ODU', value: 'ODU' },
                 { label: 'IDU', value: 'IDU' },
               ];
    }

    showSerialNumber(){
        this.showSerial=true;
        this.captureSerialNumber=false;
    }

    assignSerialNumber(event){
        this.serialNumber=event.target.value;

    }
    handleBack(){
        this.captureSerialNumber=true;
        this.showSerial=false;
    }

}