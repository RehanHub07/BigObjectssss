import { LightningElement } from 'lwc';

export default class ConfigurationBigObjectHome extends LightningElement {


    data=[];

    columns = [
        { label: 'Configuration Number', fieldName: 'Name', sortable: true },
        { label: 'Source Object', fieldName: 'Source_Object_Name__c', sortable: true},
        { label: 'Big Object Name', fieldName: 'Big_Object_Name__c', sortable: true },
        { label: 'Total Fields Backed Up', fieldName: 'TotalBackUpCount', sortable: true ,type:'number'},
        { label: 'List View Name', fieldName: 'List_View_Name__c', sortable: true ,editable: true },
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
}