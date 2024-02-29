import { LightningElement, wire, api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import AWARDS from '@salesforce/schema/Portfolio__c.Awards__c';
import SUPERBADGES from '@salesforce/schema/Portfolio__c.Superbadges__c';
import LANGUAGES from '@salesforce/schema/Portfolio__c.Languages__c';
import PortfolioAssets from '@salesforce/resourceUrl/PortfolioAssets';


export default class PortfolioOtherDetails extends LightningElement {

    @api recordId;

    awards=[];
    superbadges=[];
    languages=[];


    trophyICON = `${PortfolioAssets}/PortfolioAssets/trophy.png`
    languageICON = `${PortfolioAssets}/PortfolioAssets/language.png`
    badgeICON = `${PortfolioAssets}/PortfolioAssets/badge.png`

    @wire(getRecord, {
        recordId:'$recordId',
        fields:[AWARDS,SUPERBADGES,LANGUAGES]
    })otherHandler({data, error}){
        if(data){
            console.log("Other Details=>",  JSON.stringify(data));
            this.formatData(data);
        }
        if(error){
            console.error("error",error);
        }
    }
    formatData(data){
        const{Awards__c,Superbadges__c,Languages__c}=data.fields;
        this.awards= Awards__c && Awards__c.value ? Awards__c.value.split(','):[]
        this.superbadges = Superbadges__c && Superbadges__c.value ? Superbadges__c.value.split(';').map(item=>{
            return `SuperBadges ${item}`
        }):[];
        this.languages= Languages__c &&  Languages__c.value ? Languages__c.value.split(','):[]

    }
}