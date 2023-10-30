trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
  public static boolean runTrigger = true;
  if(runTrigger){
    if(trigger.isBefore){
      if(trigger.isInsert){
        AccountTriggerHandler.beforeInsert(trigger.new, trigger.newMap);
      }
      if(trigger.isUpdate){
        AccountTriggerHandler.beforeUpdate(trigger.new, trigger.newMap,trigger.old,trigger.oldMap);
      }
      if(trigger.isDelete){
        AccountTriggerHandler.beforeDelete(trigger.old,trigger.oldMap);
      }
    } 
    if(trigger.isAfter){
      if(trigger.isInsert){
        AccountTriggerHandler.afterInsert(trigger.new, trigger.newMap);
      }
      if(trigger.isUpdate){
        AccountTriggerHandler.afterUpdate(trigger.new, trigger.newMap,trigger.old,trigger.oldMap);
      }
      if(trigger.isDelete){
        AccountTriggerHandler.afterDelete(trigger.old,trigger.oldMap);
      }
    } 
  }
}