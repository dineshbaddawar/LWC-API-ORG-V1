public class FetchObjects {
    
    // Method for getting All Sobjects
    @auraEnabled(cacheable=true)
    public static List<String> fetchObjectsInfo(){
        try{
            Map<String,String> objectMap = new Map<String,String>();
            list<string> ListOfSobjects = new list<string>();
            for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
                String name = objTyp.getDescribe().getName();
                String label = objTyp.getDescribe().getLabel();
                if(!name.containsignorecase('history') && !name.containsignorecase('tag') && !name.containsignorecase('SBQQ__') &&
                   !name.containsignorecase('share') && !name.containsignorecase('feed') && 
                   !name.containsignorecase('group') && !name.containsignorecase('public') &&
                   !objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().isCreateable() &&
                   objTyp.getDescribe().getRecordTypeInfos().size() > 0){      
                       objectMap.put(name,label);
                       ListOfSobjects.add(name);
                   }
            }
            System.debug(objectMap);
            if(objectMap != null && objectMap.size() > 0){
                ListOfSobjects.sort(); 
                return ListOfSobjects;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // Method for getting All Fileds by Passing Object Name
    @auraEnabled(cacheable=true)
    public static list<string> fetchFieldsInfo(string obj){
        try{
            list<string> ListOfSobjectFields=new list<string>();
            schema.sobjectType objToken=schema.getGlobalDescribe().get(obj);
            map<string,sobjectField> m=objToken.getdescribe().fields.getMap();
            for(string token:m.keySet()){
                schema.describeFieldResult r=m.get(token).getDescribe();
                ListOfSobjectFields.add(r.getName());
            }
            ListOfSobjectFields.sort();
            return ListOfSobjectFields;
        }catch(Exception e){
            System.debug('The Error '+e.getMessage() + 'Erron Line '+e.getLineNumber()); 
        }
        return null;
    }
    
    // Method for Get Dynamic Query
    @auraEnabled(cacheable=true)
    public static list<sobject> fetchResult(string query){
        try{
            list<sobject> data=new list<sobject>();
            string updatedQuery = query+' Limit 10';
            List<sObject> lstOfRecords = Database.query(updatedQuery);
            if(lstOfRecords !=null){
                return lstOfRecords;   
            }
        }catch(Exception e){
            System.debug('The Error '+e.getMessage() + 'Erron Line '+e.getLineNumber()); 
        }
        return null;
    }
    
}