public with sharing class AddRecipeIntoOppController {
  public static Set<String> setOfproductsId = new Set<String>();
  private static Map<Id, Decimal> productPriceMap;
  private static Map<Id, String> productPriceBookIdMap;
  public static Decimal discount;

  @AuraEnabled
  public static void addRecipeIntoOpp(String recipeId, String oppId){
    // Get Opportunity from oppId
    Opportunity opp = [Select Id, Recipe__c, Account.Id from Opportunity where Id =: oppId];
      
    // Get Account Discount from AccountId
    Account acc = [Select Id, Discount__c from Account where Id =: opp.Account.Id];
    discount = acc.Discount__c;

    // add Recipe into the Opportunity
    opp.Recipe__c = recipeId;

    // get productQuantityMap
    // run this one first to get setOfproductsId
    Map<Id, Decimal> productQuantityMap = getProductQuantity(recipeId);

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

  private static Map<Id, String> getProductName() {
    Map<Id, String> result = new  Map<Id,String>();
    
  }
}