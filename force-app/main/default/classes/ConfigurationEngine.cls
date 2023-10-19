public with sharing class ConfigurationEngine {
    public virtual class ConfigurationEngineException extends Exception {}
    
    /* 
     * Desc : Create archival configuration record
     * Param : sourceObjectApiName - Object APi name
     * Param : childObjectApiName - related object api name
     * param : relatedFieldApiName -field name on related object that is refrecened to parent object
    */
    public static Archival_Configuration__c createArchiveConfiguration(String sourceObjectApiName,String childObjectApiName,String relatedFieldApiName){
        DescribeSobjectResult sourceObject=SDescribeUtility.getSobjectType(sourceObjectApiName.trim());
        DescribeSobjectResult childObject=SDescribeUtility.getSobjectType(childObjectApiName.trim());
        Archival_Configuration__c config=new Archival_Configuration__c();
        config.Parent_Object_API_Name__c=sourceObject.getName();
        config.Parent_Object_Name__c=sourceObject.getLabel();
        config.Related_Object_API_Name__c=childObject.getName();
        config.Related_Object_Name__c=childObject.getLabel();
        config.Related_Index_Field_API_Name__c=relatedFieldApiName;
        config.Related_List_Name__c='Archived '+childObject.getLabel();
        insert config;
        return config;
    } 


    /* 
     * Desc : Create Big Object Configuration record based on source object  and api names
     * Param : sourceObjectApiName - Object APi name
     * Param[] : sourceObjectFieldApiName - list of field api names
     * param[] : indexFieldApiNames - list of index fields 
    */
    public static Big_Object_Configuration__c createBigObjectConfiguration(String sourceObjectApiName,
    List<String> sourceObjectFieldApiName,Set<String> indexFieldApiNames){
        DescribeSobjectResult objectDetails=SDescribeUtility.getSobjectType(sourceObjectApiName.trim());
        Map<String,DescribeFieldResult> fieldDetails=SDescribeUtility.getAllObjectFields(objectDetails);
        
        Big_Object_Configuration__c configObj=ConfigurationEngineHelper.generatConfigurationRecrod(objectDetails);
        insert configObj;
       
        List<Big_Object_Field_Configuration__c> toInsertFields=new List<Big_Object_Field_Configuration__c>();
        for(String apiName:sourceObjectFieldApiName){
            apiName=apiName.trim();
            DescribeFieldResult fieldConfig=fieldDetails.get(apiName);
           	//get defination copy for big object
            toInsertFields.add(ConfigurationEngineHelper.generateFieldConfiguration(configObj.Id,configObj.Source_Object_API_Name__c,fieldConfig,indexFieldApiNames));
            
            //get defination copy for refrence field for big object
            if((fieldConfig.getType()==DisplayType.Reference || fieldConfig.getType()==DisplayType.ID ) && !apiName.equalsIgnoreCase('Id')){
                toInsertFields.add(ConfigurationEngineHelper.generateAutomatedFieldConfiguration(configObj.Id,configObj.Source_Object_API_Name__c,fieldConfig,'Id'));
            }
        }
        toInsertFields.add(ConfigurationEngineHelper.generateAutomatedFieldConfiguration(configObj.Id,configObj.Source_Object_API_Name__c,null,'TimeStamp'));
        
        insert toInsertFields;
        return configObj;
    }
    
    
    
    public static void createBigObject(String bigObjectConfigurationId){
        List<String> errorList=new List<String>();
        List<Big_Object_Field_Configuration__c> toUpdateFields=new List<Big_Object_Field_Configuration__c>();
        Big_Object_Configuration__c bigObjectDetails=[SELECT id,Big_Object_API_Name__c,Big_Object_Name__c,Source_Object_API_Name__c,Source_Object_Name__c,
                                                            (SELECT Id,Data_Type__c,Big_Object_Field_API_Name__c,Big_Object_Field_Name__c,Indexed__c,Is_Ascending_Sort__c,Number_Field_Length__c,Related_List_View__c,Source_Data_Type__c,Source_Object_API_Name__c,Source_Object_Field_API_Name__c,Source_Object_Field_Name__c,Text_Field_Length__c,Source__c
                                                             FROM Big_Object_Field_Configurations__r) 
                                                            FROM Big_Object_Configuration__c WHERE id=:bigObjectConfigurationId];
        
        MetadataService.MetadataPort service =ConfigurationEngineHelper.getMetadataConnection();
        
        //define Big Object  
        MetadataService.CustomObject bigObject = ConfigurationEngineHelper.getBigObjectMetadataConfig(bigObjectDetails);
        bigObjectDetails.Big_Object_API_Name__c=bigObject.fullName;
        bigObjectDetails.Big_Object_Name__c=bigObject.label;
        
        
        List<MetadataService.CustomField> lstCustomFields = new List<MetadataService.CustomField>();  
        List<MetadataService.IndexField> lstIndexFields = new List<MetadataService.IndexField>();  
      
        //define fields
        for(Big_Object_Field_Configuration__c fieldConfig:bigObjectDetails.Big_Object_Field_Configurations__r){
            MetadataService.CustomField fieldObj =ConfigurationEngineHelper.getBigObjectFieldMetadataConfig(fieldConfig);
            
            fieldConfig.Big_Object_Field_API_Name__c=fieldObj.fullName;
            fieldConfig.Big_Object_Field_Name__c=fieldObj.label;
            
            if(fieldConfig.Indexed__c){
                MetadataService.IndexField indfl = new MetadataService.IndexField();  
                indfl.name = fieldObj.fullName;  
                indfl.sortDirection = (fieldConfig.Is_Ascending_Sort__c)?'ASC':'DESC';  
                lstIndexFields.add(indfl);  
            }
           	System.debug('Field: '+fieldObj.fullName);
            lstCustomFields.add(fieldObj);  
            toUpdateFields.add(fieldConfig);
        }
        
        
        //define index  
        List<MetadataService.Index> lstIndex = new List<MetadataService.Index>() ;  
        
        MetadataService.Index indexObj = new MetadataService.Index();  
        indexObj.label = bigObject.label;  
        indexObj.fullName = bigObject.label.replace(' ','_');  
        System.debug('Index: '+indexObj.fullName);
        indexObj.fields = lstIndexFields;  
        
        lstIndex.add(indexObj);  
        
        bigObject.fields = lstCustomFields; 
        bigObject.indexes = lstIndex;  
        
        
        //finally create Big Object with Index field  
        List<MetadataService.SaveResult> saveResults = service.createMetadata( new MetadataService.Metadata[] { bigObject});   
       	 
        for(MetadataService.SaveResult result:saveResults){
            if(!result.success){
                for(MetadataService.Error error:result.errors){
                 	System.debug('Message: '+error.message);    
                    System.debug('Fields: '+error.fields);   
                    errorList.add(error.fields[0]+':'+error.message);
                }
                 
            }
            
        }
        
        if(errorList.size()>0){
            throw new ConfigurationEngineException(String.join(errorList, ','));
        } 
        
        
        update bigObjectDetails;
        update toUpdateFields;
         
        
        
    
    }
    
    
   
    
}