/* eslint-disable no-prototype-builtins */
import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import LightningAlert from 'lightning/alert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getWorkOrdersByType from '@salesforce/apex/TechnicianDashboardCmpController.getWorkOrdersByType';
import getWorkOrdersByTimeFrame from '@salesforce/apex/TechnicianDashboardCmpController.getWorkOrdersByTimeFrame';
import getTotalWorkOrders from '@salesforce/apex/TechnicianDashboardCmpController.getTotalWorkOrders';
import getWorkTypes from '@salesforce/apex/TechnicianDashboardCmpController.getWorkTypes';
import getTechnicianName from '@salesforce/apex/TechnicianDashboardCmpController.getTechnicianName';


import getTechnicianRating from '@salesforce/apex/TechnicianDashboardCmpController.getTechnicianRating';


export default class TechnicianDashboardCmp extends NavigationMixin(LightningElement) {


    @track timeFrame = 'Today';
    @track ticketType = 'Breakdown';

    @track workOrdersByType;
    @track totalWorkOrders;
    @track technicianName;

    @track filteredData;

    @track showSpinner = true;

    // @track ticketTypeOptions = [];

    @track stars = [];


    @track averageRating;
    @track ratingCount = [];
    @track totalRatings;


    get timeFrameOptions() {
        return [
            { label: 'Today', value: 'Today' },
            { label: 'Last Week', value: 'Last Week' },
            { label: 'Last Month', value: 'Last Month' },
            { label: '3 Months', value: '3 Months' },
            { label: '6 Months', value: '6 Months' },
            { label: 'Last 1 Year', value: 'Last 1 Year' }
        ];
    }

    // eslint-disable-next-line no-dupe-class-members
    get ticketTypeOptions() {
        return [
            { label: 'Installation', value: 'Installation' },
            { label: 'Breakdown', value: 'Breakdown' },
            { label: 'PMS', value: 'PMS' },
            { label: 'Regular Service', value: 'Regular Service' },
            { label: 'Commissioning', value: 'Commissioning' },
            { label: 'Demo', value: 'Demo' },
        ];
    }

    connectedCallback() {

        console.log('inside callback - ');


        this.ticketType = 'Breakdown';
        this.timeFrame = 'Today';

        let starRating = 3.5;
        this.setStars(starRating);


        this.refreshWorkOrders();



    }

    @wire(getTotalWorkOrders)
    wiredTotaltickets({ error, data }) {
        if (data) {
            this.totalWorkOrders = data;

            console.log('totalWorkOrders - ', this.totalWorkOrders);

        } else if (error) {
            console.error('Error : ', error);
        }
    }

    @wire(getTechnicianName)
    wiredtechnicianName({ error, data }) {
        if (data) {
            this.technicianName = data;

            console.log('technicianName - ', this.technicianName);

        } else if (error) {
            console.error('Error : ', error);
        }
    }

    // @wire(getWorkTypes)
    // wiredWorkTypes({ error, data }) {
    //     if (data) {
    //         this.ticketTypeOptions = data.map(type => {
    //             return { label: type, value: type };
    //         });
    //     } else if (error) {
    //         console.error('Error fetching work types: ', error);
    //     }
    // }


    // Method to refresh work orders based on the ticket type
    refreshWorkOrders() {
        this.showSpinner = true;

        getWorkOrdersByType({ workTypeName: this.ticketType })
            .then(data => {
                this.workOrdersByType = data;
                console.log(this.workOrdersByType);
                this.updateFilteredData();
                this.showSpinner = false;

            })
            .catch(error => {
                console.error(error);
                this.showSpinner = false;

            });

            this.fetchWorkOrdersByTime();

            this.showSpinner = false;

    }

    // // Call the Apex method to fetch work orders by type
    // @wire(getWorkOrdersByType)
    // wiredWorkOrders({ error, data }) {
    //     if (data) {
    //         this.workOrdersByType = data;
    //         console.log(this.workOrdersByType);
    //         this.updateFilteredData();


    //     } else if (error) {
    //         console.error(error);
    //     }
    // }

