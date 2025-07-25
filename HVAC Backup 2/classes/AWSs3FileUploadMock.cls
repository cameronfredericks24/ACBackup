public class AWSs3FileUploadMock implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;

    public AWSs3FileUploadMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }
}