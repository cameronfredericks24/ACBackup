import { LightningElement, track, api, wire } from 'lwc';
import isShippingPostalCodeEmpty from '@salesforce/apex/autolaunchAddress.isShippingPostalCodeEmpty';
import upsertAddress from '@salesforce/apex/autolaunchAddress.upsertAddress';
import getAddress from '@salesforce/apex/autolaunchAddress.getAddress';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';

import { RefreshEvent } from 'lightning/refresh';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddressNewEditOverride extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @api recordId;
    @track address;
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
    urlId;
    newRecord=false;
    edit=false;

    @wire(IsConsoleNavigation) isConsoleNavigation;
    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        await closeTab(tabId);
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
        console.log('currentPageReference',currentPageReference);
        console.log('currentPageReference',currentPageReference.state.ws);
        var accountId = (currentPageReference.state.ws).substring((currentPageReference.state.ws).indexOf("001"),(currentPageReference.state.ws).indexOf("001")+18);
        this.urlId = accountId;
       }
    }

    connectedCallback(){
        this.isModalOpen = true;
        console.log('urlId',this.urlId);
        console.log('recordId',this.recordId);
        if(this.recordId!=undefined && this.recordId!=null){
            this.getAddressValues();
        }else{
            this.edit=false;
            this.newRecord=true;
        }
        //this.urlId = currentPageReference.state?.id;
    }

    openModal() {
        this.isModalOpen = true;
    }

    handleOpenModal() {
        this.openModal();
    }

    handleCloseModal() {
        this.isModalOpen = false;
        if(this.newRecord){
            this.navigateToRecord(this.urlId);
        }else{
            this.navigateToRecord(this.recordId);
        }
       
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
        this.address = {};
        this.address.Id = this.recordId;
        this.address.House_Flat__c = event.detail.flat;
        this.address.Street = event.detail.street;
        if(event.detail.sector!=null && event.detail.sector!=undefined && event.detail.sector!="" ){
            this.address.Sector__c = event.detail.sector;
        }

        if(event.detail.locality!=null && event.detail.locality!=undefined && event.detail.locality!="" ){
            this.address.Locality__c = event.detail.locality;
        }

        if(event.detail.sublocality!=null && event.detail.sublocality!=undefined  && event.detail.sublocality!=""){
            this.address.Sub_Locality__c = event.detail.sublocality;
        }
        

        this.address.City = event.detail.city;
        this.address.Country = event.detail.country;
        this.address.PostalCode = event.detail.pincode;
        this.address.State = event.detail.state;
        if(this.newRecord){
            this.address.Account__c = this.urlId;
        }
        

        upsertAddress({ addressRecord: JSON.stringify(this.address) })
            .then(result => {
                console.log('result',result);
                this.recordId = result.Id;
                //this.dispatchEvent(new RefreshEvent());
                var msg = '';
                if(this.edit){
                    msg = 'Address updated successfully';
                }else{
                    msg = 'Address created successfully'
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: msg,
                        variant: 'success',
                    })
                );
                this.isModalOpen = false; 
                if(this.recordId!=undefined && this.recordId!=null){
                    console.log('record');
                    this.navigateToRecord(this.recordId);  
                }else{
                    console.log('urlId');
                    this.navigateToRecord(this.urlId);  
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
                this.isModalOpen = false; 
                if(this.recordId!=undefined && this.recordId!=null){
                    this.navigateToRecord(this.recordId);  
                }else{
                    this.navigateToRecord(this.urlId);  
                }
        });
       
           
    }

    getAddressValues(event){
        console.log('in address 1');
        getAddress({ recordId: this.recordId })
            .then(result => {
                console.log('result',result);
                this.city = result.City;
                this.state = result.State;
                this.pincode = result.PostalCode;
                this.locality = result.Locality__c;
                this.sublocality = result.Sub_Locality__c;
                this.flat = result.House_Flat__c;
                this.sector = result.Sector__c;
                this.country = result.Country;
                this.street = result.Street;
                this.isModalOpen = true;
                this.edit = true;
              
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
    }

    navigateToRecord(recordId){
        this.showSpinner=true;
        console.log('Navigate ');
        if(this.edit){
            this.closeTab();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    actionName: 'view'
                }
            });
        }else{
            this.closeTab();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    actionName: 'view'
                }
            });
            //this.dispatchEvent(new RefreshEvent());
        }
    }
}