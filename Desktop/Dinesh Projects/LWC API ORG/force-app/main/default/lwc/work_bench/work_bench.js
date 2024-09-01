import { LightningElement,track,wire,api } from 'lwc';
import fetchObjectsInfo from '@salesforce/apex/FetchObjects.fetchObjectsInfo';
import fetchFieldsInfo from '@salesforce/apex/FetchObjects.fetchFieldsInfo';
import sampleMC from '@salesforce/messageChannel/myMessageChannel__c';
import {publish,MessageContext} from 'lightning/messageService';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import workbench from '@salesforce/resourceUrl/workbench';
export default class Work_bench extends LightningElement {
    workbench = workbench;
    @wire(MessageContext)context;
    @track options=[];
    @track fieldsOption=[];
    @track filterOptions=[
        {label:'=',value:'='},
        {label:'<=',value:'<='},
        {label:'<',value:'<'},
        {label:'>=',value:'>='},
        {label:'<>',value:'<>'},
        {label:'in',value:'in'},
        {label:'not in',value:'not in'},
        {label:'like',value:'like'}
    ];
    loadingObjectFlag=false;
    choosedObject;
    choosedFields;
    choosedFilterField;
    choosedOperatorField;
    choosedValueField;
    actualQuery = '';
    // @api RunResult;


    @track error;
    @track userId = Id;
    @track currentUserName;


    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD ]}) 
    currentUserInfo({error, data}) {
        debugger;
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error ;
        }
    }
    
    @wire(fetchObjectsInfo)
    handler({ data, error }) {
        debugger;
        if (data) {
            debugger;
            data.forEach(item=>{
                this.options.push({label:item,value:item});
            });
            this.loadingObjectFlag=true;
        }
        if(error){
            console.log(error);
        }
    }

    optionHandler() {
        debugger;
        this.choosedObject=this.template.querySelector('.c1').value;
        //console.log(this.choosedObject);
        //if you change the object then make the query blank
        this.actualQuery='';
        this.template.querySelector('.c6').value=this.actualQuery;
        //fetching the fields of the selected object
        fetchFieldsInfo({obj:this.choosedObject}).then(data=>{
            //console.log(JSON.stringify(data));
            this.fieldsOption=[];//each time if you change the object then initialize the blank array
            data.forEach(item=>{
                this.fieldsOption.push({label:item,value:item});
            });
        }).catch(error=>{
            console.log(error);
        })
    }

    fieldsHandler() {
        debugger;
        this.choosedFields=this.template.querySelector('.c2').value;
        
        this.actualQuery='';//initialize the string as blank to make a new query if you change the fields
        this.actualQuery+='Select ';
        this.choosedFields.forEach(item=>{
            this.actualQuery+=`${item},`;
        })
        //this is use to remove the last , from the query
        this.actualQuery=this.actualQuery.slice(0,this.actualQuery.length-1);
        this.actualQuery+=` from ${this.choosedObject}`;
        this.template.querySelector('.c6').value=this.actualQuery;
    }

    filterFieldHandler() {
        debugger;
        this.choosedFilterField=this.template.querySelector('.c3').value;
    }

    filterOperatorHandler() {
        debugger;;
        this.choosedOperatorField=this.template.querySelector('.c4').value;
    }

    filterValueHandler() {
        debugger;
        this.choosedValueField=this.template.querySelector('.c5').value;
    }

    filterHandler() {
        debugger;
        if(!this.actualQuery.includes('where')){
            this.actualQuery+=` where ${this.choosedFilterField} ${this.choosedOperatorField} ${this.choosedValueField}`;
            console.log('If Condition == >'+this.actualQuery);
        }
        else{
            this.actualQuery+=` and ${this.choosedFilterField} ${this.choosedOperatorField} ${this.choosedValueField}`;
            console.log('Else Condition == >'+this.actualQuery);
        }
        this.template.querySelector('.c6').value=this.actualQuery;
        console.log('Final Query === >' + this.template.querySelector('.c6').value);
        if (this.actualQuery.includes("=")) {
            this.actualQuery = this.actualQuery.replace(/= (.+)/g, "= '$1'");
        }
        if (this.actualQuery.includes("like")) {
            this.actualQuery = this.actualQuery.replace(/like (\w+)/g, "like '$1%'");
        }
        var finalQuery = this.actualQuery;
    }

    runQueryHandler(){
        debugger;
        let dataToSend = 'SUCCESS';
        console.log('Console 1 == >'+this.actualQuery);
        console.log('console 2 == >'+typeof(this.actualQuery));
        publish(this.context, sampleMC, { lmsData: { data: this.actualQuery } });
        debugger;
        const sendDataEvent = new CustomEvent('senddata', {
            detail: {dataToSend}
        });
        this.dispatchEvent(sendDataEvent);
        
    }
}