    // Method to fetch work orders
    fetchWorkOrdersByTime() {
        getWorkOrdersByTimeFrame({ timeFrame: this.timeFrame })
            .then(result => {
                this.workOrdersByType = result;
                // Call updateFilteredData after fetching work orders
                this.updateFilteredData();
                this.showSpinner = false;
            })
            .catch(error => {
                console.error('Error fetching work orders:', error);
            });
    }

    // fetchTotalWorkOrders() {
    //     getTotalWorkOrders()
    //         .then(result => {
    //             this.totalWorkOrders = result;

    //             console.log('totalWorkOrders - ', this.totalWorkOrders);


    //             LightningAlert.open({
    //                 message: 'count - ' + this.totalWorkOrders,
    //                 theme: 'success', // a red theme intended for error states
    //                 label: 'Status', // this is the header text
    //             });
    //         })
    //         .catch(error => {
    //             console.error('Error fetching total work orders:', error);
    //         });
    // }

    get ratingPercentage() {
        return this.ratingCount.map(count => (count / this.totalRatings) * 100);
    }


    @wire(getTechnicianRating)
    wiredRating({ error, data }) {
        if (data) {

            this.setStars(data);

            // this.averageRating = data.averageRating;
            // this.ratingCount = data.ratingCount;
            // this.totalRatings = data.totalRatings;

            console.log('data - ' + data);

        } else if (error) {
            console.error('Error fetching technician rating: ', error);
        }
    }



    setStars(rating) {
        this.stars = [];
        const fullStarCount = Math.floor(rating);
        console.log('fullStarCount - ', fullStarCount);
        const halfStar = rating % 1 >= 0.5;
        const emptyStarCount = 5 - fullStarCount - (halfStar ? 1 : 0);

        for (let i = 0; i < fullStarCount; i++) {
            this.stars.push({ id: i, class: 'star full' });
        }

        if (halfStar) {
            this.stars.push({ id: fullStarCount, class: 'star half' });
        }

        for (let i = 0; i < emptyStarCount; i++) {
            this.stars.push({ id: fullStarCount + i, class: 'star empty' });
        }

        console.log(this.stars);
    }



    // Method to update filtered data based on the ticket type
    updateFilteredData() {

        this.showSpinner = true;

        console.log('inside method----:');
        console.log('ticketType----:', this.ticketType);



        if (this.workOrdersByType && this.workOrdersByType.hasOwnProperty(this.ticketType)) {
            console.log('Filtered data:', this.workOrdersByType[this.ticketType]);
            // Update the filtered data property
            this.filteredData = this.workOrdersByType[this.ticketType];
        } else {
            console.warn('Ticket type not found in work orders data:', this.ticketType);
            // Clear the filtered data property if ticket type not found
            this.filteredData = {};
        }

        this.showSpinner = false;
    }



    handleTimeFrameChange(event) {
        this.timeFrame = event.detail.value;
        this.fetchWorkOrdersByTime();
    }


    handleTicketTypeChange(event) {
        this.ticketType = event.target.value;
        console.log('selectedTicketType:', this.ticketType);
        this.refreshWorkOrders();

        //this.updateFilteredData();

    }

    // Getter for All value
    get allValue() {
        return this.filteredData && this.filteredData.All ? this.filteredData.All : 0;
    }

    // Getter for Allocated value
    get allocatedValue() {
        return this.filteredData && this.filteredData.Allocated ? this.filteredData.Allocated : 0;
    }

    // Getter for Work Started value
    get workStartedValue() {
        return this.filteredData && this.filteredData['Work Started'] ? this.filteredData['Work Started'] : 0;
    }

    get materialPendingValue() {
        return this.filteredData && this.filteredData['Material Pending'] ? this.filteredData['Material Pending'] : 0;
    }

    handleRefresh(event) {

        this.showSpinner = true;

        this.refreshWorkOrders();

        this.showSpinner = false;

        const toastEvent = new ShowToastEvent({
            title: '',
            message: 'Data sync successful!!',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);

    }


}