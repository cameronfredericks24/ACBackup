public class DownloadingMatrixSelector {
    public static List<Downloading_Matrix__c> getMatrix(set<String> combinedString){
        return [select Combined_String__c,CP__c from Downloading_Matrix__c where combined_string__c in: combinedString ];
    }
}