public class ContentDownloadHandlerFactoryImpl implements Sfc.ContentDownloadHandlerFactory {
  public Sfc.ContentDownloadHandler getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext context) {
        
        // Query for content versions based on provided IDs
        List<ContentVersion> contentVersions = [
            SELECT Id, Title
            FROM ContentVersion
            WHERE Id IN :ids
        ];
        
        // Query for related content distributions
        List<ContentDistribution> contentDistributions = [
            SELECT Id, Name, ContentVersionId
            FROM ContentDistribution
            WHERE ContentVersionId IN :contentVersions
        ];
        
        // Initialize the ContentDownloadHandler
        Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();
        
        // List of restricted file name prefixes
        List<String> restrictedPrefixes = new List<String>{'SOP', 'Manual', 'GADrawing', 'TechDataSheet', 'CriticalSparePartList', 'TrainingPresentation','WiringDiagram','FirmwareUpload'};
        
        // Loop through each ContentDistribution to check for restricted prefixes
        for (ContentDistribution contentDist : contentDistributions) {
            for (String prefix : restrictedPrefixes) {
                if (contentDist.Name.startsWith(prefix)) {
                    contentDownloadHandler.isDownloadAllowed = false;
                    contentDownloadHandler.downloadErrorMessage = 'You do not have permission to download this file.';
                    return contentDownloadHandler;
                }
            }
        }
        
        // If no restrictions are found, allow the download
        contentDownloadHandler.isDownloadAllowed = true;
        return contentDownloadHandler;
    }
}