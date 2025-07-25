import { LightningElement, track, api } from 'lwc';
import getSpareProducts from '@salesforce/apex/NonBomController.getSpareProducts';
import getAssetId from '@salesforce/apex/NonBomController.getAssetId';
import getLocationByCPId from '@salesforce/apex/NonBomController.getLocationByCPId';
import getProductItemsForSelected from '@salesforce/apex/NonBomController.getProductItemsForSelected';
import createProductConsumedRecord from '@salesforce/apex/NonBomController.createProductConsumedRecord';
import createProductRequest from '@salesforce/apex/NonBomController.createProductRequest';
import isAssetBomNull from '@salesforce/apex/NonBomController.isAssetBomNull';
import fetchMaterialGroupScopeAndObligation from '@salesforce/apex/NonBomController.fetchMaterialGroupScopeAndObligation';
import canRaiseMaterialRequest from '@salesforce/apex/NonBomController.canRaiseMaterialRequest';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Family_Names from '@salesforce/label/c.Family_Names';


export default class NonBomComponent extends LightningElement {
    @api recordId; // Work Order Line Item ID
    @api workOrderId; // Work Order ID
    @api accountId; // Account ID (Channel Partner)
    @track assetId = '';
    @track cpId = ''; // Channel Partner ID
    @track location = '';
    @track searchTerm = '';
    @track allProducts = [];
    @track filteredProducts = [];
    @track selectedProducts = [];
    @track productItemId = null; // Store the Product Item ID
    @track quantityOnHand = null;
    @track serialNumbers = []; // Array to hold serial numbers
    @track quantityToConsume = 0; // Quantity to consume input
    @track successMessage = ''; // Variable to hold success message
    @track showSuccessMessage = false; // Variable to control visibility of success message
    @track isButtonDisabled = false;
    @track showReturnableMessage = false;
    @track showStockAvailableMessage = false;
    checkSpareDisabled = false;
    @track errorMessage = '';
    @api productId;
    @track productIdSelected
    @track branch;
    @track mrLocation;
    @track quantity;
    @track isMaterialGroupMatched; // Material Group Matching
    @track obligationValue; // Obligation Value
    @track scope;
    @track materialgroup;
    @track showMRSection = false;
    @track disableRaiseMRButton = false;
    @track materialGroupData = [];
    @track bomProducts = true;
    @track showStockNotAvailableMessage = '';
    @track isMaterialRequestAllowed = false;
    @track assetNotRegistered = false;
    @track nonNamoBom = false;
    @track proceedWithSO = false;
    @track upsdlock = false;
    @track greaterthannamo90Days = false;
    @track cpsdnonnamonic = false;
    @track showSpinner = false;
    @track wtyEndDate = '';



    connectedCallback() {
        this.loadProducts();



    }



