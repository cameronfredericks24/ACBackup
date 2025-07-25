import { LightningElement, track } from 'lwc';
import searchBOMRecords from '@salesforce/apex/BOMSearchController.searchBOMRecords';
import getBOMDetails from '@salesforce/apex/BOMSearchController.getBOMDetails';
import getBOMItemDetails from '@salesforce/apex/BOMSearchController.getBOMItemDetails';
import createProductRequiredRecord from '@salesforce/apex/BOMSearchController.createProductRequiredRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SearchComponent extends LightningElement {
    @track workOrderId;
    @track searchTerm = '';
    @track searchResults = [];
    @track selectedRecordId;
    @track bomDocumentUrl;
    @track bomItemDetails = [];
    @track productRequiredCounter = 0;

    columns = [
        // Define your columns here based on the object structure you are working with
        { label: 'Name', fieldName: 'Name', type: 'text' },
        // Add more columns as needed
    ];

    connectedCallback() {
        // Set the default value for workOrderId to the current record's Id
        this.workOrderId = this.recordId;
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearch() {
       searchBOMRecords({ searchTerm: this.searchTerm })
            .then(result => {

                console.log('API Response:',  JSON.stringify(result));
                
		if(result.isSuccess){
                       if(result.bomDetails.length > 0){
				this.searchResults = result.bomDetails;

			}
			else{
			     this.showMessageToast('Search Failed', 'No bom details avaiable', 'error');

			}
		}
		else{
			   this.showMessageToast('Search Failed', result.errorMessage, 'error');

		}

            })
            .catch(error => {
			   this.showMessageToast('Search Failed', 'Server Error ! please contact your admin', 'error');
            });
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.selectedRecordId = selectedRows[0].Id;
            console.log('Selected Record ID:', this.selectedRecordId);

            // Load BOM details and BOM item details
            this.loadBOMDetails();
            this.loadBOMItemDetails();
        }
    }

    loadBOMDetails() {
        getBOMDetails({ recordId: this.selectedRecordId })
            .then(result => {
                console.log('BOM Details Result:', result);
                // Document_URL__c field on BOM__c
                this.bomDocumentUrl = result.Document_URL__c;
            })
            .catch(error => {
                console.error(error);
            });
    }

    loadBOMItemDetails() {
        getBOMItemDetails({ recordId: this.selectedRecordId })
            .then(result => {
                console.clear;
                console.log('BOM Item Details Result:', JSON.stringify(result));
                // Increment the counter when BOM item details are loaded
                this.productRequiredCounter++;
                // Return a map of field names and values for BOM Item details
                this.bomItemDetails = result;
            })
            .catch(error => {
                console.error(error);
            });
    }
    handleProductRequiredChange(event) {
    console.log('hi quantity');
    console.log(event.target.dataset.customIndex);
    console.log('after printing' + parseInt(event.target.value));
    console.log('In quantity change ' + JSON.stringify(this.bomItemDetails[event.target.dataset.customIndex]));
    console.log(this.bomItemDetails[event.target.dataset.customIndex].productrequiredquantity);

    // Get the entered value
    const enteredValue = parseInt(event.target.value);
    const index = event.target.dataset.customIndex;

    // Add conditions to validate entered quantity
    if (enteredValue) {
        if (enteredValue >= 0 && enteredValue <= this.bomItemDetails[index].Quantity) {
            this.bomItemDetails[index].productrequiredquantity = enteredValue;
            console.log('hello');
            console.log('In quantity change ' + JSON.stringify(this.bomItemDetails));
        } else {
             this.bomItemDetails[index].productrequiredquantity = this.bomItemDetails[index].Quantity;
            this.showMessageToast('Please enter a valid quantity between 0 and ' + this.bomItemDetails[index].Quantity);
        }
    } else {
         this.bomItemDetails[index].productrequiredquantity = 0;
        this.showMessageToast('Please enter a valid numeric quantity');
    }
}


    handleIncrement() {
        this.productRequiredCounter++;
    }

    handleDecrement() {
        if (this.productRequiredCounter > 0) {
            this.productRequiredCounter--;
        }
    }

     handleAddProduct(event) {
     // Prepare the record input values
     var addRowIndex = parseInt(event.target.dataset.customIndex);
     console.log(addRowIndex);

     // Check if productrequiredquantity is not zero
     if (this.bomItemDetails[addRowIndex].productrequiredquantity > 0) {
        console.log('hello hello')
        const recordInput = {
            
            bomItemId: this.bomItemDetails[addRowIndex].bompathid,
            quantityRequired: this.bomItemDetails[addRowIndex].productrequiredquantity,
            
        };

        console.log('recordInput:', JSON.stringify(recordInput));

        // Create the ProductRequired record
        createProductRequiredRecord(recordInput)
            .then(result => {
                // ProductRequired record created successfully
                console.log('ProductRequired record created with Id:', result);
                this.bomItemDetails[addRowIndex].isproductcreated = true;
                 this.showMessageToast('Product Consumed record Created');
                // Optionally, you can perform additional actions after record creation
            })
            .catch(error => {
                // Handle errors
                console.error('Error creating ProductRequired record:', error);
                console.error('Error details:', error.body);
            });
    } else {
        this.showMessageToast('Please add valid quantity');
    }
}

    showMessageToast(title = 'Message', messageI, variantI = 'info', modeI = 'dismissable') {
    console.log('showMessageToast');
    const evt = new ShowToastEvent({
      title: title,
      message: messageI,
      variant: variantI,
      mode: modeI
    });
    this.dispatchEvent(evt);
  }
}