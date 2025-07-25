public class AddressFormCtrl{
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCityAndStateByPinCode(String pinCode) {
        Map<String, String> result = new Map<String, String>();
        //call mapMyIndia api 

        //result.put('state', 'Unknown State');
        result = callMappelsPinCodeService(pinCode);
        system.debug(result);
        return result;
    }

    public static  Map<String, String>  callMappelsPinCodeService(String pinCode){
        HttpRequest oRequest = new HttpRequest();
        HTTPResponse oResponse = new HTTPResponse();
        Http oHttp = new Http();
        oRequest.setEndpoint('callout:PostalCodeAPI/'+pinCode);
        oRequest.setMethod('GET');
        oRequest.setHeader('Content-Type','application/x-www-form-urlencoded');  
        oResponse = oHttp.send(oRequest);
        System.debug('Body ' + oResponse.getBody());
         if (oResponse.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(oResponse.getBody());
            Map<String, String> result = new Map<String, String>();
             if(responseMap.containsKey('city') && responseMap.containsKey('state')){
                result.put('city', (String) responseMap.get('city'));
            	result.put('state', (String) responseMap.get('state'));
             } else if(responseMap.containsKey('address')){
                 String address = (String)responseMap.get('address');
                 result.put('city', address.split(',')[0]);
            	 result.put('state', address.split(',')[1]);
             }
             
        	return result;
        } else {
            throw new CalloutException('Failed to get city and state. Response: ' +  oResponse.getBody());
        }
    }

    @AuraEnabled
    public static List<Locality_SubLocality_Data__c> getLocality(String pincode){
        return [Select Id, Locality__c, Sub_Locality__c from Locality_SubLocality_Data__c where pincode__c = : pincode];
    }

    @AuraEnabled
    public static List<PinCode__c> getSector(String pincode){
        return [Select Id, Sector__c from PinCode__c where Postal_Code__c = : pincode and Sector__c != null];
    }
}