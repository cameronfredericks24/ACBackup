import { LightningElement } from 'lwc';
import { getLocationService } from 'lightning/mobileCapabilities';

export default class LocationComponent extends LightningElement {
    locationMessage = '';

    handleGetCurrentLocationClick() {
        const myLocationService = getLocationService();
        if (myLocationService.isAvailable()) {
            this.locationMessage = 'Location is enabled';
            // Perform geolocation operations
        } else {
            this.locationMessage = 'Location is not enabled';
            // LocationService not available
            // Not running in an app with GPS, location APIs, etc.
            // Handle with message, error, beep, and so on
        }
    }
}