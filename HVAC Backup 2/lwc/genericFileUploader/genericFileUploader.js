import { LightningElement, api, track } from 'lwc';
import createRecords from '@salesforce/apex/GenericFileUploaderController.createRecords';
import getListOfMapping from '@salesforce/apex/GenericFileUploaderController.getListOfMapping';
//import getHeadersValue from '@salesforce/apex/GenericFileUploaderController.getHeadersValue';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import sampleFile from '@salesforce/resourceUrl/SampleCSV';
import getBulkUploadJobWrapper from '@salesforce/apex/GenericFileUploaderController.getBulkUploadJobWrapper';



export default class GenericFileUploader extends LightningElement {
    fileData;
    @api
    myRecordId;


    @api processName;  // will be define in the XML side on base of that Process will be Choosen 
    csvMapping;
    csvHeader;
    @track fieldMissing = [];
    @track requiredFields = [];
    @track fieldMissingBoolean
    @track showBtn
    @track allHeadersFields = [];
    @track mapOfColumnAndField;
    @track mapOfFieldAndDataType;
    apexClassName
    apexMethodName
    arrayOfChild
    @track sizeLimit;
    sizeLimitPage = false
    @track fileRows
    @track csvData = null;
    @track noRecordPage = false;

    @track uploadingMessage;
    @track uploadResult;
    @track bulkUploadJobList;
    @track loading = true
    @track OffLimitNumber = 0;
    @track disablePrevious;
    @track disableNext;
    jobQueued = false;
    ticketCreation = false;
    showSuccMsg = false;
    requiredFieldticket=false;

    get acceptedFormats() {
        return ['.csv','.xls','.xlsx'];
    }


