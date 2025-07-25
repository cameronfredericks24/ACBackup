import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBOMItems from '@salesforce/apex/BOMController.getBOMItems';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import validateMRcreation from '@salesforce/apex/BOMController.validateMRcreation';
import createProductConsumed from '@salesforce/apex/BOMController.createProductConsumed';
import createProductRequest from '@salesforce/apex/BOMController.createProductRequest';
import isProductRequestExists from '@salesforce/apex/BOMController.isProductRequestExists';
import createPartReplace from '@salesforce/apex/BOMController.createPartReplace';
import checkRmrProduct from '@salesforce/apex/BOMController.checkRmrProduct';
import createProductConsumedwithoutDE from '@salesforce/apex/BOMController.createProductConsumedwithoutDE';
import createProductRequestwithDE from '@salesforce/apex/BOMController.createProductRequestwithDE';
import createProductConsumedandPR from '@salesforce/apex/BOMController.createProductConsumedandPR';
import isProductRequestExistswithCP from '@salesforce/apex/BOMController.isProductRequestExistswithCP';
import checkMaterialGroupProducts from '@salesforce/apex/BOMController.checkMaterialGroupProducts';

export default class BOMComponent extends LightningElement {
    @api recordId; // Assuming you're passing the workOrderLineItemId from a record page
    bomItems = [];
    @track bomDocumentUrl;
    error;
    productRequiredCounter = 0;
    showPopup = false;
    @track currentBomItemDetails;
    @track workOrderid;
    @track workOrderLineItemId;
    @track addProduct = false;
    @track addManually = false;
    @track Quantity = 0;
    @track quantityErrorMessage = '';
    @track isStockAvailable = false;
    @track isCheckStockCalled = false
    @track cpId;
    @track locationId;
    @track productItemId;
    @track AccountId;
    @track message = '';
    @track messageVariant = ''; // 'success' or 'error'
    @track isCheckStockCalled = false;
    @track mrLocationOptions = [
        { label: 'Channel Partner', value: 'Channel Partner' },
        { label: 'Customer', value: 'Customer' }
    ];
    selectedMRLocation;
    @track showCreatePartReplaceButton = false;
    @track showCreatePartReplaceButtonwithcp = false;
    @track isRMRProduct = false;
    @track selectedMaterialGroup = false;
    @track scannedDefectiveBarcode = '';
    @track scannedNewBarcode = '';
    @track mrproductItemId;
    @track mrWorkOrderId;
    @track mrWorkOrderLineId;
    @track mrAccountId;
    @track mrcp;
    @track fileUploadCompleted = false;
    @track uploadedFileId;
    @track scanTypeTest;
    @track WorkOrderLineId;
    @track comments = '';
    @track makeReason = '';
    @track hasBomItems = false;
    @track obligationValue = '';
    @track wtyEndDate = '';
    @track assignedScope = '';
    assetId;
    @track showButton = false;
    @track showSpinner = false;
    @track isFocso = false;
    @track isMaterialGroupMatched = false;
    @track materialGroupMessage = '';
    @track greaterthannamo90Days = false;
    @track cpsdnonnamonic = false
    @track cpsdnonnamonicerrorMessage = '';

    counter = 0;

    makeOptions = [
        { label: 'BLUE STAR', value: 'Bluestar' },
        { label: 'ERP', value: 'ERP' },
        { label: 'Others', value: 'others' }
    ];

    connectedCallback() {
        if (this.recordId) {
            this.loadBOMItems();

            this.myScanner = getBarcodeScanner();
            //isAvailable() this method Returns true when used on a supported device, and false otherwise.
            if (this.myScanner == null || !this.myScanner.isAvailable()) {
                this.scanButtonDisabled = true;
            }
        }
        else {
            console.error('recordId is undefined.');
        }
    }

    get showSection() {
        return this.isCheckStockCalled
    }
    get hideall() {
        return this.showCreatePartReplaceButton || this.showCreatePartReplaceButtonwithcp;
    }

    get showDefectivepartscanner() {
        return this.isStockAvailable || (!this.isStockAvailable) || this.isRMRProduct || this.showCreatePartReplaceButton || this.showCreatePartReplaceButtonwithcp;
    }
    get shownewpartscanner() {
        return this.isStockAvailable || this.showCreatePartReplaceButtonwithcp;
    }

