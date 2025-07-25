import { LightningElement,wire,api,track } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import getProductItemList from '@salesforce/apex/ProductTransferController.getProductItemList';
import createProductTransfer from '@salesforce/apex/ProductTransferController.createProductTransfer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningModal from 'lightning/modal';

export default class createProductTransferCmp extends LightningModal {

    @api recordId;
    columns;
    productItemWrapper = null
    maxTransferQuan
    transferQuan;
    isReceived;
    showModal;
    quantityRequested;
    @track isLoading = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
    }
}

    connectedCallback(){
        this.showModal = true;
        this.columns = [
            { label: 'Product Name', fieldName: 'ProductName', type: 'text' , cellAttributes: { alignment: 'center' },hideDefaultActions: true},
            { label: 'Quantity In Inventory', fieldName: 'QuantityOnHand', type: 'text', cellAttributes: { alignment: 'center' },hideDefaultActions: true},
            { label: 'Quantity Requested', fieldName: 'QuantityRequested', type: 'number' , cellAttributes: { alignment: 'center' },hideDefaultActions: true}
        ];
        console.log(this.recordId,'this.recordId')
        getProductItemList({ prodReqLineItemId: this.recordId})
            .then(result => {
            console.log(result);
            if(result.length != 0 ) {
                this.productItemWrapper = result;
                this.maxTransferQuan = result ? result[0].QuantityOnHand : 0;
                this.quantityRequested = result ? result[0].QuantityRequested : 0;
            }
            
            console.log('productItemList-->'+JSON.stringify(this.productItemWrapper));
            console.log(this.maxTransferQuan,'maxTransferQuan')
        })
        .catch(error => {
            this.error = error;
        })
    }

    onSubmitHandler(){

         
        if(this.transferQuan > this.maxTransferQuan){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Transfer Quantity cannot be greater than Quantity In Inventory',
                    variant: 'error',
                }),
            );
            return;
        }
        
        if(this.transferQuan == 0 || this.transferQuan == '' || this.transferQuan == undefined)
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Transfer Quantity cannot be blank or zero',
                    variant: 'error',
                }),
            );
            return;
        }

        if(this.transferQuan > this.quantityRequested){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Transfer Quantity cannot be greater than Quantity Requested',
                    variant: 'error',
                }),
            );
            return;
        }

        this.isLoading = true; 
        var prodItemInputWrapper; 
        console.log('wrap',JSON.stringify(this.productItemWrapper))
        
        const json = JSON.stringify(this.productItemWrapper)
        // Parse the JSON into a JavaScript object
        const data = JSON.parse(json);

        // Access the value and assign it to a variable
        prodItemInputWrapper = data[0];
        console.log('prodItemInputWrapper',prodItemInputWrapper)
        console.log('transferQuam',this.transferQuan)
        console.log('isReceived',this.isReceived)
        if(this.isReceived == null || this.isReceived == undefined) this.isReceived = false;
        createProductTransfer({prodItemWrapper:prodItemInputWrapper,transferQuan:this.transferQuan,isReceived:this.isReceived,prodReqLineItemId:this.recordId})
        .then(result => {
            console.log(result,'result');
            if(result == 'Product Transfer Created Successfully'){
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Product Transfer Created Successfully',
                        variant: 'success',
                    }),
                );
                
                this.dispatchEvent(new CloseActionScreenEvent());
            } else if(result == 'Product Transfer Already Created') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                    }),
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while creating Product Transfer',
                        variant: 'error',
                    }),
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            
            this.isLoading = false;
        })
        .catch(error => {
            console.log(error)
            this.error = error;
            
        })

        console.log('sumit')
    }

    onCancelHandler(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleQuanChange(event){
        this.transferQuan = event.target.value;
        console.log(this.transferQuan,'this.transferQuan')
    }

    handleReceiveChange(event){
        this.isReceived = event.target.checked;
        console.log(this.isReceived,'this.isReceived')
    }
}