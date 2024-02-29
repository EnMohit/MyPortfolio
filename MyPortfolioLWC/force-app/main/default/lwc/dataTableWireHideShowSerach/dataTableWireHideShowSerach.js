import { LightningElement,track, api } from 'lwc';
import getContactList from '@salesforce/apex/ContactList.getContactList';
const columns = [
    {label:"Name", fieldName:"Name"},
    {label:"Phone", fieldName:"Phone"}

]

export default class DataTableWireHideShowSerach extends LightningElement {

    @track buttonLabel="Show Contact";
    @track columns = columns;
    @track data = [];
    @track cardVisible = false;
    @api recordId;
    @track searchValue = '';

    connectedCallback(){
        getContactList({accId:this.recordId})
        .then(result => {
            this.data = result;
            console.log("DATA:"+ JSON.stringify(this.data));
        })
        .catch(error=>{
            console.log("Error:" + error);
        })
    }
    handleChange(event){
        this.searchValue = event.target.value;
        console.log('serachValue:', this.searchValue);
        getContactList({accId:this.recordId, searchKey: this.searchValue })
        .then(result => {
            this.data = result;
            console.log("SERACH-DATA:"+ JSON.stringify(this.data));
        })
        .catch(error=>{
            console.log("Error:" + error);
        })

    }

    handleClick(event){
        const label = event.target.label;
        if(label=="Show Contact"){
            this.buttonLabel = "Hide Contact";
            this.cardVisible = true;
        }else if(label=="Hide Contact"){
            this.buttonLabel = "Show Contact";
            this.cardVisible = false;
        }
    }
    getSelectedRows(event){
        const selectedRowDetails = event.detail.selectedRows;
        window.alert(JSON.stringify(selectedRowDetails));
    }
}