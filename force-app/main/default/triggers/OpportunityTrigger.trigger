trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
  public static boolean runTrigger = true;
  if(runTrigger){
    if(trigger.isBefore){
      if(trigger.isInsert){
        OpportunityTriggerHandler.beforeInsert(trigger.new, trigger.newMap);
      }
      if(trigger.isUpdate){
        OpportunityTriggerHandler.beforeUpdate(trigger.new, trigger.newMap,trigger.old,trigger.oldMap);
      }
      if(trigger.isDelete){
        OpportunityTriggerHandler.beforeDelete(trigger.old,trigger.oldMap);
      }
    } 
    if(trigger.isAfter){
      if(trigger.isInsert){
        OpportunityTriggerHandler.afterInsert(trigger.new, trigger.newMap);
      }
      if(trigger.isUpdate){
        OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.newMap,trigger.old,trigger.oldMap);
      }
      if(trigger.isDelete){
        OpportunityTriggerHandler.afterDelete(trigger.old,trigger.oldMap);
      }
    } 
  }  
}