    loadProducts() {
        console.log('load');

        // Initialize the boolean flag
        this.isMaterialRequestAllowed = false;

        // Call Apex method to check if material request can be raised
        canRaiseMaterialRequest({ workOrderLineItemId: this.recordId })
            .then(result => {
                console.log('Material request condition result:', result);

                if (result === 'Asset not registered') {
                    console.log('Condition matched: Asset not registered');

                    this.isMaterialRequestAllowed = false;
                    this.assetNotRegistered = true;
                    this.nonNamoBom = false;


                }
                else if (result === 'MR cannot be raised') {
                    console.log('Condition matched: MR cannot be raised');

                    this.isMaterialRequestAllowed = false;
                    this.assetNotRegistered = false;
                    this.nonNamoBom = true;


                }
                else if (result === 'Proceed with SO') {
                     console.log('Condition matched: Proceed with SO');
                    this.isMaterialRequestAllowed = false;
                    this.assetNotRegistered = false;
                    this.nonNamoBom = false;
                    this.proceedWithSO = true; // Set SO flag

                }

                else if (result === 'NON BOM is Locked for CPAG/CBRG, Please proceed with BOM') {
                    console.log('Condition matched: NON BOM is Locked for CPAG/CBRG');
                    this.isMaterialRequestAllowed = false;
                    this.assetNotRegistered = false;
                    this.nonNamoBom = false;
                    this.proceedWithSO = false; // Set SO flag
                    this.upsdlock = true;

                } else {
                    console.log('Condition matched: Default (material request allowed)');

                    this.isMaterialRequestAllowed = true;

                    // If the condition is satisfied, proceed with further logic
                    this.loadAssetId();
                    this.myScanner = getBarcodeScanner();

                    if (this.productIdSelected) {
                        this.isBomNullOrNot(this.productIdSelected)
                            .then(isBomNull => {
                                console.log('Is BOM Null?', isBomNull);
                                // Perform additional logic based on BOM status
                            });
                    }

                }


                // Update the boolean flag based on the result
                //this.isMaterialRequestAllowed = result;

                // if (result === false) { 
                //     console.log('Material request cannot be raised for this condition.');
                //     this.bomProducts = false; // Set additional flags or UI states as necessary
                // } else {
                //     // If the condition is satisfied, proceed with further logic
                //     this.loadAssetId();
                //     this.myScanner = getBarcodeScanner();

                //     if (this.productIdSelected) {
                //         this.isBomNullOrNot(this.productIdSelected)
                //             .then(isBomNull => {
                //                 console.log('Is BOM Null?', isBomNull);
                //                 // Perform additional logic based on BOM status
                //             });
                //     }
                // }
            })
            .catch(error => {
                // Handle error from the Apex method call
                console.error('Error in canRaiseMaterialRequest:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }


    // Inside your LWC class
    async isBomNullOrNot(productId) {
        try {
            // Fetch material group scope and obligation for the product
            const result = await fetchMaterialGroupScopeAndObligation({ workOrderId: this.workOrderId, productId });

            // Check if the BOM (or any related field) is null or not
            const bomStatus = result ? true : false;
            console.log('BOM Status:', bomStatus);
            return bomStatus;
        } catch (error) {
            console.error('Error checking BOM status:', error);
            return false; // Default to false if an error occurs
        }
    }


    async loadAssetId() {
        console.log('Loading Asset ID for WorkOrderLineItem ID:', this.recordId);
        try {
            const assetData = await getAssetId({ workOrderLineItemId: this.recordId });
            if (assetData) {
                this.assetId = assetData.AssetId; // Set Asset ID
                this.cpId = assetData.CpId; // Store CP ID
                this.workOrderId = assetData.WorkOrderId;
                this.workOrderLineItemId = this.recordId;  // Set Work Order ID
                this.accountId = assetData.AccountId; // Set Account ID

                await this.loadLocation(this.cpId); // Load location with the CP ID
            }
            console.log('Retrieved Asset ID:', this.assetId);
            console.log('Retrieved Work Order ID:', this.workOrderId);
            console.log('Retrieved Account ID:', this.accountId);
            console.log('Retrieved Work Order Line Item ID:', this.workOrderLineItemId);
        } catch (error) {
            console.error('Error retrieving asset ID:', error);
        }
    }

    async loadLocation(cpId) {
        console.log('Loading Location for CP ID:', cpId);
        try {
            const locationMap = await getLocationByCPId({ cpIds: [cpId] }); // Get location by CP ID
            console.log('Retrieved Locations:', locationMap);
            if (locationMap && locationMap[cpId]) {
                this.location = locationMap[cpId]; // Set the location ID
                console.log(`Location ID for CP ID ${cpId}:`, this.location);
            } else {
                console.log(`No location found for CP ID ${cpId}`);
            }
        } catch (error) {
            console.error('Error retrieving location:', error);
        }
    }

    async checkProductItemId() {
        console.log('Location in checkProductItemId:', this.location);
        console.log('Entered checkProductItemId'); // Log that the check button was clicked

        if (this.selectedProducts.length > 0) {
            const lastSelectedProductId = this.selectedProducts[this.selectedProducts.length - 1].Id;
            console.log('Last selected product ID:', lastSelectedProductId);
            //console.log(JSON.stringify(this.location));

            try {
                const item = await getProductItemsForSelected({ productIds: lastSelectedProductId, locations: this.location });

                if (item) {
                    this.productItemId = item.Id;
                    this.quantityOnHand = item.QuantityOnHand;
                    this.showReturnableMessage = item.Product2.Is_Returnable__c === true;
                    console.log('showReturnableMessage:', this.showReturnableMessage);
                    this.showStockAvailableMessage = this.quantityOnHand > 0;
                    this.showStockNotAvailableMessage = this.quantityOnHand == 0.00; // Track stock not available
                    this.isButtonDisabled = this.quantityOnHand === 0; // Disable button if no stock
                    this.showMRSection = true; // Assuming you want to show the MR section if we checked stock

                    this.disableRaiseMRButton = this.quantity === 0;
                    this.materialGroup = item.Product2.Material_Group__c;

                } else {
                    this.productItemId = null;
                    this.quantityOnHand = null;
                    this.showStockNotAvailableMessage = true;
                }

                console.log('Fetched Product Item ID:', this.productItemId);
                console.log('Fetched Quantity on Hand:', this.quantityOnHand);
                console.log('showStockNotAvailableMessage:', this.showStockNotAvailableMessage);
                this.handleFetchMaterialGroupScopeAndObligation(this.productIdSelected);


            } catch (error) {
                console.error('Error fetching product item ID:', error);
            }
        } else {
            console.log('No selected products to check.');
        }
    }




    handleSearchTermChange(event) {
        this.searchTerm = event.target.value.toLowerCase();

        debugger;
        console.log('this.searchTerm', this.searchTerm);
        if (this.searchTerm) {

            this.getSpareProducts();

        } else {
            this.filteredProducts = [];
        }
    }
    getSpareProducts() {
        getSpareProducts({ searchKey: this.searchTerm })
            .then(result => {
                if (result) {
                    this.allProducts = result.map(product => ({ ...product, modalOpen: false, Family_Name: product.Product_Family__r?.Name || '', }));
                    this.filteredProducts = this.allProducts.filter(product =>
                    ((product.Name != null && product.Name.toLowerCase().includes(this.searchTerm)) ||
                        (product.ProductCode != null && product.ProductCode.toLowerCase().includes(this.searchTerm)))
                    );
                }
            })
    }

    addProductToSelection(event) {
        const productId = event.currentTarget.dataset.id;


        const selectedProduct = this.allProducts.find(product => product.Id === productId);

        if (selectedProduct && !this.selectedProducts.some(product => product.Id === productId)) {
            this.selectedProducts = [...this.selectedProducts, selectedProduct];
        }
    }

    removeProductFromSelection(event) {
        const productId = event.target.dataset.id;
        this.selectedProducts = this.selectedProducts.filter(product => product.Id !== productId);
    }

    handleOpenModal(event) {
        const productId = event.target.dataset.id;
        this.productIdSelected = productId;
        this.filteredProducts = this.filteredProducts.map(product =>
            product.Id === productId ? { ...product, modalOpen: true } : product
        );

        this.quantityToConsume = 0; // Reset quantity

        this.isButtonDisabled = true; // Disable "Consume Product" button by default
        this.errorMessage = ''; // Clear any previous error message
        this.showReturnableMessage = false;
        this.showStockAvailableMessage = false;
        this.checkSpareDisabled = false;
    }

    handleClosePopup(event) {
        const productId = event.target.dataset.id;
        this.filteredProducts = this.filteredProducts.map(product =>
            product.Id === productId ? { ...product, modalOpen: false } : product
        );

        this.quantityToConsume = 0; // Reset quantity
        this.serialNumbers = []; // Clear serial numbers
        this.isButtonDisabled = true;
        this.errorMessage = ''; // Clear error message
        this.showReturnableMessage = false;
        this.showStockAvailableMessage = false;
        this.successMessage = '';
        this.quantity = null;
        this.showMRSection = false;
        this.showStockNotAvailableMessage = false;
        this.isButtonDisabled = false;
        this.disableRaiseMRButton = false;

    }

    handleConfirmSelection(event) {
        this.handleClosePopup(event);
    }

    handleQuantityChange(event) {
        this.quantityToConsume = parseInt(event.target.value) || 0; // Parse the quantity input

        this.isButtonDisabled = this.quantityToConsume === 0 || this.quantityToConsume > this.quantityOnHand;

        if (this.quantityToConsume > this.quantityOnHand) {
            this.errorMessage = `Cannot consume more than available quantity (${this.quantityOnHand}).`;
        } else {
            this.errorMessage = ''; // Clear error message if valid
        }

        this.generateSerialNumberFields(); // Generate serial number fields when quantity changes
    }

    generateSerialNumberFields() {
        //      const quantity = this.quantity || this.quantityToConsume; // Use quantity if defined, otherwise use quantityToConsume

        // if (quantity > 0) {
        //     this.serialNumbers = Array.from({ length: quantity }, (_, i) => ({
        //         id: i + 1,
        //         defectiveSerialNumber: '',
        //         newSerialNumber: ''
        //     }));
        // } else {
        //     this.serialNumbers = [];
        // }
        console.log('this.quantityToConsume-->' + this.quantityToConsume);
        if (this.quantityToConsume && this.quantityToConsume > 0) {
            this.serialNumbers = []; // Clear serial numbers
            this.serialNumbers = Array.from({ length: this.quantityToConsume }, (_, index) => ({
                id: index,
                oldSerial: '',
                newSerial: '',
                productId: this.productId  // Link each serial number to productId
            }));


        }
        console.log('this.serialNumbers in start-->' + JSON.stringify(this.serialNumbers));

    }

    handleDefectivePartNumber(event) {
        console.log('event.currentTarget.dataset.index;-->' + JSON.stringify(event.currentTarget.dataset.index));

        // const id = event.target.dataset.id;
        // const value = event.detail; // Value from barcode scan
        // const index = this.serialNumbers.findIndex(sn => sn.id === parseInt(id));
        // if (index > -1) {
        //     this.serialNumbers[index].defectiveSerialNumber = value;
        // }
        const index = event.currentTarget.dataset.index;

        this.serialNumbers[index].oldSerial = event.detail;
        console.log('in old part-->' + JSON.stringify(this.serialNumbers));


    }
    handleDefectivePartNumberSingle(event) {

        console.log('Event detail:', event.detail);


        this.serialNumbers.oldSerial = event.detail;
        console.log('in old part-->' + JSON.stringify(this.serialNumbers.oldSerial));


    }

    handleNewPartNumber(event) {
        // const id = event.target.dataset.id;
        // const value = event.detail; // Value from barcode scan
        // const index = this.serialNumbers.findIndex(sn => sn.id === parseInt(id));
        // if (index > -1) {
        //     this.serialNumbers[index].newSerialNumber = value;
        // }
        const index = event.target.dataset.index;
        this.serialNumbers[index].newSerial = event.detail;
        console.log('in new part-->' + JSON.stringify(this.serialNumbers));

    }


    async handleConsumeProduct() {

        this.isButtonDisabled = true;
        this.showSpinner = true;



        console.log('serialNumbers-->' + JSON.stringify(this.serialNumbers));

        console.log('this.serialNumbers.oldSerial-->' + JSON.stringify(this.serialNumbers.oldSerial));

        if (this.quantityToConsume === 0 || this.quantityToConsume === '') {
            this.errorMessage = 'Please enter a valid quantity.';
            this.isButtonDisabled = false;
            this.showSpinner = false;
            return; // Exit the method early
        }

        if (this.serialNumbers.some(item => !item.oldSerial || item.oldSerial.trim() === '')) {
            this.errorMessage = 'Old serial number is required for all entries.';
            this.isButtonDisabled = false;
            this.showSpinner = false;
            return;
        }


        if (!this.serialNumbers.some(sn => sn.oldSerial && sn.oldSerial.trim() !== '')) {
            this.errorMessage = 'At least one old serial number is required.';
            this.isButtonDisabled = false;
            this.showSpinner = false;
            return;
        }

        try {
            const productItemId = this.productItemId;
            const productId = this.productIdSelected; // Ensure you have the productId assigned from the selected product
            const quantity = this.quantityToConsume;
            const workOrderId = this.workOrderId;
            const workOrderLineId = this.recordId;
            const accountId = this.accountId;
            const cpId = this.cpId;
            const obligationValue = this.obligationValue;
            const qtySerialNumberDetalils = JSON.stringify(this.serialNumbers);
            const qtyInHand = this.quantityOnHand;
            const scope = this.scope;
            const wtyEndDate = this.wtyEndDate;
        

            // Log the materialGroupScopeObligation to check if it's defined properly
            console.log('materialGroupScopeObligation:', this.materialGroupScopeObligation);

            // Ensure materialGroupScopeObligation is properly defined before accessing isMaterialGroupMatched
            const isMaterialGroupMatched = this.materialGroupScopeObligation && this.materialGroupScopeObligation.isMaterialGroupMatched !== undefined
                ? this.materialGroupScopeObligation.isMaterialGroupMatched
                : false;

            console.log('productItemId:', productItemId);
            console.log('productId:', productId);
            console.log('quantity:', quantity);
            console.log('workOrderId:', workOrderId);
            console.log('workOrderLineId:', workOrderLineId);
            console.log('accountId:', accountId);
            console.log('cpId:', cpId);
            console.log('serialNumbers:', this.serialNumbers); // Log the serial numbers
            console.log('isMaterialGroupMatched:', isMaterialGroupMatched); // Log the value of isMaterialGroupMatched

            const result = await createProductConsumedRecord({
                qtySerialNumberDetalils,
                workOrderId,
                workOrderLineId,
                accountId,
                quantity,
                qtyInHand,
                productItemId,
                productId,
                obligationValue,
                isMaterialGroupMatched,
                cpId,
                scope,
                wtyEndDate
            });
            if(this.cpsdnonnamonic = false) {
            this.successMessage = `Successfully consumed ${quantity} products!`;
            }else
            this.successMessage = `Successfully consumed ${quantity} products and MR not Created NON NAMO+ CPSD+ NIC Case!`
            this.showSuccessMessage = true;
            this.isButtonDisabled = false;
            this.selectedProducts = [];
            this.quantityToConsume = ''; // Reset quantity after consumption
            this.serialNumbers = []; // Clear serial numbers after consumption
            this.showReturnableMessage = false;
            this.isButtonDisabled = true;
            this.checkSpareDisabled = true;

            console.log('Consume Product result:', result);
            this.showSpinner = false;



        } catch (error) {
            this.errorMessage = `Error consuming product: ${error.message}`;
            console.error('Error consuming product:', error);
              console.error('Error:', JSON.stringify(error));
            this.isButtonDisabled = false;
            this.showSpinner = false;


        }
    }


    // Method to handle product request creation
    async handleCreateProductRequest() {

        this.disableRaiseMRButton = true;
        this.showSpinner = true;

        if (this.quantity === 0) {
            this.errorMessage = 'Cannot create a MR as the quantity is zero.';
            this.disableRaiseMRButton = false;
            this.showSpinner = false;
            return;
        }

        if (!this.serialNumbers.oldSerial || this.serialNumbers.oldSerial.trim() === '') {
            this.errorMessage = 'Old serial number is required.';
            this.disableRaiseMRButton = false;
            this.showSpinner = false;
            return;
        }


        const allowedProductFamilies = Family_Names.split(',').map(item => item.trim());
        console.log('allowedProductFamiliesn -' + allowedProductFamilies);
        const selectedProductFamilies = this.selectedProducts.map(product => product.Family_Name);
        console.log('selectedProductFamilies - ' + selectedProductFamilies);
        // Check if any product family in the selected list matches the allowed product families
        const hasMatchingProduct = selectedProductFamilies.some(family =>
            allowedProductFamilies.includes(family)
        );

        if (hasMatchingProduct && !this.serialNumbers.oldSerial) {
            console.log('selectedProductFamilies 497- ' + selectedProductFamilies);

            this.errorMessage = 'Please Enter Serial Number.';
            this.disableRaiseMRButton = false;
            this.showSpinner = false;
            return;
        }

        console.log('Creating Product Request with the following parameters:');
        console.log({
            productid: this.productIdSelected,
            WorkOrderId: this.workOrderId,
            cpId: this.cpId,
            branch: this.branch,
            mrLocation: this.mrLocation,
            WorkOrderLineId: this.recordId,
            Quantity: this.quantity,
            ProductItemid: this.productItemId,
            isMaterialGroupMatched: this.isMaterialGroupMatched,
            obligationValue: this.obligationValue,
            oldSerial: this.serialNumbers.oldSerial,
            scope: this.scope
        });
        try {
            this.disableRaiseMRButton = true;
            await createProductRequest({
                productid: this.productIdSelected,
                WorkOrderId: this.workOrderId,
                cpId: this.cpId,
                branch: this.branch,
                mrLocation: this.mrLocation,
                WorkOrderLineId: this.recordId,
                Quantity: this.quantity,
                ProductItemid: this.productItemId,
                isMaterialGroupMatched: this.isMaterialGroupMatched,
                obligationValue: this.obligationValue,
                oldSerial: this.serialNumbers.oldSerial,
                endDate: this.wtyEndDate,
                scope: this.scope

            });
            this.successMessage = 'Product Request created successfully!';
            console.log('Scope value:', this.scope);
            this.showSuccessMessage = true;
            console.log('Product Request created successfully!');
            console.log('Scope',  )
            this.showSpinner = false;

        } catch (error) {
            this.errorMessage = `Error creating product request: ${error.body.message}`;
            this.disableRaiseMRButton = false;
            this.showSpinner = false;

            console.error('Error creating product request:', error);
            console.log('Parameters sent to createProductRequest:', {
                productid: this.productId,
                WorkOrderId: this.workOrderId,
                cpId: this.cpId,
                branch: this.branch,
                mrLocation: this.mrLocation,
                WorkOrderLineId: this.recordId,
                Quantity: this.quantity,
                ProductItemid: this.productItemId,
                isMaterialGroupMatched: this.isMaterialGroupMatched,
                obligationValue: this.obligationValue
            });
        }
    }

    handleQuantityChange(event) {
        const value = parseInt(event.target.value) || 0;

        if (event.target.label === 'Add Quantity') {
            this.quantityToConsume = value;
        } else if (event.target.label === 'Quantity') {
            this.quantity = value;
        }

        // Check if quantityToConsume exceeds quantityOnHand
        if (this.quantityToConsume > this.quantityOnHand) {
            this.errorMessage = `Cannot consume more than available quantity (${this.quantityOnHand}).`;
            this.isButtonDisabled = true; // Disable the button
        } else {
            this.errorMessage = ''; // Clear error message if valid
            this.isButtonDisabled = this.quantityToConsume === 0; // Disable if no quantity is entered
        }

        // Generate serial number fields when quantity changes
        this.generateSerialNumberFields();
    }
    // Fetch material group scope and obligation
    handleFetchMaterialGroupScopeAndObligation(productId) {
     if (this.workOrderId) {
         fetchMaterialGroupScopeAndObligation({ workOrderId: this.workOrderId ,productId:productId})
             .then(result => {
                 console.log('Hello',JSON.stringify(result, null, 2)); 
                 this.materialGroupScopeObligation = result;
                 this.scope = result.scope;
                 this.materialGroup = result.materialgroup;
                 this.obligationValue = result.policyObligation;
                 this.isMaterialGroupMatched = result.isMaterialGroupMatched;
                 this.greaterthannamo90Days = result.greaterthannamo90Days;
                 this.cpsdnonnamonic = result.cpsdnonnamonic;
                 if (result.warrantyEndDate != '') {
                    this.wtyEndDate = result.warrantyEndDate;
                } 
                  
  if (this.cpsdnonnamonic == true) {
    this.errorMessage = 'NON Namo Customer+ CPSD+ NIC = NO MR ';
    this.disableRaiseMRButton = true;
} else if (this.greaterthannamo90Days == true && this.showStockNotAvailableMessage == true && this.isMaterialGroupMatched == true) {
    this.errorMessage = 'NAMO Customer-Part warranty expired more than 90days-Cant Raise MR';
    this.disableRaiseMRButton = true;
}
else if (this.isMaterialGroupMatched == false) {
    this.errorMessage = 'Part Scope not found, please check with admin team';
    this.disableRaiseMRButton = true;
    this.isButtonDisabled = true;
}


                 console.log('Material Group in JS:', this.materialGroup);
                 console.log('this.materialGroupScopeObligatio-->'+JSON.stringify(this.materialGroupScopeObligation));
                 console.log('WTY END Date',this.wtyEndDate)
             })
             .catch(error => {
                 console.error('Error fetching material group scope and obligation:', error);
             });
     } else {
         console.error('No workOrderId available.');
     }
 } 
    // Getter to display material group, scope, and obligation
    get materialGroupScopeObligationList() {
        return Object.keys(this.materialGroupScopeObligation).map(materialGroup => ({
            materialGroup,
             scope: this.materialGroupScopeObligation[materialGroup]?.scope,
        obligation: this.materialGroupScopeObligation[materialGroup]?.obligation,
        materialGroup: this.materialGroupScopeObligation[materialGroup]?.materialgroup
        }));
    }
}