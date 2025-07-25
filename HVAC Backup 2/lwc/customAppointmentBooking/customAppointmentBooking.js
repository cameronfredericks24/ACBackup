// appointmentScheduler.js
import { LightningElement, wire,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSAId from '@salesforce/apex/AppointmentService.getSAId';
import getSlots from '@salesforce/apex/AppointmentService.getSlots';
import ScheduleSA from '@salesforce/apex/AppointmentService.ScheduleSA';
import getSAPolicies from '@salesforce/apex/AppointmentService.getSAPolicies';
import assignResource from '@salesforce/apex/AppointmentService.assignResource';
import getCaseRecord from '@salesforce/apex/AppointmentService.getCaseRecord';
import { NavigationMixin } from 'lightning/navigation';


export default class AppointmentScheduler  extends NavigationMixin(LightningElement){
    schedulingPolicies =[
        { label: 'Customer First', value: 'a0cBi00000098ftIAA' },
        { label: 'Customer Satisfaction', value: 'a0cBi0000009GyPIAU' },
        { label: 'Emergency', value: 'a0cBi0000009H1dIAE' },
        { label: 'High Intensity', value: 'a0cBi0000009H3FIAU' },
        { label: 'Soft Boundaries', value: 'a0cBi0000009H4rIAE' }
    ];
    //schedulingPolicies =[];
    selectedPolicy;
    startDateTime;
    endDateTime;
    @track dateSlots = [];
    @api recordId;
    showSpinner=false;
    slots = [];
    saId;
    showSlots=false;
    showError = false;
    returnWrapper = {};

    connectedCallback() {
        console.log('recordId',this.recordId);
        this.getSAPoliciesMethod();      
    }

    processSlots(slots) {
        debugger;
        let slotsByDate = {};
        slots.forEach(slot => {
            if (!slotsByDate[slot.date]) {
                slotsByDate[slot.date] = [];
            }
            slotsByDate[slot.date].push(slot.time);
        });

        this.dateSlots = Object.keys(slotsByDate).map(date => ({
            date: date,
            slots: slotsByDate[date]
        }));
        this.showSpinner=false;
    }

    handleSlotSelection(event) {
        const slotValue = event.target.value;
        // Handle slot selection
    }

    handlePolicyChange(event) {
        this.selectedPolicy = event.detail.value;
        // Handle policy change
    }

    handleStartDateTimeChange(event) {
        this.startDateTime = event.target.value;
        // Handle start date time change
    }

    handleEndDateTimeChange(event) {
        this.endDateTime = event.target.value;
        // Handle end date time change
    }

    handleAppointment(){
        debugger;
        var valid = true;
        if(this.startDateTime==null || this.startDateTime==undefined || this.startDateTime==''){
            valid=false;
        }
        if(this.endDateTime==null || this.endDateTime==undefined || this.endDateTime==''){
            valid=false;
        }
        if(this.selectedPolicy==null || this.selectedPolicy==undefined || this.selectedPolicy==''){
            valid=false;
        }

        if(valid){
            this.showSpinner=true;
            var jsWrapper = {};
            jsWrapper.startDate = this.startDateTime;
            jsWrapper.EndDate = this.endDateTime;
            jsWrapper.caseId = this.recordId;
            jsWrapper.schPolicyId = this.selectedPolicy;

            getSAId( {requestWrapperString : JSON.stringify(jsWrapper)})
            .then(result => {
                debugger;
                this.returnWrapper = result;
                if(result!=null && result.saId!=undefined && result.saId!=null){
                    this.saId = result.saId;
                    this.getSlotsMethod();
                }else if(result.error!=null && result.error!='' && result.error!=undefined){
                    this.showToast(result.error,'Error');
                    this.showSpinner=false;
                }
                else{
                    this.showToast('Error retrieving slots','Error');
                    this.showSpinner=false;
                }
            })
            .catch(error => {
                console.error('Error retrieving slots:', error);
                this.showToast(error,'Error');
                this.showSpinner=false;
            });
        }else{
            this.showToast('Please enter the required fields.','Error');
        }
        
    }

    getSlotsMethod(){
        getSlots( {saId : this.saId, schId : this.selectedPolicy})
            .then(result => {
                debugger;
                result.forEach(record => {
                    var s = {};
                    s.date = record.dateString;
                    s.time = record.timeString;
                    s.startDate = record.startdateTime;
                    s.endDate = record.endDateTime;
                    this.slots.push(s);                 
                });
                if(this.slots.length>0){
                    this.showSlots=true;
                    this.showError = false;
                }

                this.processSlots(this.slots);
            })
            .catch(error => {
                console.error('Error retrieving slots:', error);
                this.showToast(error,'Error');
                this.showSpinner=false;
            });
    }

    handleSlotSelection(event){
        var dateVar = event.target.getAttribute('name');
        var timeVar = event.target.value;
        var startdatetimevar;
        var enddatetimevar;
        this.slots.forEach(record => {
            if(record.date==dateVar && record.time==timeVar){
                startdatetimevar = record.startDate
                enddatetimevar = record.endDate;
            }              
        });


        this.showSpinner=true;
        ScheduleSA( {dateString : startdatetimevar, timeString : enddatetimevar, requestWrapperString : JSON.stringify(this.returnWrapper)})
            .then(result => {
                debugger;
                if(result=='success'){
                    if(this.returnWrapper.autoassignResource){
                        this.assignResourceMethod();
                    }else{
                        this.showToast('Successfully Scheduled','Success');
                        this.showSpinner=false;
                        this.navigateToCase();
                    }                   
                }else{
                    this.showToast('There is something wrong, appointment could not be scheduled.','Error');
                    this.showSpinner=false;
                }
            })
            .catch(error => {
                console.error('Error while scheduling', error);
                this.showToast(error,'Error');
                this.showSpinner=false;
            });
    }

    showToast(message, type) {
        this.disableButton = true;
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    getSAPoliciesMethod(){
        this.showSpinner=true;
        //this.schedulingPoliciesVar=[];
        getSAPolicies()
            .then(result => {
                debugger;
                result.forEach(record => {
                    debugger;
                    var option = {
                        label: record.Name,
                        value: record.Id
                    };
                    this.schedulingPolicies.push(option);
                    if(record.Name == 'Customer Satisfaction'){
                        this.selectedPolicy = record.Id;
                    }              
                });


                console.log('schedulingPolicies',this.schedulingPolicies);

                this.showSpinner=false;
                console.log('recordId',this.recordId);
                this.getCaseRecordMethod(); 
            })
            .catch(error => {
                console.error('Error retrieving schedule policies:', error);
                this.showToast(error,'Error');
                this.showSpinner=false;
            });
    }

    getCaseRecordMethod(){
        this.showSpinner=true;
        getCaseRecord({recordId : this.recordId})
            .then(result => {
                debugger;
                this.startDateTime = result.Preferred_Slot_Start_Time__c;
                this.endDateTime = result.Preferred_Slot_End_Time__c;
                this.showSpinner=false;
                
            })
            .catch(error => {
                console.error('Error retrieving schedule policies:', error);
                this.showSpinner=false;
            });
    }

    assignResourceMethod(){
        assignResource( {requestWrapperString : JSON.stringify(this.returnWrapper)})
            .then(result => {
                debugger;
                if(result=='success'){
                    this.showToast('Successfully Scheduled','Success');
                    this.showSpinner=false;
                    this.navigateToCase();
                }else{
                    this.showToast('There is something wrong, appointment could not be scheduled.','Error');
                    this.showSpinner=false;
                }
            })
            .catch(error => {
                console.error('Error while scheduling', error);
                this.showToast(error,'Error');
                this.showSpinner=false;
            });
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

}