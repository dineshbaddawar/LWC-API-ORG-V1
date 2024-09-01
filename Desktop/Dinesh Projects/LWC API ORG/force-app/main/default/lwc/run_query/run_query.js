import { LightningElement,wire,track } from 'lwc';
import sampleMC from '@salesforce/messageChannel/myMessageChannel__c';
import {subscribe,MessageContext} from 'lightning/messageService';
import fetchResult from '@salesforce/apex/FetchObjects.fetchResult';
import { NavigationMixin } from 'lightning/navigation';
export default class Run_query extends NavigationMixin(LightningElement)  {
    recId;
    numberOfRecord=0;
    actualQuery='';
    isDataLoad=false;
    @track data=[];
    @track cols=[];
    @wire(MessageContext)context;
    connectedCallback(){
        debugger;
        subscribe(this.context,sampleMC,msg=>{
            this.actualQuery=msg.lmsData.data;
            console.log('data is coming'+this.actualQuery);
        });

    }

    @wire(fetchResult,{query:'$actualQuery'})
    dataHandler({ data, error }) {
        if (data) {
            debugger;
            this.numberOfRecord=data.length;
            this.isDataLoad=true;
            this.makeDataTable(data);
        }
        if(error){
            console.log('Error occur');
            console.log(error);
        }
    }

    makeDataTable(rawData) {
        debugger;
        let tempArr=this.actualQuery.split(' ')[1].split(',');
        if(!tempArr.includes('Id'))
            tempArr.push('Id');
        this.cols=[];//initialize the array blank for saftey
        this.data=[];//initialize the array blank for saftey
        tempArr.forEach(item=>{
            this.cols.push({label:item,fieldName:item,type:'text'});
        });
        rawData.forEach(item=>{
            let tempObj={};
            this.cols.forEach(col=>{
                tempObj[col.fieldName]=item[col.fieldName];
            });
            this.data.push(tempObj);
        });
    }

    handleRowSelection(event) {
        debugger;
        this.selectedRows = event.detail.selectedRows;
        console.log('Selected Rows:', this.selectedRows);

        this.recId = this.selectedRows.map(row => row.Id);
        console.log('Selected Record IDs:', this.recId);
        if (this.recId.length != 0) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recId.toString(),
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            });
        }
        
    }
}