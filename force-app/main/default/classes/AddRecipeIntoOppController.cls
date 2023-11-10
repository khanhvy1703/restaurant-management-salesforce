public with sharing class AddRecipeIntoOppController {
  private static Set<String> setOfproductsId = new Set<String>();
  private static Map<String, Decimal> productQuantityMap = new Map<String, Decimal>();
  private static Restaurant_Discount__mdt setting;
  private static Decimal customerDiscount = 0;
  private static Decimal settingDiscount = 0;
  private static String ingredientDiscountLabel = System.Label.Ingredient_Discount_Price;

  @AuraEnabled
  public static void addRecipeIntoOpp(String recipeId, String oppId){
    setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'Discount_200' limit 1];
    if(setting != null) {
      settingDiscount = setting.Percentage__c; 
    }

    Pricebook2 standardPricebook = [Select Id, IsStandard from Pricebook2 where IsStandard = true limit 1];

    // Get Opportunity from oppId
    Opportunity opp = [Select Id, Pricebook2Id, Recipe__c, Account.Id from Opportunity where Id =: oppId];
    opp.Recipe__c = recipeId;
    if (opp.Pricebook2Id == null) {
      opp.Pricebook2Id = standardPricebook.Id;
    }
    update opp;

    String opportunityPricebookId = opp.Pricebook2Id;
    System.debug(opportunityPricebookId);

    // Get Account Discount from AccountId
    Account acc = [Select Id, Discount__c from Account where Id =: opp.Account.Id];
    if(acc.Discount__c != null) {
      customerDiscount = acc.Discount__c; 
    }

    List<Ingredient__c> ingredients = [Select Id, Name, Product__c, Product__r.ProductCode, Quantity__c, Related_Recipe__c from Ingredient__c where Related_Recipe__c =: recipeId];
    for (Ingredient__c i : ingredients) {
      setOfproductsId.add(i.Product__c);
      productQuantityMap.put(i.Product__c, i.Quantity__c);
    }

    Map<String, Decimal> productPriceMap = getProductPrice(opportunityPricebookId);
    Integer discountLabel = Integer.valueOf(ingredientDiscountLabel);

    System.debug(setOfproductsId);
    System.debug(productQuantityMap);
    System.debug(productPriceMap);

    // add Recipe into the Opportunity

    List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
    for (String pId: setOfproductsId) {
      OpportunityLineItem oppLineItem = new OpportunityLineItem();
      Decimal totalDiscount = customerDiscount;

      if (productQuantityMap.containsKey(pId) && productPriceMap.containsKey(pId)) {
        oppLineItem.OpportunityId = oppId;
        oppLineItem.Product2Id = pId;
        oppLineItem.Quantity = productQuantityMap.get(pId);
        oppLineItem.UnitPrice = productPriceMap.get(pId);
        if (productQuantityMap.get(pId) * productPriceMap.get(pId) >= discountLabel) {
          totalDiscount = customerDiscount + settingDiscount;
        }
        oppLineItem.Discount = totalDiscount;
        //oppLineItem.PricebookEntryId = opportunityPricebookId;
        oppLineItemList.add(oppLineItem);
      }
    }

    System.debug(oppLineItemList);
    insert oppLineItemList;
  }

    private static Map<String, Decimal> getProductPrice(String pricebookOpp) {
    List<PricebookEntry> entries = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry where Pricebook2Id =: pricebookOpp and Product2Id In: setOfproductsId];
    Map<String, Decimal> result = new Map<String, Decimal>();
    for (PricebookEntry pr: entries) {
      result.put(pr.Product2Id, pr.UnitPrice);
    }
    return result;
  }
}