    get hidecomboBox() {
        return this.showCreatePartReplaceButton || this.showCreatePartReplaceButtonwithcp;
    }

    get showSectionforCPlocation() {
        return this.isCheckStockCalled || this.showCreatePartReplaceButtonwithcp;
    }

    get rmrSectionProductConsumed() {
        return this.isStockAvailable & this.isRMRProduct;
    }

    handleMRLocationChange(event) {
        this.selectedMRLocation = event.detail.value;

    }
    handlecheckstock() {
        this.isCheckStockCalled = true;
        // Your check stock logic here
        //this.selectedMaterialGroup = true;
    }


    async checkRmrProduct(productId, bomid, bomPartNumber) {
        debugger;
        console.log('PRODUCTID', productId);
        console.log('bomId', bomid);
        try {
            const result = await checkRmrProduct({
                WOLIid: this.recordId,
                bomid: bomid,
                bomPartNumber: bomPartNumber,
                productId: productId

            });
            console.log('Result from Apex:', result);
            this.isRMRProduct = result.isRMR; // Set boolean variable based on result
        } catch (error) {
            console.error('Error calling checkRmrProduct:', error);
            // Handle errors
        }
    }


    async checkSelectedMaterialGroups(productId, bomid, bomPartNumber) {

        console.log('PRODUCTID IN ', productId);
        console.log('bomId', bomid);
        try {
            const result = await checkMaterialGroupProducts({
                WOLIid: this.recordId,
                bomid: bomid,
                partQuantity: this.partQuantity,
                bomPartNumber: bomPartNumber,
                productId: productId,
                materialgroup: this.materialgroup
            });
            console.log('Result from Apex for Mgroup:', result);
            this.selectedMaterialGroup = result.isImpMaterialGroup; // Set boolean variable based on result
        } catch (error) {
            console.error('Error calling checkMaterialGroupProducts:', error);
            // Handle errors
        }
    }





