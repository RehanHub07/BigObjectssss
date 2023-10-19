public inherited sharing class ConfigurationEngineHelper {

     /*
     * Desc : creates field details based on source field of object for big object
	*/
    public static Big_Object_Field_Configuration__c generateFieldConfiguration(String configId,String sourceObjectApi,DescribeFieldResult fieldDetails,Set<String> indexFieldApiNames){
        
        Big_Object_Field_Configuration__c fieldObj=new Big_Object_Field_Configuration__c();
        fieldObj.Source_Object_Field_API_Name__c=fieldDetails.getName();
      	fieldObj.Is_Standard_Field__c=!fieldDetails.isCustom();
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
        
        if(fieldDetails.getType()==DisplayType.Reference || fieldDetails.getType()==DisplayType.ID){
            fieldObj.Text_Field_Length__c=18;
        }
        else if(fieldObj.Data_Type__c=='Text'){
            fieldObj.Text_Field_Length__c=255;
        }
        else if(fieldObj.Data_Type__c=='LongTextArea'){
            fieldObj.Text_Field_Length__c=fieldDetails.getLength();
        }
        if(fieldObj.Data_Type__c=='Number'){
            fieldObj.Number_Field_Length__c=fieldDetails.getPrecision();
        }
        return fieldObj;
    }
    
    /*
     * Desc : creates field details for big object based on source object field to compliment data
	*/
    public static Big_Object_Field_Configuration__c generateAutomatedFieldConfiguration(String configId,String sourceObjectApi,DescribeFieldResult fieldDetails,String fieldType){
        Big_Object_Field_Configuration__c fieldObj=new Big_Object_Field_Configuration__c();
       
        fieldObj.Data_Type__c='text';
        fieldObj.Source__c='System Generated';
        fieldObj.Big_Object_Configuration__c=configId;
        fieldObj.Source_Object_API_Name__c=sourceObjectApi;
        if(fieldType=='TimeStamp'){
            fieldObj.Source_Object_Field_API_Name__c='Backup_Date__c';
            fieldObj.Source_Object_Field_Name__c='Backup Date';
            fieldObj.Data_Type__c='datetime';
            fieldObj.Source_Data_Type__c='DATETIME';
            fieldObj.Indexed__c=true;
        }
        else{
            fieldObj.Text_Field_Length__c=255;
            fieldObj.Source_Object_Field_API_Name__c='Namex_'+fieldDetails.getName();
            fieldObj.Source_Object_Field_Name__c='Name '+fieldDetails.getLabel();
            fieldObj.Source_Data_Type__c='String';
        } 
        return fieldObj;
    }
    
    /*
     * Desc : based on source data type returns big object datatype
	*/
    private static String getBigObjectFieldType(Schema.DisplayType fieldType){
        string typeString='';
        if( fieldType==DisplayType.Boolean || fieldType==DisplayType.Combobox || fieldType==DisplayType.Time || fieldType==DisplayType.String || fieldType==DisplayType.Picklist || fieldType==DisplayType.MultiPicklist || fieldType==DisplayType.EncryptedString) {
            typeString='Text';
        }
        else if(fieldType==DisplayType.URL){
            typeString='URL';            
        }
        else if(fieldType==DisplayType.TextArea){
            typeString='LongTextArea';            
        }
        else if(fieldType==DisplayType.Reference || fieldType==DisplayType.ID){
            typeString='Text';
        }
        else if(fieldType==DisplayType.Phone){
            typeString='Phone';
        }
        else if(fieldType==DisplayType.Percent || fieldType==DisplayType.Long || fieldType==DisplayType.Double || fieldType==DisplayType.Currency){
            typeString='Number';
        }
        else if(fieldType==DisplayType.Email){
            typeString='Email';
        }
        else if(fieldType==DisplayType.DateTime || fieldType==DisplayType.Date){
            typeString='DateTime';
        }
        
        return typeString;
    }
    
    /*
     * Desc : creates  big object configuration details
	*/
    public static Big_Object_Configuration__c generatConfigurationRecrod(DescribeSobjectResult objectDetails){
        Big_Object_Configuration__c bigObj=new Big_Object_Configuration__c();
        bigObj.Source_Object_API_Name__c=objectDetails.getName();
        bigObj.Source_Object_Name__c=objectDetails.getLabel();
        bigObj.List_View_Name__c=Constants.LISTVIEW_PREFIX+' '+objectDetails.getName();
        
        
        return bigObj;
    }
    
     /*
     * Desc : returns metadata connection
	*/
    public static MetadataService.MetadataPort getMetadataConnection(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();  
        service.SessionHeader = new MetadataService.SessionHeader_element();  
        service.SessionHeader.sessionId = UserInfo.getSessionId();  
        
        service.AllOrNoneHeader = new MetadataService.AllOrNoneHeader_element();  
        service.AllOrNoneHeader.allOrNone = true; 
        return service;
    }
    
    /*
     * Desc : returns big object metdata file
	*/
    public static MetadataService.CustomObject getBigObjectMetadataConfig(Big_Object_Configuration__c bigObjectDetails){
        MetadataService.CustomObject bigObject = new MetadataService.CustomObject();  
        bigObject.fullName = 'Archive_'+bigObjectDetails.Source_Object_API_Name__c.replace('__c','')+'__b'; 
        bigObject.label = 'Archive '+bigObjectDetails.Source_Object_Name__c;  
        bigObject.pluralLabel = 'Archive '+bigObjectDetails.Source_Object_Name__c+'s';  
        bigObject.deploymentStatus = 'InDevelopment'; //Make it Deployed if you need
        return bigObject;
    }
    
     /*
     * Desc : returns big object field metdata file
	*/
    public static MetadataService.CustomField getBigObjectFieldMetadataConfig(Big_Object_Field_Configuration__c fieldConfig){
        MetadataService.CustomField fieldObj = new MetadataService.CustomField();  
        fieldObj.type_x = fieldConfig.Data_Type__c;  
        fieldObj.label = fieldConfig.Source_Object_Field_Name__c;  
        fieldObj.fullName = fieldConfig.Source_Object_Field_API_Name__c.replace('__c','')+'__c'; 
        if(fieldObj.type_x=='Text'){
            fieldObj.length = (Integer) fieldConfig.Text_Field_Length__c;      
        }
        else if(fieldObj.type_x=='Number'){
            String s = String.valueOf(fieldConfig.Number_Field_Length__c);
            String[] arrayDecimal = s.split('\\.');
            Integer beforeDecimal=Integer.valueOf(arrayDecimal[0]);
            Integer afterDecimal=Integer.valueOf(arrayDecimal[1]);
            fieldObj.precision = beforeDecimal;  
            fieldObj.scale =afterDecimal;  
        }
        else if(fieldObj.type_x=='LongTextArea'){
            fieldObj.length = (Integer) fieldConfig.Text_Field_Length__c;      
            fieldObj.visibleLines = 3;  
        }
        
        fieldObj.required = fieldConfig.Indexed__c; 
        return fieldObj;
    }
    
    
    
    
}