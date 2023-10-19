public with sharing class QueryEngine {


    public static void  generateRelatedListQuery(String archivalConfigId){
        Archival_And_Big_Object_Link__c link=[SELECT id,Archival_Configuration__r.Related_List_Query__c,Archival_Configuration__r.Related_Index_Field_API_Name__c,Archival_Configuration__c,Big_Object_Configuration__c 
        FROM Archival_And_Big_Object_Link__c WHERE Archival_Configuration__c=:archivalConfigId];
        System.debug('link '+link);
        Big_Object_Configuration__c bigObject=[SELECT id,Big_Object_API_Name__c,
        (SELECT id,Big_Object_Field_API_Name__c,Source_Object_Field_API_Name__c 
        FROM Big_Object_Field_Configurations__r WHERE Related_List_View__c=true OR Source_Object_Field_API_Name__c=:link.Archival_Configuration__r.Related_Index_Field_API_Name__c) 
        FROM Big_Object_Configuration__c WHERE id=:link.Big_Object_Configuration__c];

        System.debug('bigObject '+bigObject);
        String query='SELECT ';
        String whereCondition=' FROM '+bigObject.Big_Object_API_Name__c+' WHERE ';
        for(Big_Object_Field_Configuration__c field:bigObject.Big_Object_Field_Configurations__r){
            if(field.Source_Object_Field_API_Name__c==link.Archival_Configuration__r.Related_Index_Field_API_Name__c){
                whereCondition+=field.Big_Object_Field_API_Name__c+'=:RELATED_INDEX_ID ';
            }
            else{
                query+=field.Big_Object_Field_API_Name__c+',';
            }
            
        }
        query.removeEnd(',');
        Archival_Configuration__c config=new Archival_Configuration__c();
        config.id=archivalConfigId;

        config.Related_List_Query__c=query+whereCondition;

        update config;



    }

}