    HandleQuantityChange(event) {
        if (event.target.value) {
            if (parseInt(event.target.value) <= parseInt(this.currentBomItemDetails.Quantity)) {
                this.Quantity = parseInt(event.target.value);
                this.quantityErrorMessage = ''

            } else {
                this.showMessageToast('Invalid Quantity', 'Quantity shound not exceed ' + this.currentBomItemDetails.Quantity, 'error');
                this.Quantity = 0;
                this.quantityErrorMessage = `Please enter a valid quantity between 0 and ${this.currentBomItemDetails.Quantity}`;
            }
        } else {
            this.Quantity = 0;
            //this.quantityErrorMessage = 'Please enter a valid numeric quantity.';


        }
    }
    async handlecheckstock() {
        if (this.Quantity > 0) {
            try {
                this.isCheckStockCalled = true;
                const result = await validateMRcreation({
                    bomId: this.currentBomItemDetails.BOMID,
                    partNumber: this.currentBomItemDetails.Part,
                    materialgroup: this.currentBomItemDetails.materialgroup,
                    workOrderLineItemId: this.workOrderLineItemId,
                    productId: this.currentBomItemDetails.productId,


                });
                console.log('result:' + result)
                this.isStockAvailable = result.isStockAvailable;
                this.isFocso = result.isFocso;
                this.cpId = result.cpId;
                console.log('location' + JSON.stringify(result.locationId));
                this.locationId = result.locationId;
                this.productItemId = result.productItemId;
                this.greaterthannamo90Days = result.greaterthannamo90Days;
                this.cpsdnonnamonic = result.cpsdnonnamonic;
                if (result.policyObligation != '') {
                    this.obligationValue = result.policyObligation;
                } else {
                    this.obligationValue = '';
                }
                if (result.policyScope != '') {
                    this.assignedScope = result.policyScope;
                } else {
                    this.assignedScope = '';
                }
                if (result.warrantyEndDate != '') {
                    this.wtyEndDate = result.warrantyEndDate;
                }
                console.log('cpsdnonnamonic value before condition:', this.cpsdnonnamonic);
                console.log('isMaterialGroupMatched:', result.isMaterialGroupMatched);
                console.log('WTY END DATE' +result.warrantyEndDate);
                if (!result.isMaterialGroupMatched) {
                    this.showButton = true;  // If you want to disable the button
                    this.errorMessage = 'Part scope is missing. MR cannot be raised.';

                } else if (this.greaterthannamo90Days == true) {

                    console.log('Entered greaterthannamo90Days condition block');
                    this.errorMessage = 'NAMO Customer-Part warranty expired more than 90days-Cant Raise MR';
                    this.showButton = true;
                }
                else if (this.cpsdnonnamonic == true) {
                    console.log('cpsdnonnamonic value after condition:', this.cpsdnonnamonic);
                    //this.errorMessage = 'NON-NAMO customer+ CPSD+ NIC = NO MR';

                    //this.showButton = true;
                }
                else {
                    this.materialGroupMessage = ''; // clear the message if matched
                    this.showButton = false;
                }


                //this.checkMaterialGroupProducts(this.currentBomItemDetails.productId, this.currentBomItemDetails.BOMID, this.currentBomItemDetails.Part);
            } catch (error) {
                console.error('Error fetching cancellation reason options', error);
            }
        } else {
            this.showMessageToast('Invalid Quantity', 'Please enter quantity to check stock', 'error');
            this.quantityErrorMessage = 'Please enter quantity to check stock.';
        }
    }
    async handlecheckstockfromadd() {

        try {
            //this.isCheckStockCalled = true;
            const result = await validateMRcreation({
                bomId: this.currentBomItemDetails.BOMID,
                partNumber: this.currentBomItemDetails.Part,
                materialgroup: this.currentBomItemDetails.materialgroup,
                workOrderLineItemId: this.workOrderLineItemId,
                productId: this.currentBomItemDetails.productId


            });
            console.log('result:' + result)
            //this.isStockAvailable = result.isStockAvailable;
            this.cpId = result.cpId;
            this.locationId = result.locationId;
            this.productItemId = result.productItemId;
        } catch (error) {
            console.error('Error fetching cancellation reason options', error);
        }
    }
    async handleConsumeProduct() {
        this.showButton = true;
        this.showSpinner = true;


        try {

            if (!this.comments || !this.selectedReason || !this.scannedDefectiveBarcode) {
                this.message = 'Please Scan Barcodes and fill Comments, Part Make.';
                this.messageVariant = 'error';
                console.error('Validation Error: Missing required fields');
                this.showButton = false;
                this.showSpinner = false;
                return;
            }

            const result = await createProductConsumed({
                Quantity: this.Quantity,
                productItemid: this.productItemId,
                productid: this.currentBomItemDetails.productId,
                WorkOrderId: this.workOrderid,
                WorkOrderLineId: this.recordId,
                accountId: this.AccountId,
                defectiveSerialNumber: this.scannedDefectiveBarcode,
                newSerialNumber: this.scannedNewBarcode,
                cpId: this.cpId,
                defectivepartmake: this.selectedReason,
                defectivecomments: this.comments,
                assetId: this.assetId,
                obligationValue: this.obligationValue,
                assignedScope: this.assignedScope,
                endDate: this.wtyEndDate

            });
            console.log('result:', result);
            // Check isMaterialGroupMatched and update UI accordingly
            console.log('isMaterialGroupMatched:', result.isMaterialGroupMatched);
            if (!result.isMaterialGroupMatched) {
                this.showButton = true;
                this.materialGroupMessage = 'Part scope is missing. MR cannot be raised. Please contact the CSG team.';
            } else {
                this.materialGroupMessage = '';
                this.showButton = false;
            }
            this.message = 'Product consumed successfully. MR ' + result.mrNumber + ' and RMR has been raised for the product item ' + result.productItemNumber;
            if (this.cpsdnonnamonic == true) {
                    this.message = 'Product consumed successfully.MR and RMR not created: for CPSD +NON NAMO +NIC case';
                }

            // 'Product consumed successfully and Raised MR and RMR';
            this.messageVariant = 'success';
            this.counter += 1;
            if (this.Quantity == this.counter) {
                this.showButton = true;
            } else {
                this.showButton = false;
            }
            console.log('show Button', this.showButton);

            this.showSpinner = false;



        } catch (error) {
            console.error('Error consuming product', error);

            this.message = 'Product not consumed';
            this.messageVariant = 'error';
            this.showButton = false;
            this.showSpinner = false;


        }

    }
    async handleConsumeProductNoRMR() {
        this.showButton = true;
        this.showSpinner = true;

        try {

            const result = await createProductConsumedwithoutDE({
                Quantity: this.Quantity,
                productItemid: this.productItemId,
                productid: this.currentBomItemDetails.productId,
                WorkOrderId: this.workOrderid,
                WorkOrderLineId: this.recordId,
                accountId: this.AccountId,
                defectiveSerialNumber: this.scannedDefectiveBarcode,
                newSerialNumber: this.scannedNewBarcode,
                cpId: this.cpId,
                assetId: this.assetId,
                obligationValue: this.obligationValue,
                assignedScope: this.assignedScope,
                endDate: this.wtyEndDate

            });
            console.log('result:', result);
            // Check isMaterialGroupMatched and update UI accordingly
            console.log('isMaterialGroupMatched:', result.isMaterialGroupMatched);
            if (!result.isMaterialGroupMatched) {
                this.showButton = true;
                this.materialGroupMessage = 'Part scope is missing. MR cannot be raised. Please contact the CSG team.';
            } else {
                this.materialGroupMessage = '';
                this.showButton = false;
            }

            this.message = 'Product Consumed successfully for the product item ' + result.productItemNumber + 'and MR ' + result.mrNumber;
            if (this.cpsdnonnamonic == true) {
                    this.message = 'Product consumed successfully.MR not created: for CPSD +NON NAMO +NIC case';
                    console.log('hehe');
                }
            this.messageVariant = 'success';
            this.counter += 1;
            if (this.Quantity == this.counter) {
                this.showButton = true;
            } else {
                this.showButton = false;
            }
            console.log('show Button', this.showButton);
            this.showSpinner = false;

            //this.showDefectivepartscanner = false;
            //this.showDefectivepartscanner = true;

        } catch (error) {
            console.error('Error consuming product', error);

            this.message = 'Product not consumed';
            this.messageVariant = 'error';
            this.showButton = false;
            this.showSpinner = false;


        }

    }

