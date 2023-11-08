public with sharing class AddRecipeController {
  public class IngredientsInnerClass {
    @AuraEnabled public String ingredientName {get; set;}
    @AuraEnabled public Decimal quantity {get; set;}
    @AuraEnabled public Boolean isProduct {get; set;}
    @AuraEnabled public Boolean isRecipe {get; set;}
  }

  public class IngredientsSummaryInnerClass {
    @AuraEnabled public String productId {get; set;}
    @AuraEnabled public Decimal quantity {get; set;}
    @AuraEnabled public String productName {get; set;}
  }

  public class IngredientLWCInnerClass {
    @AuraEnabled public String name {get; set;}
    @AuraEnabled public Decimal quantity {get; set;}
    @AuraEnabled public Boolean isProduct {get; set;}
    @AuraEnabled public Boolean isRecipe {get; set;}
    @AuraEnabled public Integer id {get; set;}
    @AuraEnabled public Integer index {get; set;}
  }

  @AuraEnabled
  public static List<IngredientsSummaryInnerClass> summary(List<IngredientsInnerClass> listOfIngredients){
    List<IngredientsSummaryInnerClass> result = new List<IngredientsSummaryInnerClass>();
    Map<String, Decimal> recipes = new Map<String, Decimal>();
    Map<String, Decimal> products = new Map<String, Decimal>();

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

  @AuraEnabled
  public static List<IngredientLWCInnerClass> getIngredients(String recipeId){
    List<Ingredient__c> ingredients = [Select Id, Name, Quantity__c, Product__c, Related_Recipe__c from Ingredient__c where Related_Recipe__c =: recipeId];
    List<IngredientLWCInnerClass> result = new List<IngredientLWCInnerClass>();
    Integer idCount = 0;
    Integer indexCount = 1;
    for (Ingredient__c i : ingredients) {
      IngredientLWCInnerClass innerClass = new IngredientLWCInnerClass();
      innerClass.name = i.Product__c;
      innerClass.isProduct = true;
      innerClass.isRecipe = false;
      innerClass.quantity = i.Quantity__c;
      innerClass.id = idCount;
      innerClass.index = indexCount;
      result.add(innerClass);
      idCount++;
      indexCount++;
    }
    return result;
  }

  @AuraEnabled
  public static String getRecipeName(String recipeId){
    Recipe__c recipe = [Select Id, Name from Recipe__c where Id =: recipeId];
    return recipe.Name;
  }

  @AuraEnabled
  public static void updateRecipe(String recipeId, String editRecipeName, List<IngredientsSummaryInnerClass> listOfIngredients){
    List<Ingredient__c> ingredients = [Select Id, Name, Quantity__c, Product__c, Related_Recipe__c from Ingredient__c where Related_Recipe__c =: recipeId];
    delete ingredients;

    List<Ingredient__c> updateIngredients = new List<Ingredient__c>();

    for (IngredientsSummaryInnerClass i : listOfIngredients) {
      Ingredient__c ingredient = new Ingredient__c();
      ingredient.Name = editRecipeName + ': ' + i.productName;
      ingredient.Product__c = i.productId;
      ingredient.Quantity__c = i.quantity;
      ingredient.Related_Recipe__c = recipeId;
      updateIngredients.add(ingredient);
    }

    System.debug(updateIngredients);
    insert updateIngredients;
  }
}