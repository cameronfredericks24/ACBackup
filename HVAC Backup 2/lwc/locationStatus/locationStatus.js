import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getLocationService } from 'lightning/mobileCapabilities';




export default class LocationStatus extends LightningElement {
    locationMessage = '';
    myLocationService;
    @api currentLocation;
    locationButtonDisabled = false;
    requestInProgress = false;
    @api islocationavailable = false;
    @api recordId;
    showSpinner=false;
    locationNotAvailable = false;


    connectedCallback() {
        try {
            console.log('in connected call back')
            this.myLocationService = getLocationService();
            if (this.myLocationService == null || !this.myLocationService.isAvailable()) {
                this.locationButtonDisabled = true;
                this.locationMessage = 'Location is not enabled, please turn on device location';
                                            

                const myEvent = new CustomEvent("nolocationfound");
                this.dispatchEvent(myEvent);
            } else {
                const myEvent = new CustomEvent("submitparent");
                this.dispatchEvent(myEvent);
                //this.handleGetCurrentLocationClick(null);
            }
        }catch(error){
            console.log('error-->'+error.message);
        }
    }

    /*handleGetCurrentLocationClick(event) {
        this.showSpinner=true;
        this.currentLocation = null;

        if (this.myLocationService != null && this.myLocationService.isAvailable()) {
            const locationOptions = {
                enableHighAccuracy: true
            };

            this.requestInProgress = true;

            this.myLocationService
                .getCurrentPosition(locationOptions)
                .then((result) => {
                    this.currentLocation = result;
                    console.log(JSON.stringify(result));
                    this.islocationavailable = true;
                    this.locationNotAvailable=false;
                    this.showSpinner=false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            //title: 'Location Detected',
                            //message: 'Location determined successfully.',
                            //variant: 'success'
                        })
                    );
                   const myEvent = new CustomEvent("submitparent", { detail: this.currentLocation });
                    this.dispatchEvent(myEvent);
                    
                })
                .catch((error) => {
                    console.error(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            //title: 'Location Detected',
                            //message: 'Location is off.',
                            //variant: 'Error'
                        })
                    );
                    const myEvent = new CustomEvent("noLocationFound");
                    this.dispatchEvent(myEvent);
                    this.showSpinner=false;
                    this.locationNotAvailable=true;
                })
                .finally(() => {
                    console.log('#finally');
                    this.requestInProgress = false;
                    this.showSpinner=false;
                });
        } else {
            this.showSpinner=false;
            this.locationNotAvailable=true;
            console.log('Get Location button should be disabled and unclickable. ');
            console.log('Somehow it got clicked: ');
            console.log(event);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'LocationService Is Not Available',
                    message: 'Try again from the Salesforce app on a mobile device.',
                    variant: 'error'
                })
            );
        }

    }

    get currentLocationAsString() {
        return `Lat: ${this.currentLocation.coords.latitude}, Long: ${this.currentLocation.coords.longitude}`;
    }*/

   

    
}