    async handleRaiseMr() {
        this.showButton = true;
        this.showSpinner = true;

        try {
            console.log('cpId:', this.cpId);
            console.log('WorkOrderLineId:', this.recordId);
            console.log('productItemId:', this.productItemId);


            const result = await createProductRequest({
                Quantity: this.Quantity,
                productid: this.currentBomItemDetails.productId,
                cpId: this.cpId,
                //productid:,
                WorkOrderId: this.workOrderid,
                mrLocation: this.selectedMRLocation,
                WorkOrderLineId: this.recordId,
                Quantity: this.Quantity,
                ProductItemid: this.productItemId,
                assetId: this.assetId,
                isFocso: this.isFocso

            });
            console.log('result:', result);

            this.message = 'MR Created successfully';
            this.messageVariant = 'success';
            this.counter += 1;
            if (this.Quantity == this.counter) {
                this.showButton = true;
            } else {
                this.showButton = false;
            }
            console.log('show Button', this.showButton);
            this.showSpinner = false;

        } catch (error) {
            console.error('Error while creating MR', error);

            this.message = 'Failed to create MR';
            this.messageVariant = 'error';
            this.showButton = false;
            this.showSpinner = false;


        }

    }
    //MR and RMR creation
    async handleRaiseMRandDPI() {
        this.showButton = true;
        this.showSpinner = true;
        if (this.cpsdnonnamonic == true) {
            console.log('cpsdnonnamonic value after condition:', this.cpsdnonnamonic);
            this.errorMessage = 'NON-NAMO customer+ CPSD+ NIC = NO MR';
            this.showButton = true;
            this.showSpinner = false;
            return;
        }

        try {
            console.log('MR And RMR cpId:', this.cpId);
            console.log('MR And RMR WorkOrderLineId:', this.recordId);
            console.log('MR And RMR productItemId:', this.productItemId);
            console.log('obligationValue:', this.obligationValue);
            console.log('Scope:', this.assignedScope);
            if (!this.comments || !this.selectedReason || !this.scannedDefectiveBarcode) {
                this.message = 'Please Scan Barcodes and fill Comments, Part Make.';
                this.messageVariant = 'error';
                console.error('Validation Error: Missing required fields');

                this.showButton = false;
                this.showSpinner = false;
                return;
            }

            const result = await createProductRequestwithDE({
                Quantity: this.Quantity,
                productid: this.currentBomItemDetails.productId,
                cpId: this.cpId,
                //productid:,
                WorkOrderId: this.workOrderid,
                mrLocation: this.selectedMRLocation,
                WorkOrderLineId: this.recordId,
                Quantity: this.Quantity,
                //uploadedFileId: this.uploadedFileId,
                defectiveSerialNumber: this.scannedDefectiveBarcode,
                ProductItemid: this.productItemId,
                defectivepartmake: this.selectedReason,
                defectivecomments: this.comments,
                assetId: this.assetId,
                accountId: this.AccountId,
                obligationValue: this.obligationValue,
                assignedScope: this.assignedScope,
                isFocso: this.isFocso,
                endDate: this.wtyEndDate



            });
            console.log('result:', result);

            this.message = 'MR ' + result.mrNumber + ' has been raised for the product item ' + result.productItemNumber;// 'Product consumed successfully and Raised MR and RMR';
            //this.message = 'MR and RMR Created successfully : ', result;
            this.messageVariant = 'success';
            this.counter += 1;
            if (this.Quantity == this.counter) {
                this.showButton = true;
            } else {
                this.showButton = false;
            }
            this.showSpinner = false;


        } catch (error) {
            console.error('Error while creating MR', error);

            this.message = 'Failed to create MR';
            this.messageVariant = 'error';
            this.showButton = false;
            this.showSpinner = false;
        }
    }


