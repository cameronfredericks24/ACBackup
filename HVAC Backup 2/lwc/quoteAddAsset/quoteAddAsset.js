import { LightningElement, wire, track, api } from 'lwc';
import formQuoteLines from '@salesforce/apex/QuoteAddAssetController.formQuoteLines';
import processSelectedQuoteLines from '@salesforce/apex/QuoteAddAssetController.processSelectedQuoteLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLines from '@salesforce/apex/QuoteAddAssetController.getQuoteLines';
import deleteQuoteLines from '@salesforce/apex/QuoteAddAssetController.deleteQuoteLines';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
// import getOpportunityStageForQuote from '@salesforce/apex/QuoteAddAssetController.getOpportunityStageForQuote';

const columns = [
    { label: 'Asset Name', fieldName: 'AssetName' },
    { label: 'Obligation', fieldName: 'obligation' },
    { label: 'Model Capacity', fieldName: 'Capacity', type: 'number' },
    { label: 'Actual Capacity', fieldName: 'ActualCapacity', type: 'number', editable: true},
    { label: 'UOM', fieldName: 'Unit' },
    { label: 'Price', fieldName: 'price', type: 'decimal' },
    { label: 'Proposal Start Date', fieldName: 'startDate', type: 'date' },
    { label: 'Proposal End Date', fieldName: 'endDate', type: 'date' },
    { label: 'Comments', fieldName: 'comments'}
];

const columns1 = [
    { label: 'Asset Name', fieldName: 'AssetName' },
    { label: 'Obligation', fieldName: 'obligation' },
    { label: 'Model Capacity', fieldName: 'Capacity', type: 'number' },
    { label: 'Actual Capacity', fieldName: 'ActualCapacity', type: 'number'},
    { label: 'UOM', fieldName: 'Unit' },
    { label: 'Price', fieldName: 'price', type: 'decimal' },
    { label: 'Proposal Start Date', fieldName: 'startDate', type: 'date' },
    { label: 'Proposal End Date', fieldName: 'endDate', type: 'date' },
    { label: 'Comments', fieldName: 'comments'}
];

export default class QuoteAddAsset extends NavigationMixin(LightningElement) {
    @api recordId;
    objectApiName;
    @track quoteLineWrappers = [];
    columns = columns;
    columns1 = columns1;
    selectedRows = [];
    showQuoteLines = true;
    showContent = true;
    showCreateMessage = false;
    message = 'No quote lines available for this quote.';
    draftValues = [];
    showContractNoSelected = false;
    
    @track quoteLines = [];
    @track selectedQuoteLineRows = [];
    @track isModalOpen = false;
    wiredQuoteLinesResult;
    wiredFormQuoteLinesResult;

