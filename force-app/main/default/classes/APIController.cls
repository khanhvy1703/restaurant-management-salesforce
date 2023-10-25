public with sharing class APIController {
	public static CatFactInnerClass fetchCatFactApi() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://catfact.ninja/fact');
		request.setMethod('GET');
		Http http = new Http();

		try {
			HttpResponse response = http.send(request);
			if (response.getStatusCode() == 200) {
					CatFactInnerClass result = (CatFactInnerClass) JSON.deserialize(response.getBody(), CatFactInnerClass.class);
					return result;
			} else {
					System.debug('Error: Unable to fetch data.');
					return null;
			}
		} catch (Exception e) {
			System.debug('An error occurred: ' + e.getMessage());
			return null;
		}
	}

	public class CatFactInnerClass {
		public String fact {get; set;}
		public Integer length {get; set;}
	}
}