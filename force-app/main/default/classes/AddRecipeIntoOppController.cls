public with sharing class AddRecipeIntoOppController {
  private static Set<String> setOfproductsId = new Set<String>();
  private static Restaurant_Discount__mdt setting;
  private static Decimal customerDiscount;
  private static Decimal settingDiscount;

  @AuraEnabled
  public static void addRecipeIntoOpp(String recipeId, String oppId){
    setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'Discount_200' limit 1];
    if(setting != null) {
      settingDiscount = setting.Percentage__c; 
    } else {
      customerDiscount = 0;
    }

    // Get Opportunity from oppId
    Opportunity opp = [Select Id, Pricebook2Id, Recipe__c, Account.Id from Opportunity where Id =: oppId];
    opp.Recipe__c = recipeId;

    // Get Account Discount from AccountId
    Account acc = [Select Id, Discount__c from Account where Id =: opp.Account.Id];
    if(acc.Discount__c != null) {
      customerDiscount = acc.Discount__c; 
    } else {
      customerDiscount = 0;
    }

    // get productQuantityMap
    // run this one first in order to get setOfproductsId
    Map<Id, Decimal> productQuantityMap = getProductQuantity(recipeId);
    Id opportunityPricebookId = opp.Pricebook2Id;
    List<PricebookEntry> entries = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :setOfproductsId And Pricebook2Id = :opportunityPricebookId];
    Map<Id, Decimal> productPriceMap = getProductPrice(entries);
    Map<Id, String> productCodeMap = getProductCode();

    // add Recipe into the Opportunity

    List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
    for (String pId: setOfproductsId) {
      OpportunityLineItem oppLineItem = new OpportunityLineItem();
      Decimal totalDiscount = customerDiscount;
      if (productQuantityMap.containsKey(pId) && productPriceMap.containsKey(pId) && productCodeMap.containsKey(pId)) {
        oppLineItem.OpportunityId = oppId;
        oppLineItem.Product2Id = pId;
        oppLineItem.Quantity = productQuantityMap.get(pId);
        oppLineItem.UnitPrice = productPriceMap.get(pId);
        if (productQuantityMap.get(pId) * productPriceMap.get(pId) > 100) {
          totalDiscount = customerDiscount + settingDiscount;
        }
        oppLineItem.Discount = totalDiscount;
        //oppLineItem.PricebookEntryId = opportunityPricebookId;
      }
      oppLineItemList.add(oppLineItem);
    }

    System.debug(productQuantityMap);
    System.debug(productPriceMap);
    System.debug(productCodeMap);
    System.debug(oppLineItemList);

    insert oppLineItemList;
    update opp;
  }

  // Id: productId
  // Decimal: Quantity of the Product
  // TODO: remove recursive calls in hierarchy
  private static List<Map<Id, Decimal>> getProductQuantityFromRecipeId(String recipeId) {
    List<Ingredient__c> ingredients = [Select Id, Name, Product__c, Recipe__c, Quantity__c, Related_Recipe__c from Ingredient__c where Related_Recipe__c =: recipeId];

    Set<String> productIds = new Set<String>();
    Set<String> recipeIds = new Set<String>();

    for (Ingredient__c i : ingredients) {
      if (i.Recipe__c != null) {
        recipeIds.add(i.Recipe__c);
      } if (i.Product__c != null) {
        productIds.add(i.Product__c);
      }
    }

    setOfproductsId.addAll(productIds);
    List<Map<Id, Decimal>> result = new List<Map<Id, Decimal>>();

    for (String r : recipeIds) {
      List<Map<Id, Decimal>> m = getProductQuantityFromRecipeId(r);
      result.addAll(m);
    }

    Map<Id, Decimal> mProduct = getProductQuantityFromSetOfProductId(productIds, recipeId);
    result.add(mProduct);

    return result;
  }

  private static Map<Id, Decimal> getProductQuantityFromSetOfProductId(Set<String> productIds, String recipeId) {
    //System.debug(productIds);
    Map<Id, Decimal> result = new Map<Id, Decimal>();
    List<Product2> products = [Select Id, Name, (Select Id, Quantity__c, Related_Recipe__c From Ingredients__r) From Product2 where id IN: productIds];
    for(Product2 p: products) {
      Decimal quantity = 0;
      List<Ingredient__c> ingredients = p.Ingredients__r;
      for (Ingredient__c i : ingredients) {
        if (i.Related_Recipe__c == recipeId) {
          quantity = i.Quantity__c;
          break;
        }
      }
      result.put(p.Id, quantity);
    }
    return result;
  }

  private static Map<Id, Decimal> getProductQuantity(String recipeId) {
    Map<Id, Decimal> result = new Map<Id, Decimal>();
    List<Map<Id, Decimal>> maps = getProductQuantityFromRecipeId(recipeId);
    for (Map<Id, Decimal> m : maps) {
      for(Id key : m.keySet()) {
        if (!result.containsKey(key)) {
          result.put(key, m.get(key));
        } else {
          result.put(key, m.get(key) + result.get(key));
        }
      }
    }
    return result;
  }

  private static Map<Id, Decimal> getProductPrice(List<PricebookEntry> entries) {
    Map<Id, Decimal> result = new Map<Id, Decimal>();
    for (PricebookEntry pr: entries) {
      result.put(pr.Product2Id, pr.UnitPrice);
    }
    return result;
  }

  private static Map<Id, String> getProductCode() {
    Map<Id, String> result = new Map<Id, String>();
    List<Product2> products = [SELECT Id, ProductCode from Product2 Where Id IN :setOfproductsId];
    for (Product2 p: products) {
      result.put(p.Id, p.ProductCode);
    }
    return result;
  }

}