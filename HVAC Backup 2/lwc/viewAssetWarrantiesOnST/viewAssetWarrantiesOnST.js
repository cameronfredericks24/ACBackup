import { LightningElement,api, wire } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import ASSET_FIELD from '@salesforce/schema/WorkOrder.AssetId';
export default class ViewAssetWarrantiesOnST extends LightningElement {
  error;
  records;
  @api recordId; // This is the Work Order ID passed from the parent component or context
  assetId;
  noRecordFound = false;

  columns = [
    { label: 'ID', fieldName: 'Id' },
    { label: 'Asset Warranty Number', fieldName: 'AssetWarrantyNumber' } // Add more columns as needed
    ];

@wire(getRecord, { recordId: '$recordId', fields: [ASSET_FIELD] })
workOrderRecord({ error, data }) {
        if (data) {
            console.log('data',data);
            this.assetId = data.fields.AssetId.value;
            if(this.assetId==null){
                this.noRecordFound = true;
            }
        } else if (error) {
            console.error('Error fetching Work Order record:', error);
        }
    }


  @wire(getRelatedListRecords, {
    parentRecordId: '$assetId',
    relatedListId: 'WarrantyAssets',
    fields: ['AssetWarranty.Id', 'AssetWarranty.AssetWarrantyNumber', 'AssetWarranty.StartDate', 'AssetWarranty.EndDate', 'AssetWarranty.WarrantyType','AssetWarranty.Warranty_Term_Name__c'],
  })
  listInfo({ error, data }) {
    console.log('here');
    if (data) {
        console.log('data 1',data);
        this.records = data.records.map(record => ({
            Id: record.fields.Id.value,
            AssetWarrantyNumber: record.fields.AssetWarrantyNumber.value,
            StartDate : record.fields.StartDate.value,
            EndDate : record.fields.EndDate.value,
            WarrantyType : record.fields.WarrantyType.value,
            WarrantyTermId : record.fields.Warranty_Term_Name__c.value,
            AssetWarrantyURL : (window.location.href.includes('channelpartnerportal')) ? window.location.origin+'/channelpartnerportal/s/detail/'+record.fields.Id.value: '/lightning/r/AssetWarranty__c/'+record.fields.Id.value+'/view'
        }));
        if(this.records.length==0){
            this.noRecordFound = true;
        }
      this.error = undefined;
    } else if (error) {
        console.log('error',error);
      this.error = error;
      this.records = undefined;
    }
  }
  
}