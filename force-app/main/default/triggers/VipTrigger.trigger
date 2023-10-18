trigger VipTrigger on Account (before update) {
  Restaurant_Discount__mdt setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'VIP_Discount' limit 1];
	Decimal discount = 0;
  if(setting != null) {
    discount = setting.Percentage__c; 
  }

  if (!StaticVariables.CarTriggerTrainingTriggerExecuted) {
    for (Account a : Trigger.new) {
      Account oldAcc = Trigger.oldMap.get(a.Id);
      if (a.Total_Sale_Sets__c >= 100 && !a.VIP__c) {
        a.VIP__c = true;
        a.Discount__c = discount;
      }

      // Add Logic for testing ...
      if (oldAcc.Total_Sale_Sets__c > 100 && a.Total_Sale_Sets__c <= 100) {
        a.VIP__c = false;
        a.Discount__c = 0; // Reset the discount
      }
    }
    StaticVariables.CarTriggerTrainingTriggerExecuted = true;
  }

  // public static boolean runTrigger = true;
  // if(runTrigger) {
  //   if(trigger.isBefore) {
  //     if(trigger.isInsert) {
  //       VipTriggerHandler.beforeInsert(trigger.new, trigger.newMap);
  //     } if(trigger.isUpdate) {
  //       VipTriggerHandler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
  //     } if(trigger.isDelete) {
  //       VipTriggerHandler.beforeDelete(trigger.old, trigger.oldMap);
  //     }
  //   }
  //   if(trigger.isAfter) {
  //     if(trigger.isInsert) {
  //       VipTriggerHandler.afterInsert(trigger.new, trigger.newMap);
  //     } if(trigger.isUpdate) {
  //       VipTriggerHandler.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
  //     } if(trigger.isDelete) {
  //       VipTriggerHandler.afterDelete(trigger.old, trigger.oldMap);
  //     }
  //   }
  // }

}