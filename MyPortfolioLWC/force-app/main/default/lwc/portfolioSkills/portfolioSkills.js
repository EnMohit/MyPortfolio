import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import TECH_FIELD from '@salesforce/schema/Portfolio__c.TechnicalSkills__c'
import SOFT_FIELD from '@salesforce/schema/Portfolio__c.SoftSkills__c'
import SOFTWARE_FIELD from '@salesforce/schema/Portfolio__c.SoftwareTools__c'
export default class PortfolioSkills extends LightningElement {

    techSkills = [];
    softSkills = [];
    softwareTools = [];


    @api recordId
    @wire(getRecord, {
        recordId:'$recordId',
        fields:[TECH_FIELD,SOFT_FIELD,SOFTWARE_FIELD]
    })skillHandler({data, error}){
        if(data){
            console.log("Skills Data", JSON.stringify(data));
            this.formatedSkills(data);
        }
        if(error){
            console.log("Skill error", error)
        }
    }

    formatedSkills(data){
        const {SoftSkills__c,TechnicalSkills__c,SoftwareTools__c}= data.fields
        this.techSkills = TechnicalSkills__c ? TechnicalSkills__c.value.split(','):[]
        this.softSkills = SoftSkills__c ? SoftSkills__c.value.split(','):[]
        this.softwareTools = SoftwareTools__c ? SoftwareTools__c.value.split(','):[]
    }
}