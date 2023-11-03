public with sharing class AddRecipeController {
  public class IngredientsInnerClass {
    @AuraEnabled public String ingredientName {get; set;}
    @AuraEnabled public Integer quantity {get; set;}
    @AuraEnabled public Boolean isProduct {get; set;}
    @AuraEnabled public Boolean isRecipe {get; set;}
  }

  public class IngredientsSummaryInnerClass {
    @AuraEnabled public String productId {get; set;}
    @AuraEnabled public Decimal quantity {get; set;}
    @AuraEnabled public String productName {get; set;}
  }

  @AuraEnabled
  public static List<IngredientsSummaryInnerClass> summary(List<IngredientsInnerClass> listOfIngredients){
    List<IngredientsSummaryInnerClass> result = new List<IngredientsSummaryInnerClass>();
    Map<String, Integer> recipes = new Map<String, Integer>();
    Map<String, Integer> products = new Map<String, Integer>();

    for (IngredientsInnerClass i : listOfIngredients) {
      if (i.isRecipe) {
        if (!recipes.containsKey(i.ingredientName)) {
          recipes.put(i.ingredientName, i.quantity);
        } else {
          recipes.put(i.ingredientName, i.quantity + recipes.get(i.ingredientName));
        }
      } 
      if(i.isProduct) {
        if (!products.containsKey(i.ingredientName)) {
          products.put(i.ingredientName, i.quantity);
        } else {
          products.put(i.ingredientName, i.quantity + products.get(i.ingredientName));
        }
      } 
    }

    List<Map<String, Decimal>> listOfMaps = new List<Map<String, Decimal>>();

    // recipes
    for (String key : recipes.keySet()) {
      Decimal quantity = recipes.get(key);
      Map<String, Decimal> productsFromRecipe = getProductsFromRecipe(key, quantity);
      listOfMaps.add(productsFromRecipe);
    }

    // products
    for (String key : products.keySet()) {
      Map<String, Decimal> productMap = new Map<String, Decimal>();
      productMap.put(key, products.get(key));
      listOfMaps.add(productMap);
    }

    Map<String, Decimal> finalProductAndQuantity = new Map<String, Decimal>();
    for (Map<String, Decimal> m : listOfMaps) {
      for (String key : m.keySet()) {
        Decimal q = m.get(key);
        if (!finalProductAndQuantity.containsKey(key)) {
          finalProductAndQuantity.put(key, q);
        } else {
          finalProductAndQuantity.put(key, q + finalProductAndQuantity.get(key));
        }
      }
    }

    Set<String> listOfProductIds = finalProductAndQuantity.keySet();
    Map<String, String> productNameMap = getProductNameFromIds(listOfProductIds);

    for (String pId : listOfProductIds) {
      if (finalProductAndQuantity.containsKey(pId) && productNameMap.containsKey(pId)) {
        IngredientsSummaryInnerClass summaryClass = new IngredientsSummaryInnerClass();
        summaryClass.productId = pId;
        summaryClass.productName = productNameMap.get(pId);
        summaryClass.quantity = finalProductAndQuantity.get(pId);
        result.add(summaryClass);
      }
    }

    System.debug(listOfMaps);
    System.debug(products);
    System.debug(finalProductAndQuantity);
    System.debug(result);
    return result;
  }

  // recipeAndQuanity: key is recipe Id and value is quanity.
  // result: key is productId and value id quantity
  private static Map<String, Decimal> getProductsFromRecipe(String recipeId, Decimal quanity) {
    Map<String, Decimal> result = new Map<String, Decimal>();
    List<Ingredient__c> ingredients = [select Id, Name, Quantity__c, Product__r.Id from Ingredient__c where Related_Recipe__c =: recipeId];
    for (Ingredient__c i : ingredients) {
      Decimal newQuantity = i.Quantity__c * quanity;
      result.put(i.Product__r.Id, newQuantity);
    }
    System.debug(result);
    return result;
  }

  private static Map<String, String> getProductNameFromIds(Set<String> productIds) {
    Map<String, String> result = new Map<String, String>();
    List<Product2> products = [SELECT Id, Name from Product2 Where Id IN :productIds];
    for (Product2 p: products) {
      result.put(p.Id, p.Name);
    }
    return result;
  }

  @AuraEnabled
  public static void addNewRecipe(String recipeName, List<IngredientsSummaryInnerClass> listOfIngredients){
    // Add recipe
    Recipe__c newrecipe = new Recipe__c();
    newrecipe.Name = recipeName;
    insert newrecipe;

    List<Ingredient__c> ingredients = new List<Ingredient__c>();
    for (IngredientsSummaryInnerClass i : listOfIngredients) {
      Ingredient__c ingredient = new Ingredient__c();
      ingredient.Name = recipeName + ': ' + i.productName;
      ingredient.Product__c = i.productId;
      ingredient.Quantity__c = i.quantity;
      ingredient.Related_Recipe__c = newrecipe.Id;
      ingredients.add(ingredient);
    }
    
    System.debug(ingredients);
    insert ingredients;
  }
}