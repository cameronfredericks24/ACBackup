/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, track, api } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import fetchAssetDetails from '@salesforce/apex/ProductRegistrationFSlController.fetchAssetDetails';
import otpNeeded from '@salesforce/apex/ProductRegistrationFSlController.otpNeeded';
import getownerPhone from '@salesforce/apex/ProductRegistrationFSlController.getownerPhone';
import validateOtp from '@salesforce/apex/ProductRegistrationFSlController.validateOtp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import fetchProductCodes from '@salesforce/apex/AssetRegistrationController.fetchProductCodes';



export default class ProductRegistrationFSL extends LightningElement {
    @track selectedOption;
    @track barcodeResult;
    @track nonBSLMake;
    @track nonBSLModel;
    @track type;
    showSerial = false;
    showSuccessMessage;
    showErrorMessage;
    @track serialNumber;
    showSuccess;
    showError = false;
    scannedBarcode;
    @api recordId;
    @api isInstallation;
    bsl = false;
    nonBsl = false;
    showButton = true;
    serialType;
    autoSerial = false;
    captureSerialNumber = false;
    showSpinner = false;
    scanAsset = false;
    @api calledFromStartWork;
    saId;
    islocationavailable = false;
    @track currentLocation;
    @track latitude;
    @track longitude;

    @track registerProductScreen = false;
    @track modelNumber;
    showOTP = false;
    otp;
    scanAssetScreen = false;
    otpNotValid = false;
    maskedNumber;

     @track showAvailableCodesUnitary = false;
         @track filteredOptionsProductCode = [];



    //Determine whether to enable the Scan button when the component is initialised.
    connectedCallback() {
        this.showButton = true;
        this.captureSerialNumber = true;
        this.myScanner = getBarcodeScanner();
        //isAvailable() this method Returns true when used on a supported device, and false otherwise.
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }

