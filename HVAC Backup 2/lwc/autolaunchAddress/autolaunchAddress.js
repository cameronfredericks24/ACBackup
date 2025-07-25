import { LightningElement, track, api, wire } from 'lwc';
import isShippingPostalCodeEmpty from '@salesforce/apex/autolaunchAddress.isShippingPostalCodeEmpty';
import updateAccount from '@salesforce/apex/autolaunchAddress.updateAccount';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import getShippingPincode from '@salesforce/apex/autolaunchAddress.getShippingPincode';

import { RefreshEvent } from 'lightning/refresh';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [
    'Account.Shipping_Pincode__c'
];

export default class AutolaunchAddress extends LightningElement {
    @track isModalOpen = false;
    @api recordId;
    @track account;
    @api calledFromFlow=false;
    @api pincode;
    @api city;
    @api state;
    @api country;
    @api flat;
    @api street;
    @api locality;
    @api sublocality
    @api sector;
    @api label;
    addressSaved = false;


    connectedCallback() {
        console.log('val',this.calledFromFlow);
        console.log('val',this.calledFromFlow==false);

        if(this.calledFromFlow==false){
            this.getShippingPincodeMethod();
        }
        
    }

    checkShippingPostalCode() {
        isShippingPostalCodeEmpty({ accountId: this.recordId })
            .then(result => {
                if (result) {
                    this.openModal();
                }
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while checking the postal code.', 'error');
                console.error('Error in checkShippingPostalCode:', error);
            });
    }

    getShippingPincodeMethod() {
        getShippingPincode({ accountId: this.recordId })
            .then(result => {

                if (result) {
                    this.pincode = result;
                    this.checkShippingPostalCode();
                }else{
                    this.checkShippingPostalCode();
                }
                
            })
            .catch(error => {
                //this.checkShippingPostalCode();
                //this.showToast('Error', 'An error occurred while checking the postal code.', 'error');
                console.error('Error in checkShippingPostalCode:', error);
            });
    }

    openModal() {
        this.isModalOpen = true;
    }

    handleOpenModal() {
        this.openModal();
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
    handleAddressValues(event){
        console.log('in address');
        this.account = {};
        this.account.Id = this.recordId;
        this.account.Shipping_House_Flat_BlockNo__c = event.detail.flat;
        //this.account.Shipping_Locality__c = event.detail.locality;
        //this.account.Shipping_SubLocality__c = event.detail.sublocality;
        this.account.ShippingStreet = event.detail.street;
        if(event.detail.sector!=null && event.detail.sector!=undefined && event.detail.sector!="" ){
            this.account.Shipping_Sector__c = event.detail.sector;
        }

        if(event.detail.locality!=null && event.detail.locality!=undefined && event.detail.locality!="" ){
            this.account.Shipping_Locality__c = event.detail.locality;
        }

        if(event.detail.sublocality!=null && event.detail.sublocality!=undefined  && event.detail.sublocality!=""){
            this.account.Shipping_Sublocality__c = event.detail.sublocality;
        }
        

        this.account.ShippingCity = event.detail.city;
        this.account.ShippingCountry = event.detail.country;
        this.account.ShippingPostalCode = event.detail.pincode;
        this.account.ShippingState = event.detail.state;
        //this.formData.StateCode = (foundObject!=null && foundObject!=undefined) ? foundObject.value : null;

        console.log('account',this.account);
        console.log('account',this.account.ShippingPostalCode);
        if(this.calledFromFlow){
            this.isModalOpen=false;
            this.pincode = this.account.ShippingPostalCode;
            this.city = this.account.ShippingCity;
            this.state= this.account.ShippingState;
            this.country = this.account.ShippingCountry;
            this.flat = this.account.Shipping_House_Flat_BlockNo__c;
            this.street = this.account.ShippingStreet;
            this.locality = this.account.Shipping_Locality__c;
            this.sublocality = this.account.Shipping_SubLocality__c;
            this.sector = this.account.Shipping_Sector__c;
            ["pincode", "city", "country","flat","street","locality","sublocality","sector"].forEach((inp) =>
                this.dispatchEvent(new FlowAttributeChangeEvent(inp, this[inp]))
            );
            this.addressSaved = true;
        }else{
            updateAccount({ accountToUpdate: this.account })
            .then(result => {
                this.dispatchEvent(new RefreshEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Address updated successfully',
                        variant: 'success',
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
        });
        this.isModalOpen = false;

        }
       
    }
}