    // @track opportunityStage = '';
    // @track isProposalStage = false;

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.objectApiName = data.apiName;
        } else if (error) {
            console.error(error);
        }
    }
    
    // @wire(getOpportunityStageForQuote, { recordId: '$recordId' })
    // wiredOpportunityStage({ error, data }) {
    //     if (data) {
    //         this.opportunityStage = data;

    //         // Check if the stage is one of the restricted stages
    //         const restrictedStages = ['In Review', 'Site Visited', 'Prospecting'];
    //         this.isProposalStage = restrictedStages.includes(this.opportunityStage);

    //     } else if (error) {
    //         console.error('Error fetching opportunity stage:', error);
    //     }
    // }

    @wire(getQuoteLines, { quoteId: '$recordId' })
    wiredOldQuoteLines(result) {
        this.wiredQuoteLinesResult = result;
        if (result.data) {
            this.quoteLines = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Failed to load quote lines', 'error');
        }
    }

    handleQuoteLineRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedQuoteLineRows = selectedRows;
    }

    handleDeleteClick() {
        if (this.selectedQuoteLineRows.length > 0) {
            this.isModalOpen = true;
        } else {
            this.showToast('Error', 'No rows selected', 'error');
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    confirmDelete() {
        const quoteLineIds = this.selectedQuoteLineRows.map(row => row.quoteLineId);
        deleteQuoteLines({ quoteLineIds })
            .then(() => {
                this.showToast('Success', 'Quote lines deleted', 'success');
                this.message = 'Quote Lines deleted successfully.';
                this.showCreateMessage = false;
                this.showContent = true;
                this.selectedQuoteLineRows = [];
                this.quoteLines = [];
                 refreshApex(this.wiredQuoteLinesResult);
                 refreshApex(this.wiredFormQuoteLinesResult);
            })
            .then(() => {
                this.navigateToRecordView();
            })
            .catch(error => {
                this.showToast('Error', 'Failed to delete quote lines', 'error');
            })
            .finally(() => {
                this.isModalOpen = false;
                this.selectedQuoteLineRows = [];
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }

    @wire(formQuoteLines, { quoteId: '$recordId' })
    wiredQuoteLines(result) {
        this.wiredFormQuoteLinesResult = result;
        if (result.data) {
            this.quoteLineWrappers = result.data.map(item => {
                return {
                    ...item,
                    selected: false
                };
            });

            if (!(this.quoteLineWrappers && this.quoteLineWrappers.length > 0)) {
                this.showContent = false;
            } else if(this.quoteLineWrappers.length > 0 && (this.quoteLineWrappers[0].contractType == null || this.quoteLineWrappers[0].contractType == '')){
                this.showContractNoSelected = true; //show contract not selected message
            }
        } else if (result.error) {
            console.error(error);
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRows = selectedRows;
        console.log(' this.selectedRows : ', this.selectedRows);
    }

    processSelected() {
        if (this.selectedRows && this.selectedRows.length > 0) {
            const selectedRowsJson = JSON.stringify(this.selectedRows);
            processSelectedQuoteLines({ selectedQuoteLinesJson: selectedRowsJson })
                .then(() => {
                    this.showQuoteLines = false;
                    this.showCreateMessage = true;
                    this.showToast('Success', 'Quote Line Created successfully.', 'success');
                    console.log('Selected rows processed successfully');
                    refreshApex(this.wiredQuoteLinesResult);
                 refreshApex(this.wiredFormQuoteLinesResult);
                })
                .then(() => {
                    this.navigateToRecordView();
                })
                .catch(error => {
                    this.showToast('Error', 'There is some error while processing line items. Please contact your Admin.', 'error');
                    console.error('Error processing selected rows: ', error);
                });
        } else {
            this.showToast('Alert', 'Select quote lines to be processed.', 'alert');
        }
    }

    handleCheckboxChange(event) {
        const selectedRowId = event.target.dataset.id;
        const selected = event.target.checked;
        this.quoteLineWrappers = this.quoteLineWrappers.map(row => {
            if (row.assetId === selectedRowId) {
                return { ...row, selected };
            }
            return row;
        });
    }

    navigateToRecordView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        });
    }

    handleCellChangeOnAssetId(event) {
        // Get the row that was modified
        this.draftValues = event.detail.draftValues;
        const modifiedRow = event.detail.draftValues[0];
        console.log('Modified Row:', modifiedRow);
      
       
        // Get the value of a specific field in the modified row
        const modifiedValue = modifiedRow.ActualCapacity;
        const selectedRow = modifiedRow.assetId;
        console.log('Modified Value:', modifiedValue);
        console.log('selected asset:', selectedRow);
        console.log('qli:', this.quoteLineWrappers);
        for (let i = 0; i < this.quoteLineWrappers.length; i++) {
            if(this.quoteLineWrappers[i].assetId == selectedRow && this.quoteLineWrappers[i].division != 'CPSD'){
                this.quoteLineWrappers[i].ActualCapacity = this.quoteLineWrappers[i].Capacity;
                for(let j = 0; j < this.draftValues.length; j++){
                    if(this.draftValues[j].assetId == selectedRow){
                        this.draftValues[j] = this.quoteLineWrappers[i].ActualCapacity;
                    }
                }
                
                alert('You can change the Actual Capacity for only 50 & 51 dept models for price change.');
                
                return;
            }
        }

        for (let i = 0; i < this.quoteLineWrappers.length; i++) {
            if(this.quoteLineWrappers[i].assetId == selectedRow){
                
                var actualCapacity = modifiedValue;
                var modelCapacity = this.quoteLineWrappers[i].Capacity;
                var modelPrice = this.quoteLineWrappers[i].modelPrice;
                var modelOneYearPrice = this.quoteLineWrappers[i].modelOneYearPrice;
                //var perDay = (modelPrice/modelOneYearPrice);
                var perDay = this.quoteLineWrappers[i].noOfDays/365;
                var pricePerUnit = modelPrice/modelCapacity;
                var actualPricePerUnit = Math.round(pricePerUnit*actualCapacity);
                var actualPrice = Math.round(actualPricePerUnit*perDay);
                //this.quoteLineWrappers[i].oneYearPrice = actualPricePerUnit*actualCapacity;
                this.quoteLineWrappers[i].price = actualPrice;
                this.quoteLineWrappers[i].ActualCapacity = modifiedValue;


            }
        }

        /*this.quoteLineWrappers = this.quoteLineWrappers.map(row => {
            if (row.assetId === selectedRow) {
                row.ActualCapacity = modifiedValue;
            }
            
        });*/


    }
}