        if (this.calledFromStartWork) {
            this.saId = this.recordId;
        }
        this.otpNeededJs();
    }

    renderedCallback() {
        // alert('record id',this.recordId);
    }

    handleLocation(event) {
        //('event',event);
        //alert('event',event.detail);
        //alert('event',event.detail.detail);
        this.currentLocation = event.detail;

    }

    handleLocationService(event) {
        this.currentLocation = event.detail;
        this.latitude = this.currentLocation.coords.latitude;
        this.longitude = this.currentLocation.coords.longitude;
        this.showButton = true;
        this.captureSerialNumber = true;
    }

    bslClick() {
        this.bsl = true;
        this.nonBsl = false;
        this.showButton = false;
        this.captureSerialNumber = true;
    }

    nonBslClick() {
        this.bsl = false;
        this.nonBsl = true;
        this.showButton = false;
        this.autoSerial = true;
        // this.captureSerialNumber=true;
    }

    //Method To Handle Button Click To Scan
    handleBarcodeClick(event) {
        if(this.modelNumber === null || this.modelNumber === undefined || this.modelNumber === ''){
            const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter the model number to proceed',
                            error: 'error'
                        });

                        this.dispatchEvent(event);

                        return;

                    }
        this.scanAsset = true;
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';
        if (this.myScanner.isAvailable() || this.myScanner != null) {

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
                    this.serialNumber = this.scannedBarcode;
                    this.showSerial = true;
                    //this.captureSerialNumber=false;
                    this.fetchAsset();

                })
                .catch((error) => {
                    this.showSuccess = false;
                    //this.showError('error',error);
                })
                .finally(() => {
                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                });
        } else {

            // Inform the user that they must use a mobile phone with a camera.
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'This Device does not support a scanner.',
                error: 'error'
            });
            this.dispatchEvent(event);
            this.showSuccess = false;
        }
    }


    get options() {
        return [
            { label: 'ODU', value: 'ODU' },
            { label: 'IDU', value: 'IDU' },
        ];
    }
    get serialOptions() {
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
        if (this.serialType == 'autoGenerate') {
            this.autoSerial = true;
            this.showSerial = false;
        } else {
            this.autoSerial = false;
            this.showSerial = true;
        }
        this.captureSerialNumber = false;
    }

    loadProductCodes(searchTermProductCode) {
        fetchProductCodes({ searchTerm: searchTermProductCode })
            .then(result => {
                console.log('product codes -- ' + JSON.stringify(result));
                const productSet = new Set(result); // Using Set to store unique product codes
                this.filteredOptionsProductCode = Array.from(productSet).map(productCode => {
                    return { label: productCode, value: productCode };
                });

                //this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;
                console.log('filteredOptionsProductCode -- ' + JSON.stringify(this.filteredOptionsProductCode));

            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }


    handleOnClickCustomLookupProductCodeUnitary(event) {

        try {

            console.log('filteredOptionsProductCode on click - ', this.filteredOptionsProductCode.length);
            this.showAvailableCodesUnitary = this.filteredOptionsProductCode.length > 0;
            console.log('showAvailableCodesUnitary on click - ', this.showAvailableCodesUnitary);

        }
        catch (error) {
            console.log('error - ', error);
        }
    }

    handleOnChangeCustomLookupProductCodeUnitary(event) {

        const searchTermProductCodeUnitary = event.target.value.toLowerCase();

        this.modelNumber = event.target.value;

        console.log('searchTermProductCodeUnitary  - ', searchTermProductCodeUnitary);

        this.loadProductCodes(searchTermProductCodeUnitary);

    }

    handleOnFocusCustomLookupProductCodeUnitary() {
        this.showAvailableCodesUnitary = true;
    }

    handleOnBlurCustomLookupProductCodeUnitary() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showAvailableCodesUnitary = false;
        }, 300);
    }

    handleOptionClickProductCodeUnitary(event) {

        this.modelNumber = event.currentTarget.dataset.value;

        console.log(' modelNumber 964 - ' + this.modelNumber);

    }

    handleModelNumberChangeCustomLookupUnitary(event) {
        console.log("option clicked: ");

        this.modelNumber = event.currentTarget.dataset.value;

        this.showAvailableCodesUnitary = false;

    }

    fetchAsset() {
        console.log('serial number', this.serialNumber);
        this.showSpinner = true;
        var valid = true;
        var returnMsg = '';

        //check Validation 
        if (this.bsl && this.scanAsset != true) {
            if (this.serialNumber == '' || this.serialNumber == undefined || this.serialNumber == null) {
                valid = false;
            }

            returnMsg = 'Please enter the Serial Number.'
        }

        if (this.nonBsl && this.scanAsset != true) {
            var fields = ''
            if (!this.autoSerial && (this.serialNumber == '' || this.serialNumber == undefined || this.serialNumber == null)) {
                valid = false;
                fields += 'Serial Number, ';
            }
            if (this.nonBSLMake == '' || this.nonBSLMake == undefined || this.nonBSLMake == null) {
                valid = false;
                fields += 'Non Bsl Make, ';
            }
            if (this.nonBslModel == '' || this.nonBSLModel == undefined || this.nonBSLModel == null) {
                valid = false;
                fields += 'Non Bsl Model, ';
            }
            if (this.selectedOption == '' || this.selectedOption == undefined || this.selectedOption == null) {
                valid = false;
                fields += 'Type, ';
            }
            returnMsg = 'Please enter ' + fields + '.';
        }

        if (valid) {
            this.showButton = false;
            this.showSerial = false;

            debugger;
            var jsWrapper = {};
            jsWrapper.recordId = this.recordId;
            //jsWrapper.recordId ='0WOBi000001xTILOA2';

            jsWrapper.serialNumber = (this.serialNumber.trim()).replace(/[\r\n]+/gm, "");
            jsWrapper.modelNumber = this.modelNumber;
            jsWrapper.bsl = !this.nonBsl;
            jsWrapper.nonBslMake = this.nonBSLMake;
            jsWrapper.nonBslModel = this.nonBSLModel;
            jsWrapper.nonBslType = this.selectedOption;
            jsWrapper.latitude = this.latitude;
            jsWrapper.longitude = this.longitude;
            jsWrapper.otp = this.otp;
            if (this.calledFromStartWork) {
                jsWrapper.calledFromStartWork = true;
            } else {
                jsWrapper.calledFromStartWork = false;
            }

            this.bsl = false;
            this.nonBsl = false;

            fetchAssetDetails({ wrapperRecordString: JSON.stringify(jsWrapper) })
                .then(result => {
                    console.log('result', result);

                    if (result == 'success') {
                        LightningAlert.open({
                            message: 'Service Line Item added successfully',
                            theme: 'success', // a red theme intended for error states
                            label: 'success!', // this is the header text
                        });

                        this.showSuccessMessage = 'Service Ticket Line Item has been created successfully. Please close the window and refresh data to see the service ticket line item.';
                        this.showSuccess = true;

                        // Emit custom event on success
                        const productRegisterSuccessEvent = new CustomEvent('scanassetsuccess', {});
                        this.dispatchEvent(productRegisterSuccessEvent);

                    }
                    else if (result === 'No asset found') {

                        this.registerProductScreen = true;


                    } else if (result.includes('OTP Sent')) {
                        this.showOTP = true;
                        this.scanAsset = false;
                         if (result.includes('-')) {
                            let phoneNumber = result.split(' -')[1]; 
                            if(phoneNumber!=undefined && phoneNumber!=null && phoneNumber.length>5){
                                let masked = '*'.repeat(phoneNumber.length - 4) + phoneNumber.slice(-4);
                                this.maskedNumber = masked;
                            }
                         }
                    }
                    else if(result === 'DmlException'){

                            this.showSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Unable to save the asset in the ticket, contact admin',
                                    message: returnMsg,
                                    variant: 'error'
                                })
                            );


                    }
                    else {
                        this.showErrorMessage = result;
                        this.showError = true;
                    }
                    //this.showSuccessMessage = result;           

                    this.showSpinner = false;
                    this.calledFromStartWork = false;
                    this.showButton = false;
                })
                .catch(error => {
                    var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                    console.log('Error', error.body.message);
                    this.showSuccessMessage = errormsg;
                    this.showSuccess = true;
                    this.bsl = false;
                    this.nonBsl = false;
                    this.showSpinner = false;
                    this.calledFromStartWork = false;
                    this.showButton = false;
                });

        } else {

            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Required Fields',
                    message: returnMsg,
                    variant: 'error'
                })
            );

        }

    }

    scanAgainHandler() {

        console.log('scan again called0---');

        this.scanAssetScreen = true;
        this.captureSerialNumber = true;
        this.showButton = true;
        this.showOTP = false;
        this.serialNumber = '';

        console.log('captureSerialNumber---' + this.captureSerialNumber);
        console.log('showButton---' + this.showButton);
        console.log('showOTP---' + this.showOTP);


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

    showSerialNumber() {

         if(this.modelNumber === null || this.modelNumber === undefined || this.modelNumber === ''){
            const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter the model number to proceed',
                            error: 'error'
                        });

                        this.dispatchEvent(event);

                        return;

                    }

        this.showSerial = true;
        this.captureSerialNumber = false;
    }

    assignSerialNumber(event) {
        this.serialNumber = event.target.value;

    }
    handleBack() {
        this.registerProductScreen = false;
        this.showButton = true;
        this.captureSerialNumber = true;
        this.showSerial = true;
        console.log('this.captureSerialNumber - ' + this.captureSerialNumber);
        console.log('this.showSerial - ' + this.showSerial);

    }


    handleModelNumberChange(event) {
        this.modelNumber = event.target.value;
        console.log('this.modelNumber - ' + this.modelNumber);
        console.log('this.serialNumber - ' + this.serialNumber);

    }


    handleBackClick(event) {
        // Emit custom event on back click
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);
    }

    handleAssetExist(event) {
        console.log('asset exist called---');

        this.serialNumber = event.detail.serialNumber;

        console.log('this.serialNumber - ' + this.serialNumber);


        this.registerProductScreen = false;
        this.otpNeededJs();

        this.showOTP = true;
        this.scanAsset = false;

    }

    handleAssetExistSameAccount(event) {

        this.serialNumber = event.detail.serialNumber;

        this.registerProductScreen = false;


        console.log('this.serialNumber - ' + this.serialNumber);

        this.fetchAsset();

    }

    handleScanSerialNumber(event) {

        this.scannedBarcode = event.detail;
        this.serialNumber = this.scannedBarcode;
        this.showSerial = true;
        //this.captureSerialNumber=false;
        this.fetchAsset();
    }

    otpNeededJs() {
        otpNeeded({ recordId: this.recordId })
            .then(result => {
                console.log('result', result);
                this.showOTP = result;
                if (this.showOTP == false) {
                    this.scanAssetScreen = true;
                    this.calledFromStartWork = false;
                    this.showButton = true;
                }else{
                    this.getownerNumber();
                }

            })
            .catch(error => {
                var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                console.log('Error', error.body.message)
            });
    }

    getownerNumber() {
        getownerPhone({ recordId: this.recordId })
            .then(result => {
                console.log('result', result);
                if(result!=undefined && result!=null && result.length>5){
                    let masked = '*'.repeat(result.length - 4) + result.slice(-4);
                    this.maskedNumber = masked;
                }
               
                //this.maskedNumber = result;
            })
            .catch(error => {
                var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                console.log('Error', error.body.message)
            });
    }

    assignOTP(event) {
        this.otp = event.target.value;
    }

    validateOtpJS() {

        this.showSpinner = true;
        validateOtp({ recordId: this.recordId, otp: this.otp, serialNumber: this.serialNumber,modelNumber:this.modelNumber })
            .then(result => {
                console.log('validate', result);
                if (result == true) {
                    this.showOTP = false;
                    this.scanAssetScreen = true;
                    this.otpNotValid = false;
                    //this.calledFromStartWork = false;
                    this.showButton = true;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: 'Service Ticket Line Item has been created successfully. Please close the window and refresh data to see the service ticket line item.',
                            variant: 'success'
                        })
                    );

                    this.showSpinner = false;


                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: 'Invalid OTP',
                            variant: 'warning'
                        })
                    );
                    console.log('OTP not valid');
                    this.otpNotValid = true;

                    this.showSpinner = false;

                }
            })
            .catch(error => {
                var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                console.log('Error', error.body.message);
                this.showSpinner = false;

            });
    }

    handleRegistrationSuccess(){
             // Emit custom event on back click
             const backClick = new CustomEvent('backclick', {});
             this.dispatchEvent(backClick);

              // Emit custom event on back click
              const assetSelected = new CustomEvent('assetselected', {});
              this.dispatchEvent(assetSelected);
    }
}