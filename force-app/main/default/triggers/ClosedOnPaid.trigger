trigger ClosedOnPaid on Opportunity (before update) {
  if (!StaticVariables.CarTriggerTrainingTriggerExecuted) {
    for (Opportunity opp : Trigger.new) {
      Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
      if (opp.Paid__c && !oldOpp.Paid__c) {
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.now().date();
      }
    }
    StaticVariables.CarTriggerTrainingTriggerExecuted = true;
  }
}