import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import tagChannelPartnerUI from '@salesforce/apex/CreateCaseFormController.tagChannelPartnerUI';
import checkAssetWty from '@salesforce/apex/CreateCaseFormController.checkAssetWty';
import  checkWorkOrderPMS from '@salesforce/apex/CreateCaseFormController.checkWorkOrderPMS';
import { NavigationMixin } from 'lightning/navigation';

import { updateRecord } from "lightning/uiRecordApi";

export default class CreateWorkOrder extends NavigationMixin(LightningElement) {
    @api recordId;
    @api assetId;
    @api parentLwc = false;
    @api caseType;
    @track pmsremaining;
    accountId;
    errorMessage;
    showError=false;
    disableButton=false;
    disButton = false;
    showSpinner=false;
    showFlow =false;
    showWtyExist=false;
    showWtyNotExist =false;
    showWtyButNoPMS =false;
    inputVariables=[];
    showDecline=false;
    @api showBooking=false;
    pmsUsed;
    pmsAvailable;
    @api workOrderCreated=false;

   
   
    constructor(){
        super();
    }
    connectedCallback() {
        console.log('this.recordId c',this.recordId);
        debugger;
       
        if(this.isRecordIdAvailable == true){
            setTimeout(() => {
            
                console.log('this.recordId f',this.recordId);
                this.checkAssetWty();
            }, 5);
        }

        if(this.isRecordIdAvailable == false){
            if(this.parentLwc==true || this.parentLwc=="true"){
                this.showBooking=true;
                this.navigateToCase();
                
            }
           
        }
         
            
    }

    checkAssetWty(){
        this.showSpinner=true;
        debugger;
       
        checkAssetWty({assetId: this.assetId})
        .then(result=>{
            console.log('result asset', result);
            if(result != null){
                console.log('result-->'+JSON.stringify(result));
                console.log('result asset', result);
                console.log('this.pmsAvailable '+ result.PMS_Available__c);
                console.log('this.pmsUsed '+ result.PMS_Used__c);
                this.showSpinner = false;
                
                console.log('this.pmsremaining 1'+ this.pmsremaining);
                
                this.pmsUsed = result.PMS_Used__c;
                this.pmsAvailable = result.PMS_Available__c;
               
                    if(this.pmsAvailable >= this.pmsUsed){
                        
                       
                            console.log('showpms');
                            this.assetId = result.Id;
                            this.accountId = result.AccountId;
                            console.log('this.assetId '+ this.assetId +'this.accountId '+ this.accountId);
                            this.checkWorkOrderPMS();
                            
                        
                       
                    }else{
                        console.log('showpms 11');
                        this.showError=false;
                        this.showToast(' No PMS service is available.','success');
                        if(this.parentLwc==true || this.parentLwc=="true"){
                            this.showBooking=true;
                            this.navigateToCase();
                        }
                       // this.navigateToCase();
                    }
                
                
               
              
              
            }else{
                
                console.log('this.showWtyNotExist', this.showWtyNotExist);
                this.showToast('Asset is not under warranty. No PMS service is available.','success')
                //this.showWtyNotExist= true;
                this.showSpinner = false;
                console.log('this.showWtyNotExist', this.showWtyNotExist);
                if(this.parentLwc==true || this.parentLwc=="true"){
                    this.showBooking=true;
                    this.navigateToCase();
                }
                //this.navigateToCase();
            }
        })
        .catch(error => {
            console.log('error',error);
            var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
            console.log('Error', error.body.message);
            this.disableButton = false;
            this.showSpinner = false;
            this.showToast(errormsg, 'Error');
        })
    }


    
     
   
    updateAsset(){
        console.log('case');
        this.disButton = true;
        console.log('recordId');
        console.log('this.disButton'+this.disButton);
        const fields = {};
        fields['Id'] = this.assetId; //populate it with current record Id
        
        fields['PMS_Used__c']= this.pmsUsed +1;
        fields['PMS_Available__c']= this.pmsAvailable -1;
        
        const recordInput = { fields };

        updateRecord(recordInput)
        .then(() => {

            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated',
                        variant: 'success'
                }))
            console.log('updte case');
            this.disableButton = false;
            //this.navigateToCase();
debugger;
            if(this.parentLwc==true || this.parentLwc=="true"){
                this.showBooking=true;
                this.navigateToCase();
            }
        
       
    }).catch(error => {
        console.log('error Case'+ error.body.message);
             this.dispatchEvent(

                  new ShowToastEvent({
                title: 'Error Updating record',
                message: error.body.message,
                variant: 'error'
                 })
                   );
        });
    }

    checkWorkOrderPMS(){
         console.log('updateworkordr ' + this.assetId + 'acc' + this.accountId);

        checkWorkOrderPMS({assetId: this.assetId, accountId:this.accountId})
        .then(result=>{
            console.log('result asset', result);
            if(result == false){
                 
                 console.log('decline');
                
                console.log('showpms 11');
                        this.showError=false;
                        this.showToast('PMS cannot be avail as there must be atleast 30 days gap between two consecutive PMS','success');
                        if(this.parentLwc==true || this.parentLwc=="true"){
                            this.showBooking=true;
                            this.navigateToCase();
                        }
                        //this.navigateToCase()
               }else{
                console.log('wty exist');
                this.showWtyExist =true;
                                
               }
            }).catch(error=>{

                })

            }

    updateCase(){

            
       console.log('case');
        const fields={};
        fields['Id'] = this.recordId; //populate it with current record Id
        fields['Type'] = 'PMS';
        const recordInput = { fields };

        updateRecord(recordInput)
        .then(() => {

            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated',
                        variant: 'success'
                }))
            console.log('updte case');
            this.disableButton = false;

            this.updateAsset();
        
       
    }).catch(error => {
        console.log('error Case'+ error.body.message);
             this.dispatchEvent(

                  new ShowToastEvent({
                title: 'Error Updating record',
                message: error.body.message,
                variant: 'error'
                 })
                   );
        });
    }

    
    //call the method for creating workorder and tagging the channel partner.
    tagChannelPartner() {
        this.showSpinner=true;
        this.disableButton = true;
        tagChannelPartnerUI({ recordId: this.recordId })
            .then(result => {
                console.log('result channel partner', result);
                this.showToast('Successfully created the service ticket.','success');
                if (result == 'success') {
                    this.showSpinner = false;
                    this.showBooking=true;
                    this.navigateToCase();
                }else{
                    this.showError=true;
                    this.errorMessage=result;
                    this.disableButton = false;
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                console.log('error',error);
                var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                console.log('Error', error.body.message);
                this.disableButton = false;
                this.showSpinner = false;
                this.showToast(errormsg, 'Error');
            });
    }

    
        handleFlowStatusChange(event) {
            // Handle Flow status changes
            if (event.detail.status === 'FINISHED') {
                this.showFlow= false;
                // Flow finished successfully
            } else if (event.detail.status === 'ERROR') {
                // Flow encountered an error
                this.showToast(errormsg, 'Error');
            }
        }

    showToast(message, type) {
        //this.disableButton = true;
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    navigateToCase(){
        this.showSpinner=true;
        console.log('Navigate ');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }

    handleNo(){
        this.disButton=false;
        if(this.parentLwc==true || this.parentLwc=="true"){
            this.showBooking=true;
            this.navigateToCase();
        }else{
            this.showBooking=false;
            this.navigateToCase();
        }
    }

   get isRecordIdAvailable() {

    console.log('cseType'+this.caseType);
        
        return this.assetId !== null && this.assetId !== undefined && this.caseType ==='Regular Service';
    }

    
    

}