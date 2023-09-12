import { LightningElement, api } from 'lwc';
const action = [
     { label: 'View', fieldName: 'View' },
]
 const columnsList = [
        { label: 'Contact Name', fieldName: 'name' },
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'phone' },
        {
            type :'action',
            typeAttributes:{rowActions:action}
        }
    ];
export default class CustomRelatedLists extends LightningElement {
    @api relatedListType = 'Basic List';
    // Calculate conditions and store them in variables
    get isTile() {
        return this.relatedListType === 'Tile';
    }
    get isBasicList() {
        return this.relatedListType === 'Basic List';
    }
    get isEnhancedList() {
        return this.relatedListType === 'Enhanced List';
    }
    columns=columnsList;
 dataList = [
        {
            name: 'John Doe',
            email: 'joshn.doe@example.com',
            phone: '123-456-7890'
        },
        {
            name: 'Smith',
            email: 'smith.smith@example.com',
            phone: '987-654-3210'
        },
        {
            name: 'HARY',
            email: 'Harry.smith@example.com',
            phone: '987-654-3210'
        },
        {
            name: 'Faizz',
            email: 'Faizz.smith@example.com',
            phone: '987-654-3210'
        },
        {
            name: 'MARY',
            email: 'mary.smith@example.com',
            phone: '987-654-3210'
        },
        
    ];

}