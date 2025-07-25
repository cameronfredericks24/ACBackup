public class SAPTokenUtils{
    
    public static final String SENDCONTRACTAPI = 'Send_Contract_Details_API';
    
    public static String extractCsrfToken(HttpResponse res) {
        return (String)res.getHeader('x-csrf-token');
    }
    
    // Method to extract cookie values from the response headers
    public static String extractCookies(String originalString) {
        // Extract MYSAPSSO2
        String mySAPSSO2 = extractValue(originalString, 'MYSAPSSO2=');
        
        // Extract SAP_SESSIONID_BRQ_300
        String sessionID = extractValue(originalString, 'SAP_SESSIONID_BRQ_300=');
        
        // Extract sap-usercontext
        String userContext = extractValue(originalString, 'sap-usercontext=');
        
        // Construct the final cookie string
        return mySAPSSO2 + ';' + sessionID + ';' + userContext;
    }
    
    private static String extractValue(String originalString, String key) {
        Integer startIndex = originalString.indexOf(key);
        if (startIndex == -1) {
            return ''; // Return empty string if key is not found
        }
        Integer endIndex = originalString.indexOf(';', startIndex);
        if (endIndex == -1) {
            endIndex = originalString.length(); // In case it’s the last cookie in the string
        }
        return originalString.substring(startIndex, endIndex);
    }
    
    
    public static Map<String, String> prepareHeaders(HttpResponse res) {
        Map<String, String> headers = new Map<String, String>();
        String csrfToken = extractCsrfToken(res);
        String cookieString = extractCookies(res.getHeader('set-cookie'));
        
        headers.put('x-csrf-token', csrfToken);
        headers.put('Content-Type', 'application/json');
        headers.put('Cookie', cookieString);
        
        return headers;
    }
    
    
}