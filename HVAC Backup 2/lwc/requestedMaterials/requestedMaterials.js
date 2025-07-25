import { LightningElement, api, track } from 'lwc';
import getProductRequests from '@salesforce/apex/RequestedMaterialsController.getProductRequests';
import getSubmittedProductRequests from '@salesforce/apex/RequestedMaterialsController.getSubmittedProductRequests';
import createProductConsumedRecords from '@salesforce/apex/RequestedMaterialsController.createProductConsumedRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class RequestedMaterials extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track showpopup = false;
    @track productRequests = [];
    @track message = '';
    @track currentPartRequestId;
     @track disableButton = false;
    makeOptions = [
        { label: 'BLUE STAR', value: 'BLUE_STAR' },
        { label: 'ERP', value: 'ERP' },
        { label: 'Other', value: 'other' }
    ];
    disableButton = false;

    connectedCallback() {
        this.fetchProductRequests();
        this.fetchSubmittedProductRequests();
    }

    fetchProductRequests() {
        this.isLoading = true;
        getProductRequests({ workOrderId: this.recordId })
            .then(data => {
                debugger;
               this.productRequests = data.map(item => ({
                ...item,
               disabled: (item.Status == 'Submitted') ? true : false  // Set 'disabled' based on item.status
            }));
                console.log('this.productRequests.data - ' , this.productRequests);
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching product requests: ', error);
                this.isLoading = false;
            });
    }

    fetchSubmittedProductRequests() {
        getSubmittedProductRequests({ workOrderId: this.recordId })
            .then(data => {
                this.disableButton = true;
                console.log('Submitted Product Requests: ', data);
            })
            .catch(error => {
                this.disableButton = false;
                console.error('Error fetching submitted product requests: ', error);
            });
    }

    handleAddProduct(event) {
        const addRowIndex = parseInt(event.target.dataset.customIndex);
        console.log('Add Product clicked for index:', addRowIndex);
        // Add your logic here to handle the button click
        this.currentPartRequests = this.productRequests[addRowIndex];
        console.log('currentPartRequests', this.currentPartRequests);
        console.log('partrequestId', this.currentPartRequests.Id);
        console.log('Status', this.currentPartRequests.Status);
        console.log('Defective Part Serial Number', this.currentPartRequests.Defective_Part_Serial_Number__c); 
        this.showpopup = true;
        console.log('partRequestId in handleConsumeProduct' + Id);

        const partRequestId = event.target.dataset.partRequestId;
        console.log('Add Product clicked for Part Request ID:', partRequestId);
        this.currentPartRequestId = partRequestId;
        this.currentPartRequests.Defective_Part_Serial_Number__c = defectivePartSerialNumber;
        this.selectedProductRequestId = event.detail.selectedProductRequestId;
    }

    handleClosePopup() {
        // This method will be called when the popup is closed
        this.showpopup = false;
        this.message = '';
    }

    handleConsumeProduct() {
        console.log('productRequestId', this.currentPartRequests.Id);
        this.isLoading = true;
        createProductConsumedRecords({ workOrderId: this.recordId, productRequestId: this.currentPartRequests.Id, newbarcode: this.scannednewBarcode })
            .then(() => {
                this.isLoading = false;
                this.message = 'Product consumed records created successfully.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.message,
                        variant: 'success'
                    })
                );
                // Optionally, refresh product requests or other relevant data
                this.fetchProductRequests();
            })
            .catch(error => {
                this.isLoading = false;
                this.message = 'Error creating product consumed records: ' + error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handleNewSerialNumber(event){
        this.scannednewBarcode = event.detail;
        
    }
}