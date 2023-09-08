public with sharing class ConfigurationEngine {
    
    
    
    public static void createBigObjectConfiguration(String sourceObjectApiName,List<String> sourceObjectFieldApiName,Set<String> indexFieldApiNames){
        DescribeSobjectResult objectDetails=SDescribeUtility.getSobjectType(sourceObjectApiName.trim());
        Map<String,DescribeFieldResult> fieldDetails=SDescribeUtility.getAllObjectFields(objectDetails);
        
        Big_Object_Configuration__c configObj=generatConfigurationRecrod(objectDetails);
        insert configObj;
       
        List<Big_Object_Field_Configuration__c> toInsertFields=new List<Big_Object_Field_Configuration__c>();
        for(String apiName:sourceObjectFieldApiName){
            apiName=apiName.trim();
            DescribeFieldResult fieldConfig=fieldDetails.get(apiName);
           	toInsertFields.add(generateFieldConfiguration(configObj.Id,configObj.Source_Object_API_Name__c,fieldConfig,indexFieldApiNames));
            if(fieldConfig.getType()==DisplayType.Reference || fieldConfig.getType()==DisplayType.ID){
                toInsertFields.add(generateAutomatedFieldConfiguration(configObj.Id,configObj.Source_Object_API_Name__c,fieldConfig,'Id'));
            }
        }
        toInsertFields.add(generateAutomatedFieldConfiguration(configObj.Id,configObj.Source_Object_API_Name__c,null,'TimeStamp'));
        
        insert toInsertFields;
        
    }
    
    private static Big_Object_Field_Configuration__c generateFieldConfiguration(String configId,String sourceObjectApi,DescribeFieldResult fieldDetails,Set<String> indexFieldApiNames){
        
        Big_Object_Field_Configuration__c fieldObj=new Big_Object_Field_Configuration__c();
        fieldObj.Source_Object_Field_API_Name__c=fieldDetails.getName();
      
        fieldObj.Source_Object_Field_Name__c=fieldDetails.getLabel();
        fieldObj.Data_Type__c=getBigObjectFieldType(fieldDetails.getType());
        fieldObj.Source_Data_Type__c=String.valueOf(fieldDetails.getType());
        fieldObj.Indexed__c=indexFieldApiNames.contains(fieldDetails.getName());
        fieldObj.Source__c='User Defined';
        fieldObj.Big_Object_Configuration__c=configId;
        fieldObj.Source_Object_API_Name__c=sourceObjectApi;
        if(fieldDetails.getType()==DisplayType.Reference || fieldDetails.getType()==DisplayType.ID){
            fieldObj.Source_Object_Field_API_Name__c='Idx_'+fieldObj.Source_Object_Field_API_Name__c;
            fieldObj.Source_Object_Field_Name__c='Id '+fieldObj.Source_Object_Field_Name__c;
        }
        
        if(fieldObj.Data_Type__c=='text'){
            fieldObj.Text_Field_Length__c=255;
        }
        else if(fieldObj.Data_Type__c=='textArea'){
            fieldObj.Text_Field_Length__c=fieldDetails.getLength();
        }
        if(fieldObj.Data_Type__c=='number'){
            fieldObj.Number_Field_Length__c=fieldDetails.getPrecision();
        }
        return fieldObj;
    }
    
    private static Big_Object_Field_Configuration__c generateAutomatedFieldConfiguration(String configId,String sourceObjectApi,DescribeFieldResult fieldDetails,String fieldType){
        Big_Object_Field_Configuration__c fieldObj=new Big_Object_Field_Configuration__c();
       
        fieldObj.Data_Type__c='text';
        fieldObj.Source__c='System Generated';
        fieldObj.Big_Object_Configuration__c=configId;
        fieldObj.Source_Object_API_Name__c=sourceObjectApi;
        if(fieldType=='TimeStamp'){
            fieldObj.Source_Object_Field_API_Name__c='Record_CreatedDate__c';
            fieldObj.Source_Object_Field_Name__c='Record Created Date';
            fieldObj.Data_Type__c='datetime';
            fieldObj.Source_Data_Type__c='DATETIME';
        }
        else{
            fieldObj.Text_Field_Length__c=255;
            fieldObj.Source_Object_Field_API_Name__c='Namex_'+fieldDetails.getName();
            fieldObj.Source_Object_Field_Name__c='Name '+fieldDetails.getLabel();
            fieldObj.Source_Data_Type__c='String';
        } 
        return fieldObj;
    }
    
    private static String getBigObjectFieldType(Schema.DisplayType fieldType){
        string typeString='';
        if( fieldType==DisplayType.Boolean || fieldType==DisplayType.Combobox || fieldType==DisplayType.Time || fieldType==DisplayType.String || fieldType==DisplayType.Picklist || fieldType==DisplayType.MultiPicklist || fieldType==DisplayType.EncryptedString) {
            typeString='text';
        }
        else if(fieldType==DisplayType.URL){
            typeString='URL';            
        }
        else if(fieldType==DisplayType.TextArea){
            typeString='textArea';            
        }
        else if(fieldType==DisplayType.Reference || fieldType==DisplayType.ID){
            typeString='text';
        }
        else if(fieldType==DisplayType.Phone){
            typeString='phone';
        }
        else if(fieldType==DisplayType.Percent || fieldType==DisplayType.Long || fieldType==DisplayType.Double || fieldType==DisplayType.Currency){
            typeString='number';
        }
        else if(fieldType==DisplayType.Email){
            typeString='email';
        }
        else if(fieldType==DisplayType.DateTime || fieldType==DisplayType.Date){
            typeString='datetime';
        }
        
        return typeString;
    }
    
    private static Big_Object_Configuration__c generatConfigurationRecrod(DescribeSobjectResult objectDetails){
        Big_Object_Configuration__c bigObj=new Big_Object_Configuration__c();
        bigObj.Source_Object_API_Name__c=objectDetails.getName();
        bigObj.Source_Object_Name__c=objectDetails.getLabel();
        bigObj.List_View_Name__c=Constants.LISTVIEW_PREFIX+' '+objectDetails.getName();
        
        
        return bigObj;
    }
    
}