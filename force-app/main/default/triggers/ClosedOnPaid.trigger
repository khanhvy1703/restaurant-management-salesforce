trigger ClosedOnPaid on Opportunity (before update) {
  if (!StaticVariables.CarTriggerTrainingTriggerExecuted) {
    for (Opportunity opp : Trigger.new) {
      Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
      if (opp.Paid__c && !oldOpp.Paid__c) {
        opp.StageName = 'Closed Won';
        opp.Order_Status__c = 'Delivered';
        opp.CloseDate = System.now().date();
        CatFactController.getCatFact(opp.Id);
      }
    }
    StaticVariables.CarTriggerTrainingTriggerExecuted = true;
  }
}