// Mock class for BulkSAPAuthorisation
public class BulkSAPAuthorisationMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(405);
        res.setHeader('x-csrf-token', 'jbcjkwbvijwbv');
        res.setHeader('set-cookie', 'MYSAPSSO2=mocked;SAP_SESSIONID_BRQ_300=mocked;');
        res.setBody('{}');
        return res;
    }
}