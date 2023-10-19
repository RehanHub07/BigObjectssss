import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import deleteArchiveAndBigObjectConfig from '@salesforce/apex/ConfigurationHomeController.deleteArchiveAndBigObjectConfig'
import getAllArchivalConfiguration from '@salesforce/apex/ConfigurationHomeController.getAllArchivalConfiguration';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';

import NewArchiveSetup from 'c/configurationNewArchiveSetup';
export default class ConfigurationArchiveConfigHome extends NavigationMixin(LightningElement) {

    data = [];
    originalData

    columns = [
        { label: 'Configuration Number', fieldName: 'Name', sortable: true },
        { label: 'Parent Object Name', fieldName: 'Parent_Object_Name__c', sortable: true },
        { label: 'Related Object Name', fieldName: 'Related_Object_Name__c', sortable: true },
        { label: 'Related Index Field API Name', fieldName: 'Related_Index_Field_API_Name__c', sortable: true },
        { label: 'Linked Big Object', fieldName: 'LinkedBigObjectConfiguration', sortable: true },
        { label: 'Related List Name', fieldName: 'Related_List_Name__c', sortable: true },

        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            },
        },
    ];

    get lineItemCount() {
        return this.data.length;
    }


    @wire(getAllArchivalConfiguration)
    wiredConfigs(result) {
        this.originalData=result;
     
        if (result.data) {
            this.data = result.data.map(a => {
                let obj = { ...a };
                if (a.Archival_And_Big_Object_Links1__r) {
                    obj.LinkedBigObjectConfiguration = a.Archival_And_Big_Object_Links1__r[0]?.Big_Object_Name__c;
                }
                return obj;
            })
        }
        else {
            console.error(result.error);
        }

    }

    onNewArchive() {
        NewArchiveSetup.open()
        .then(()=>{
            refreshApex(this.originalData);
        })
        
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log(row);
        switch (actionName) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Archival_Configuration__c',
                        actionName: 'view'
                    },
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Archival_Configuration__c',
                        actionName: 'edit'
                    },
                });
                refreshApex(this.originalData);
                break;
            case 'delete':
                if(row.LinkedBigObjectConfiguration){

                }
                else{
                    LightningConfirm.open({
                        message: 'This will delete archive and big object configuration.',
                        
                        label: 'Are you sure you want to delete?.',
                        // setting theme would have no effect
                    })
                    .then(selection=>{
                        if(selection){
                            deleteArchiveAndBigObjectConfig({
                                archiveConfigId:row.Id
                            })
                            .then(()=>{
                                refreshApex(this.originalData);
                            })
                            .catch(error=>console.error(error));
                        }
                    })
                }
                break;
            default:
        }
    }
}