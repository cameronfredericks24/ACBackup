import { LightningElement, api, track } from 'lwc';
import updateServiceAppointmentLocation from '@salesforce/apex/ServiceAppointmentController.updateServiceAppointmentLocation';

export default class ServiceAppointmentStatus extends LightningElement {
    @api recordId; // Assuming you pass the ServiceAppointment Id from the parent component
    @track status;
    showfaultAction = false;

    statusOptions = [
        { label: 'None', value: 'None' },
        { label: 'Work Started', value: 'Work Started' },
        { label: 'Requested Material', value: 'Requested Material' },
        { label: 'Material Received', value: 'Material Received' },
        { label: 'Completed', value: 'Completed' }
    ];

    handleChangeStatus(event) {
        this.status = event.detail.value;
        if(this.status=='Completed'){
            this.showfaultAction=true;
        }else{
            this.showfaultAction=false;
        }
    }

    updateLocation() {
        if (navigator.geolocation) {
            console.log('Location'+JSON.stringify(navigator.geolocation));
            navigator.geolocation.getCurrentPosition(position => {
                const latitude = position.coords.latitude;
                const longitude = position.coords.longitude;

                const wrapper = {
                    serviceAppointmentId: this.recordId,
                    latitude: latitude,
                    longitude: longitude,
                    status: this.status
                };

                updateServiceAppointmentLocation({ wrapper })
                    .then(result => {
                        // Handle success
                        console.log('Service Appointment updated successfully:', result);
                    })
                    .catch(error => {
                        // Handle error
                        console.error('Error updating Service Appointment:', error);
                    });
            });
        } else {
            // Geolocation is not supported
            console.error('Geolocation is not supported by this browser.');
        }
    }
}