    connectedCallback() {
        //  this.sampleFile=sampleFile;

        // this.objectName=objectName;
        console.log(this.processName);
        if(this.processName == 'Ticket Creation'){
            this.requiredFieldticket = true;
        }else{
            this.requiredFieldticket=false;
        }

        getListOfMapping({ 'processName': this.processName }).then(result => {
            console.log(result);
            var map = new Map();
            var map2 = new Map();
            this.csvMapping = result;
            this.arrayOfChild = this.csvMapping[0].CSV_Uploading_Mappings__r
            this.apexClassName = this.csvMapping[0].Apex_Class_Name__c;
            this.apexMethodName = this.csvMapping[0].Apex_Method_Name__c
            this.sizeLimit = this.csvMapping[0].Size__c;


            this.csvMapping[0].CSV_Uploading_Mappings__r.forEach((ele, index) => {
                console.log(ele);


                if (ele.Is_Required__c === true) {
                    console.log('see--->  ' + ele.Column_Name__c);
                    this.requiredFields.push(ele.Column_Name__c);
                }

                this.allHeadersFields.push(ele.Column_Name__c);
                map.set(ele.Column_Name__c, ele.Field_API_Name__c);
                map2.set(ele.Field_API_Name__c, ele.Field_Type__c);

            })
            this.csvMapping[0].CSV_Uploading_Mappings__r.forEach((ele, index) => {

                if (index === 0) {
                    this.allHeadersFields.push('\n' + ele.Value__c);
                } else {
                    this.allHeadersFields.push(ele.Value__c);
                }

            })

            this.mapOfColumnAndField = map;
            this.mapOfFieldAndDataType = map2
            getBulkUploadJobWrapper({ 'Type': this.processName, 'OffLimitNumber': this.OffLimitNumber }).then(result => {
                console.log(result);
                this.bulkUploadJobList = result;
                this.loading = false;
                this.disablePrevious = true;

                if (this.bulkUploadJobList.length < 10) {
                    this.disableNext = true
                } else {
                    this.disableNext = false
                }
            }).catch((error) => {
                console.log('getBulkUploadJobWrapper connectedCallback error....');
                this.error = error;

                console.log('Error is', this.error);

            });

        }).catch((error) => {
            console.log('getListOfMapping connectedCallback error....');
            this.error = error;

            console.log('Error is', this.error);

        });


    }
    previousHandler() {


        if (this.OffLimitNumber >= 10) {
            this.OffLimitNumber = this.OffLimitNumber - 10;
        }
        getBulkUploadJobWrapper({ 'Type': this.processName, 'OffLimitNumber': this.OffLimitNumber }).then(result => {
            console.log(result);
            this.bulkUploadJobList = result;
            this.loading = false;
            if (this.bulkUploadJobList.length <= 0) {
                this.disablePrevious = true;
            } else {
                this.disablePrevious = false;
                this.disableNext = true
            }

            if (this.bulkUploadJobList.length >= 10) {
                this.disableNext = false
            } else {
                this.disableNext = true
            }
            if (this.OffLimitNumber === 0) {
                this.disablePrevious = true;
            }
        }).catch((error) => {
            console.log('getBulkUploadJobWrapper connectedCallback error....');
            this.error = error;

            console.log('Error is', this.error);

        });

        console.log('chek' + this.OffLimitNumber);
        // if(this.OffLimitNumber === 0){
        //     getBulkUploadJobWrapper({'Type':this.processName,'OffLimitNumber':0}).then(result=>{
        //         console.log(result);
        //         this.bulkUploadJobList=result;
        //         this.loading=false;
        //         if(this.bulkUploadJobList.length>0){
        //             this.disablePrevious=true;
        //         }else{
        //             this.disablePrevious=false;
        //             this.disableNext=true
        //         }

        //         if(this.bulkUploadJobList.length >10){
        //             this.disableNext=false
        //         }else{
        //             this.disableNext=true
        //         }
        //     }).catch((error) => {
        //         console.log('getBulkUploadJobWrapper connectedCallback error....');
        //         this.error = error;

        //         console.log('Error is', this.error);

        //     });
        //     this.disablePrevious=true; 
        //     console.log( 'if--->'+this.OffLimitNumber);
        // }else{


        //     console.log( 'else --->'+this.OffLimitNumber);
        //     getBulkUploadJobWrapper({'Type':this.processName,'OffLimitNumber':OffLimitNumber}).then(result=>{
        //         console.log(result);
        //         this.bulkUploadJobList=result;
        //         this.loading=false;
        //         if(this.bulkUploadJobList.length>0){
        //             this.disablePrevious=true;
        //         }else{
        //             this.disablePrevious=false;
        //             this.disableNext=true
        //         }

        //         if(this.bulkUploadJobList.length >10){
        //             this.disableNext=false
        //         }else{
        //             this.disableNext=true
        //         }
        //     }).catch((error) => {
        //         console.log('getBulkUploadJobWrapper connectedCallback error....');
        //         this.error = error;

        //         console.log('Error is', this.error);

        //     });
        // }



    }
    nextHandler() {
        this.OffLimitNumber = this.OffLimitNumber + 10;

        getBulkUploadJobWrapper({ 'Type': this.processName, 'OffLimitNumber': this.OffLimitNumber }).then(result => {
            console.log(result);
            this.bulkUploadJobList = result;
            this.loading = false;

            if (this.bulkUploadJobList.length < 10) {
                this.disablePrevious = false;
                this.disableNext = true
            } else {
                this.disablePrevious = false;
                this.disableNext = false
            }


        }).catch((error) => {
            console.log('getBulkUploadJobWrapper connectedCallback error....');
            this.error = error;

            console.log('Error is', this.error);

        });
    }
    // handleUploadFinished(event) {
    //     // Get the list of uploaded files
    //     const uploadedFiles = event.detail.files;
    //     console.log(JSON.stringify(uploadedFiles));
    //     alert('No. of files uploaded : ' + uploadedFiles.length);
    // }
    generateCSV() {

        // let csvContent = "data:text/csv;charset=utf-8,";
        // // Adding headers
        // csvContent +=this.allHeadersFields.join(",") + "\n";
        // // Adding values
        // csvContent +=  this.allHeadersFields.forEach(ele1=>{
        //     if(ele1.includes('Date'))[
        //         ele1=ele1+'\n2024-01-18'
        //     ]
        // })

        //    this.allHeadersFields.forEach(ele1=>{
        //             if(ele1.includes('Date'))[
        //                 ele1=ele1+'\n2024-01-18'
        //             ]
        //         })
        const element = 'data:application/csv,' + encodeURIComponent(this.allHeadersFields);
        const downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'sampleFile.csv'; // You can change the file name here
        this.template.querySelector('div').appendChild(downloadElement);

        downloadElement.click();
    }
    //to handle File Uploading data we are using this function 
    handleFileUpload(event) {

        try {
            this.fieldMissingBoolean = false;
            this.uploadingMessage = false;
            this.fieldMissing = []
            const file = event.target.files[0];


            if (file) {
                const reader = new FileReader();
                reader.onload = () => {
                    this.csvData = reader.result;
                };
                reader.readAsText(file);

            }
            console.log('ok--->' + JSON.stringify(file));
            if (file) {
                this.readFile(file);
            }
        } catch (error) {
            console.log(error);
        }

    }

