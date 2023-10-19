public with sharing class ConfigurationHomeController {

    @AuraEnabled
    public static void deleteArchiveAndBigObjectConfig(string archiveConfigId){
        List<Archival_Configuration__c> archive=[SELECT id,Related_List_Name__c,CreatedDate,Name,Parent_Object_API_Name__c,Parent_Object_Name__c,Related_Index_Field_API_Name__c,Related_Object_API_Name__c,Related_Object_Name__c,(SELECT id,Big_Object_Name__c,Big_Object_Configuration__c FROM Archival_And_Big_Object_Links1__r) FROM Archival_Configuration__c WHERE id=:archiveConfigId];
        String bigObjectConfigId='';
        if(archive.size()>0 && archive.get(0).Archival_And_Big_Object_Links1__r.size()>0){
            bigObjectConfigId=archive.get(0).Archival_And_Big_Object_Links1__r[0].Big_Object_Configuration__c;
        }
        List<Big_Object_Configuration__c> big=[SELECT id FROM Big_Object_Configuration__c WHERE id=:bigObjectConfigId];
        if(big.size()>0) delete big;
        if(archive.size()>0) delete archive;
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Archival_Configuration__c> getAllArchivalConfiguration(){
        return [SELECT id,Related_List_Name__c,CreatedDate,Name,Parent_Object_API_Name__c,Parent_Object_Name__c,Related_Index_Field_API_Name__c,Related_Object_API_Name__c,Related_Object_Name__c,(SELECT id,Big_Object_Name__c,Big_Object_Configuration__c FROM Archival_And_Big_Object_Links1__r) FROM Archival_Configuration__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getAllObjects(){
        Map<String,String> apiAndNameMap=new Map<String,String>();
        for(DescribeSObjectResult obj:SDescribeUtility.getAllObjects().values()){
            apiAndNameMap.put(obj.getName(),obj.getLabel());
        }
        return apiAndNameMap;
    }

    @AuraEnabled
    public static void createArchiveConfig(String parentObjectApiName,String childObjectApiName,
    String childObjectRelatedFieldName,
    List<String> childObjectFields){
        Set<String> childIndexFields=new Set<String>();
        childIndexFields.add('Id');
        childIndexFields.add(childObjectRelatedFieldName);
        Archival_Configuration__c config=ConfigurationEngine.createArchiveConfiguration(parentObjectApiName,childObjectApiName,childObjectRelatedFieldName);

        Big_Object_Configuration__c bigObject=ConfigurationEngine.createBigObjectConfiguration(childObjectApiName, childObjectFields, childIndexFields);

        Archival_And_Big_Object_Link__c link=new Archival_And_Big_Object_Link__c();
        link.Archival_Configuration__c=config.id;
        link.Big_Object_Configuration__c=bigObject.id;
        insert link;
    }
}