    async checkProductRequestExists() {
        try {
            const exists = await isProductRequestExists({
                productid: this.currentBomItemDetails.productId,
                WorkOrderLineId: this.recordId,

            });

            this.showCreatePartReplaceButton = exists;
        } catch (error) {
            console.error('Error checking product request existence', error);
        }
    }

    /*async checkProductRequestExistsWithCPlocation() {
    try {
    console.log('woli',this.workOrderLineItemId);
    const response = await isProductRequestExistswithCP({
    productid: this.currentBomItemDetails.productId,
    WorkOrderLineId: this.workOrderLineItemId
    });
    this.showCreatePartReplaceButtonwithcp = true;
    console.log('result' +JSON.stringify(response));
    debugger;
    if (response.isSuccess) {
    // Populate other properties if needed
    this.mrproductItemId = response.mrproductItemId;
    this.mrWorkOrderId = response.mrWorkOrderId;
    this.mrAccountId = response.mrAccountId;
    this.mrcp = response.mrcp;
    this.mrLocation = response.mrLocation;
    this.workOrderLineItemId = response.mrWorkOrderLineId;
    this.productId = response.productid;
    if(response.cpdataexist == false){
    this.showCreatePartReplaceButtonwithcp = false;
    }
    } else {
    console.error('Error in response:', response.errorMessage);
    // Handle the error appropriately in your UI
    
    }
    } catch (error) {
    console.error('Error checking product request existence', error);
    }
    }*/


    handleAddManually(event) {
        this.addManually = event.target.checked;
    }
    loadBOMItems() {
        console.log('workOrderLineItemId:', this.recordId); // Debug log to output the value of workOrderLineItemId
        getBOMItems({ workOrderLineItemId: this.recordId })
            .then(result => {
                console.log('Data received from Apex controller:', JSON.stringify(result));
                debugger;
                if (result.isSuccess) {
                    console.log('BOM items:', result.bomDetails);
                    this.productRequiredCounter++;
                    this.bomItems = result.bomDetails;
                    this.workOrderid = result.WorkOrderId;
                    this.workOrderLineItemId = result.WorkOrderLineId;
                    this.bomDocumentUrl = result.bomDocumentUrl;
                    this.AccountId = result.AccountId;
                    this.assetId = result.assetId;
                    this.hasBomItems = true;
                } else {
                    console.error('Error message:', result.errorMessage);
                    this.error = result.errorMessage;
                    this.hasBomItems = false;
                }
            })
            .catch(error => {
                console.error('Error fetching BOM items', error);
                this.error = 'Error fetching BOM items';
            });
    }