    // readFile(file) {
    //     const reader = new FileReader();
    //     reader.onload = () => {
    //         this.fileData = reader.result;
    //     };
    //     reader.readAsText(file);
    //     var string = reader.readAsText(file)
    //     console.log(string);
    //     const rows = file.text().split('\n');
    //     const header = rows[0].split(',');
    //     console.log(rows);
    //     console.log(header);
    //   // console.log('reader-->'+ reader.readAsText(file));
    //     console.log(this.fileData);
    // }

    readFile(file) {
        const reader = new FileReader();

        reader.onload = (e) => {

            this.fileData = reader.result;

            if (this.csvData) {
                const rows = this.csvData.split('\n');
                console.log(rows[0]);
                this.csvHeader = rows[0];
                this.fieldMissing = this.requiredFields.filter(element => !this.csvHeader.includes(element));
                // console.log(this.csvHeader.filter(element => !this.requiredFields.includes(element)));
                // console.log(arr);
                console.log(this.fieldMissing);
                this.fileRows = rows.length;
                this.noRecordPage = false;
                if (this.fieldMissing.length > 0) {
                    this.fieldMissingBoolean = true
                    this.fileData = null;
                    this.showBtn = false
                } else {
                    if (this.fileRows > this.sizeLimit) {
                        this.showBtn = false;
                        this.sizeLimitPage = true;
                    } else {
                        if (this.fileRows <= 1) {
                            this.showBtn = false
                            this.noRecordPage = true;
                        } else {
                            this.showBtn = true
                            this.sizeLimitPage = false;
                            this.noRecordPage = false;
                        }
                    }
                }
                const rowCount = rows.length;


                // Now you can use the rowCount variable as needed
                console.log('Number of rows in CSV file:', rowCount);
            } else {
                console.error('No CSV file selected');
            }


        };

        reader.readAsText(file);



    }


    //for creating  Records we are using this function 
    handleCreateRecords() {
        console.log(this.mapOfColumnAndField);
        console.log(this.mapOfFieldAndDataType);
        this.loading = true;
        createRecords({ 'data': this.fileData, 'arraychildMap': this.arrayOfChild, 'apexClassName': this.apexClassName, 'apexMethodName': this.apexMethodName }).then(result => {

            console.log('result--'+ result);

            if(result == null || result === undefined || result === ''){
                console.log('result ifff--'+ result);

            const errorEvent = new ShowToastEvent({
                title: '',
                message: 'Required fields are missing, please add them to proceed',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(errorEvent);


                this.fileData = null;
                this.showBtn = false;
                this.loading = false;
            }
            else{

                debugger;
            if(result.length == 0){
                this.jobQueued = true;

            }else{
                this.jobQueued = false;
            }
            if(this.jobQueued == false && this.processName == 'Ticket Creation'){
                this.ticketCreation = true;
            }else if(this.jobQueued == false){
                this.showSuccMsg = true;
                this.ticketCreation = false;
                this.jobQueued = false;
            }

            this.uploadResult = result

            // console.log(csvContent);
            // let Newheader=csvContent.split('\n')[0]
            // console.log(Newheader);
            this.uploadingMessage = true;

            const event = new ShowToastEvent({
                title: '',
                message: 'Your File is uploaded Succesfully and it will be download automatically to see success and failure Records',
                variant: 'success',
                mode: 'dismissable'
            });
            if(this.showSuccMsg){
                this.dispatchEvent(event);
            }
           
            this.fileData = null;
            this.showBtn = false;
            this.loading = false;

            }
            
        }).catch((error) => {
            console.log('Creation error....');
            this.error = error;

            console.log('Error is', this.error);
            const event = new ShowToastEvent({
                title: 'Some Error has occured. Please contact admin.',
                message: this.error,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.showBtn = false;
            this.loading = false;
            this.showSuccMsg = false;
                this.ticketCreation = false;
                this.jobQueued = false;
        });

    }


    getUploadData() {
        // Get column headers
        const headers = Object.keys(this.uploadResult[0]);

        // Create CSV content
        let csvContent = headers.join(',') + '\n';

        // Add data rows
        this.uploadResult.forEach(row => {
            const values = headers.map(header => row[header]);
            csvContent += values.join(',') + '\n';
        });
        const element = 'data:application/csv,' + encodeURIComponent(csvContent);
        const downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'uploadingFile.csv'; // You can change the file name here
        this.template.querySelector('div').appendChild(downloadElement);

        downloadElement.click();

    }


    getUploadData2(e) {

        console.log(e.target.dataset.title);
        const element = 'data:application/csv,' + encodeURIComponent(e.target.dataset.title);
        const downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = e.target.dataset.name + 'UploadingFile.csv'; // You can change the file name here
        this.template.querySelector('div').appendChild(downloadElement);

        downloadElement.click();

    }


}