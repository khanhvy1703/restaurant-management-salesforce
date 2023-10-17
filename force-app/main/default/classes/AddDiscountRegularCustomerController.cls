public with sharing class AddDiscountRegularCustomerController {
  public static Restaurant_Discount__mdt setting;
  public static Decimal discount;
    
  public static void loadDiscountSetting() {
    setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'Regular_Discount' limit 1];
    System.debug(setting.Percentage__c);
    if(setting != null) {
      discount = setting.Percentage__c; 
    } else {
      discount = 0;
    }
    System.debug(discount);
  }

  @AuraEnabled
  public static Boolean checkDiscountApex(){
    Account acc = [Select Id, VIP__c, Is_Regular_Discount_Added__c from Account where VIP__c = false limit 1];
    if (acc.Is_Regular_Discount_Added__c) {
      return true;
    } else {
      return false;
    }
  }

  @AuraEnabled
  public static List<Account> addRegularDiscountApex() {
    loadDiscountSetting();
    List<Account> regularCustomers = [Select Id, VIP__c, Discount__c, Is_Regular_Discount_Added__c from Account where VIP__c = false];
    for (Account a: regularCustomers) {
      a.Discount__c = discount;
      a.Is_Regular_Discount_Added__c = true;
    }
    System.debug(regularCustomers);
    update regularCustomers;
    return regularCustomers;
  }

  @AuraEnabled
  public static List<Account> removeRegularDiscountApex() {
    loadDiscountSetting();
    List<Account> regularCustomers = [Select Id, VIP__c, Discount__c, Is_Regular_Discount_Added__c from Account where VIP__c = false];
    for (Account a: regularCustomers) {
      a.Discount__c = 0;
      a.Is_Regular_Discount_Added__c = false;
    }
    System.debug(regularCustomers);
    update regularCustomers;
    return regularCustomers;
  }
}