    handleScanSerialNumber() {
        // Dynamically load the barcodeScanner component
        const barcodeScannerComponent = createElement('c-barcode-scanner', { is: BarcodeScanner });
        this.template.querySelector('.slds-modal__content').appendChild(barcodeScannerComponent);
    }

    handleAddProduct(event) {
        // Handle your add product logic here
        // Set showPopup to true to display the popup
        const addRowIndex = parseInt(event.target.dataset.customIndex);
        //console.log('inParentbomid', this.bomItems[addRowIndex].BOMID);
        this.currentBomItemDetails = this.bomItems[addRowIndex];
        //this.showPopup = true;
        this.addProduct = true;
        this.checkProductRequestExists();
        //this.checkProductRequestExistsWithCPlocation();
        this.checkRmrProduct(this.currentBomItemDetails.productId, this.currentBomItemDetails.BOMID, this.currentBomItemDetails.Part);
        this.checkSelectedMaterialGroups(this.currentBomItemDetails.productId, this.currentBomItemDetails.BOMID, this.currentBomItemDetails.Part);
        //this.createProductRequest(this.currentBomItemDetails.workOrderLineItemId);
        console.log('Hello hi', JSON.stringify(this.bomItems[addRowIndex]));

        // After handling popup, if you also want to add a new row below the current one,
        // you can do it by pushing an empty object into bomItems array.
        //this.bomItems.splice(addRowIndex + 1, 0, {});
        console.log('After adding new row:', this.bomItems);
        this.showButton = false;
        this.counter = 0;

    }
    async handlePartReplace() {
        try {
            await createPartReplace({
                productItemId: this.currentBomItemDetails.productId,
                workOrderId: this.workOrderid,
                WorkOrderLineId: this.recordId,
                defectiveSerialNumber: this.scannedDefectiveBarcode,
                newSerialNumber: this.scannedNewBarcode
            });
            this.message = 'Part Replace Created successfully';
            this.messageVariant = 'success';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Part Replace created successfully.',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error creating Part Replace: ' + error.body.message,
                    variant: 'error'
                })
            );
        }
    }
    async handlePartReplaceForCPLocation() {
        try {
            await createProductConsumedandPR({
                Quantity: 1,
                productItemid: this.mrproductItemId, // Use the stored value
                WorkOrderId: this.mrWorkOrderId, // Use the stored value
                WorkOrderLineId: this.recordId, // Use the stored value
                accountId: '001Bi00000Dh2TiIAJ',
                cpId: this.mrcp,
                LocationId: this.mrLocation,
                defectiveSerialNumber: this.scannedDefectiveBarcode,
                newSerialNumber: this.scannedNewBarcode,
                productid: this.productId
                //this.mrAccountId, // Use the stored value if needed
                // Use the stored value if needed
            });
            this.message = 'Record Created successfully';
            this.messageVariant = 'success';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Part Replace created successfully.',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.message = 'Record Created successfully';
            this.messageVariant = 'success';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Part Replace created successfully.',
                    variant: 'success'
                })

            );
        }
    }

    handleClosePopup() {
        // This method will be called when the popup is closed
        // this.showPopup = false;

        this.addProduct = false;
        this.Quantity = 0;
        this.currentBomItemDetails.serialNumber = '';
        this.currentBomItemDetails.newSerialNumber = '';
        this.isStockAvailable = false;
        this.isCheckStockCalled = false;
        this.message = '';

    }

    showFileUpload(event) {
        console.log('File uploaded event received', event);
        this.fileUploadCompleted = true;
        this.uploadedFileId = event.detail.fileId;
    }

    handleProductRequiredChange(event) {
        console.log('hi quantity');
        console.log(event.target.dataset.customIndex);
        console.log('after printing' + parseInt(event.target.value));
        console.log('In quantity change ' + JSON.stringify(this.bomItems[event.target.dataset.customIndex]));

        console.log(this.bomItems[event.target.dataset.customIndex].productrequiredquantity);

        // Get the entered value

        const enteredValue = parseInt(event.target.value);
        const index = event.target.dataset.customIndex;

        // Add conditions to validate entered quantity
        if (enteredValue) {
            console.log('inside enteredvalue');
            if (enteredValue >= 0 && enteredValue <= this.bomItems[index].Quantity) {
                console.log('2nd if' + index);
                this.bomItems[index].productrequiredquantity = enteredValue;
                console.log('hello');
                console.log('In quantity change ' + JSON.stringify(this.bomItems));
                this.quantityErrorMessage = '';

            } else {
                this.bomItems[index].productrequiredquantity = this.bomItems[index].Quantity;
                this.quantityErrorMessage = `Please enter a valid quantity between 0 and ${this.currentBomItemDetails.Quantity}`;
                this.showMessageToast('Invalid Quantity', 'Please enter a valid quantity between 0 and ' + this.bomItems[index].Quantity, 'error');
            }
        } else {
            this.bomItems[index].productrequiredquantity = 0;
            this.showMessageToast('Invalid Quantity', 'Please enter a valid numeric quantity', 'error');
            this.quantityErrorMessage = 'Please enter a valid numeric quantity.';
        }
    }
    handleBarcodeClick(event) {
        const scanType = event.target.dataset.scanType;
        if (this.myScanner.isAvailable() || this.myScanner != null) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR, this.myScanner.barcodeTypes.UPC_E, this.myScanner.barcodeTypes.EAN_13, this.myScanner.barcodeTypes.CODE_39, this.myScanner.barcodeTypes.CODE_128, this.myScanner.barcodeTypes.CODE_93, this.myScanner.barcodeTypes.EAN_8, this.myScanner.barcodeTypes.UPC_A, this.myScanner.barcodeTypes.UPC_E],
                instructionText: 'Scan a barcode',
                successText: 'Scanning complete.'
            };

            this.myScanner.beginCapture(scanningOptions)
                .then((result) => {
                    this.scanTypeTest = scanType;
                    console.log('scanType', scanType);
                    if (scanType === 'defective') {
                        this.scannedDefectiveBarcode = result.value;
                        this.currentBomItemDetails.serialNumber = result.value;

                    } else if (scanType === 'new') {
                        console.log('barcode value', result.value);
                        this.scannedNewBarcode = result.value;
                        this.currentBomItemDetails.newSerialNumber = result.value;
                    }
                })
                .catch((error) => {
                    this.showError('error', error);
                })
                .finally(() => {
                    this.myScanner.endCapture();
                });
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'This Device does not support a scanner.',
                error: 'error'
            });
            this.dispatchEvent(event);
        }
    }
    serialNumberChangeHandler(event) {
        this.serialNumber = event.target.value;
    }
    newserialNumberChangeHandler(event) {
        this.newserialNumber = event.target.value;
    }
    get quantityMessageClass() {
        return this.quantityErrorMessage.includes('valid') ? 'success-message' : 'error-message';
    }

    get messageClass() {
        return this.message.includes('successfully') ? 'success-message' : 'error-message';
    }
    showMessageToast(title, message, variant) {
        console.log('hey toast message');
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleIncrement() {
        this.productRequiredCounter++;
    }

    handleDecrement() {
        if (this.productRequiredCounter > 0) {
            this.productRequiredCounter--;
        }
    }

    handleDefectivePartNumber(event) {
        this.scannedDefectiveBarcode = event.detail;
        this.currentBomItemDetails.serialNumber = event.detail;
    }

    handleScannedSerial(event) {

        this.scannedDefectiveBarcode = event.detail;
        this.currentBomItemDetails.serialNumber = event.detail;



    }

    handleNewPartNumber(event) {
        this.scannedNewBarcode = event.detail;
        this.currentBomItemDetails.newSerialNumber = event.detail;
    }

    handleCommentsInput(event) {
        this.comments = event.target.value;
    }
    handleComboBoxChange(event) {
        this.selectedReason = event.detail.value;
    }
}