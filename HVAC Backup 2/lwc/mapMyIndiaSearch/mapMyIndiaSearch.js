import { LightningElement, track, api } from 'lwc';
import searchPlaces from '@salesforce/apex/MapMyIndiaSearchController.searchPlaces';
import createCase from '@salesforce/apex/MapMyIndiaSearchController.createCase';



export default class MapMyIndiaSearch extends LightningElement {

    @track placeSearch;
    @track placeAddresses = [];
    @track showResults = false;
    @api iconName = 'standard:address';
    @track locationSelected = false;
    @track inputClass = 'field-container';
    @api searchPlaceholder = 'Search';

    @track placeArray = [];
    @track selectedAddress;

    @track pincode;
    @track state;
    @track city;
    @track street;


    handleChange(event) {
        this.placeSearch = event.target.value;
        console.log(this.placeSearch);
        searchPlaces({ query: this.placeSearch })
            .then(result => {
                // console.log(result);
                this.placeAddresses = result;
                // console.log(this.placeAddresses);

                // Prepare a map with placeName as key and placeAddress as value
                let placeMap = {};
                this.placeAddresses.forEach(location => {
                    placeMap[location.placeName] = location.placeAddress;
                });

                // console.log(placeMap);

                // Convert the placeMap object into an array of objects
                this.placeArray = Object.keys(placeMap).map(key => ({ placeName: key, placeAddress: placeMap[key] }));

                console.log(this.placeArray);

                this.showResults = true;

            })
            .catch(error => {
                console.error('Error fetching place addresses', error);
            });
    }

    handleSelection(event) {
        this.placeSearch =  event.currentTarget.dataset.id;
        this.showResults = false;

        this.selectedAddress = event.currentTarget.dataset.address;

        // Split the address string by commas
        let addressComponents = this.selectedAddress.split(', ');
        
        //pop() removes the last element of the array
        this.pincode = addressComponents.pop();
        this.state = addressComponents.pop(); 
        this.city = addressComponents.pop(); 
        this.street = addressComponents.join(', '); 

        this.locationSelected = true;

        
        console.log('Street:', this.street);
        console.log('City:', this.city);
        console.log('State:', this.state);
        console.log('Pincode:', this.pincode);

        this.street = this.placeSearch + ', ' +  this.street;


          // Call the Apex method to create a case
            createCase({ street: this.street, city: this.city, state: this.state, pincode: this.pincode })
            .then(result => {
                console.log(result);
                console.log('Case created successfully');
                // You can perform further actions if needed
            })
            .catch(error => {
                console.error('Error creating case', error);
            });
    }

    handleRemovePill(event) {
        this.locationSelected = false;
        this.showResults = false;

        this.placeSearch = '';
        this.pincode = '';
        this.state = ''; 
        this.city = ''; 
        this.street = ''; 


        console.log('this.locationSelecte:', this.locationSelected);

   
    }

}