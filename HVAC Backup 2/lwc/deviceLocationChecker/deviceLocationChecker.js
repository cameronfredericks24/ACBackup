import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent
export default class DeviceLocationChecker extends LightningElement {
    @api prop1;
    @api prop3;
    @api prop2;   
    connectedCallback() {
        if ("geolocation" in navigator) {
            const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: "is Opened.",
                   variant: 'success'
                });
                this.dispatchEvent(toastEvent);
            navigator.geolocation.getCurrentPosition(
                position => {
                    const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: "Location is enabled.",
                   variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                    console.log("Location is enabled.");
                },
                error => {
                    console.log("Location is disabled. Prompt user to enable it.");
                    // You can display a prompt to the user here to enable location services
                    const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: "Location is disabled. Prompt user to enable it.",
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                }
            );
        } else {
             const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: "Geolocation is not supported by this browser.",
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            // You can provide an alternate message for browsers that don't support geolocation
        }
    }
}