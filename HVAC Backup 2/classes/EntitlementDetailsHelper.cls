/*
@Author : Abhijeet Ojha
@CreatedDate : 17th May 2024
@Description : Entitlement Return Asset Warranty and Obligations
*/
public class EntitlementDetailsHelper {
    public static final String SUCCESS_RESPONSE_RESULT = 'Success';
    public static final String FAILURE_RESPONSE_RESULT = 'Failure';
    public static final String ERROR_RESPONSE_RESULT = 'Error';
    public static final String SUCCESS_RESPONSE_MESSAGE = 'Entitlements fetched successfully.';
    public static final String FAILURE_RESPONSE_MESSAGE = 'Failed to fetch entitlements.';
    public static final String ERROR_RESPONSE_MESSAGE = 'An error occurred while fetching entitlements.';

    public static Map<String, Object> getEntitlementDetails(EntitlementDetailsRequestWrapper requestWrapper) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Fetch assets with related asset warranties using the AssetSelector class
            List<Asset> assets = AssetSelector.getAssetDetailsByModelAndSerial(requestWrapper.productModel,requestWrapper.serialNumber, requestWrapper.mobileNumber);
            
            List<EntitlementDetailsResponseWrapper.Entitlement> entitlements = new List<EntitlementDetailsResponseWrapper.Entitlement>();
            
            for (Asset asset : assets) {
                EntitlementDetailsResponseWrapper.Entitlement entitlement = new EntitlementDetailsResponseWrapper.Entitlement();
                
                // Fetch warranty expiry date from related AssetWarranty records
                if (asset.WarrantyAssets.size() > 0) {
                    entitlement.warrantyExpiryDate = formatDate(asset.WarrantyAssets[0].EndDate);
                } else {
                    entitlement.warrantyExpiryDate = null; // or handle the case when there is no warranty
                }
                
                // Set the obligation from the Asset object
                entitlement.obligation = asset.Asset_Obligation__c;
                entitlements.add(entitlement);
            }

            if (!entitlements.isEmpty()) {
                result.put(SUCCESS_RESPONSE_RESULT, true);
                result.put('entitlements', entitlements);
            } else {
                result.put(FAILURE_RESPONSE_RESULT, true);
            }
        } catch (Exception e) {
            // Handle exceptions and return failure response
            System.debug('Exception: ' + e.getMessage());
            result.put(FAILURE_RESPONSE_RESULT, true);
        }
        
        return result;
    }

    // Helper method to format DateTime
    private static String formatDate(Date dates) {
        if (dates == null) {
            return null;
        }
        // Convert Date to Datetime to format it correctly
        Datetime dateTimes = Datetime.newInstance(dates.year(), dates.month(), dates.day());
        return dateTimes.format('dd-MMM-yyyy 00:00:00');
    }
}