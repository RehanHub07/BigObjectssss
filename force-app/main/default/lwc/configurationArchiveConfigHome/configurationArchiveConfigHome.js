import { LightningElement } from 'lwc';


import NewArchiveSetup from 'c/configurationNewArchiveSetup';
export default class ConfigurationArchiveConfigHome extends LightningElement {

    data=[];

    columns = [
        { label: 'Configuration Number', fieldName: 'Name', sortable: true },
        { label: 'Parent Object Name', fieldName: 'Parent_Object_Name__c', sortable: true},
        { label: 'Related Object Name', fieldName: 'Related_Object_Name__c', sortable: true },
        { label: 'Related Index Field API Name', fieldName: 'Related_Index_Field_API_Name__c', sortable: true ,editable: true },
        { label: 'Linked Big Object', fieldName: 'LinkedBigObjectConfiguration', sortable: true },
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

    onNewArchive(){
        NewArchiveSetup.open();
    }

}