import { LightningElement,track } from 'lwc';
import ContactRecord from '@salesforce/apex/FetchContact.ConRec'
const columns = [
    {label:"Contact Record Id",  fieldName:"Id"},
    {label:"Contact Name", fieldName:"Name"}
]
export default class ContactDataTable extends LightningElement {

    @track data;
    @track columns = columns;
    value;
    connectedCallback(){
        handleClick(){
            ContactRecord(this.value)
            .then(response =>{
                this.data = response;
            });
        }

    }
    handleOnChange(event){
        this.value = event.target.value;
    }



}