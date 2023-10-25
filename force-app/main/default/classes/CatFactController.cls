public with sharing class CatFactController {
	public static String getCatFact() {
		return APIController.fetchCatFactApi().fact;
	}
}