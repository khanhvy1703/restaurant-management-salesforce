public with sharing class MockTestClass implements HttpCalloutMock {
  private static final String mockResponse = '{"fact": "Mock Cat Fact", "length": 12}';

  public HTTPResponse respond(HTTPRequest req) {
    HTTPResponse res = new HTTPResponse();
    res.setBody(mockResponse);
    res.setStatusCode(200);
    return res;
  }
}