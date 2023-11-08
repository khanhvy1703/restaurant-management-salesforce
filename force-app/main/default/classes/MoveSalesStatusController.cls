public with sharing class MoveSalesStatusController {
  private static String Success_Label = System.Label.Success;
  private static String Fail_Label = System.Label.Fail;
  private static Map<String, String> orderNextStatus {get {
    Map<String, String> result = orderNextStatus;
    if (orderNextStatus == null) {
      result = new Map<String, String>();
      for(Order_Status_Setting__mdt setting: [select Current_Status__c, Next_Status__c from Order_Status_Setting__mdt]) {
        result.put(setting.Current_Status__c, setting.Next_Status__c);
      }
    }
    return result;
  }}

  @AuraEnabled
  public static Opportunity getOppApex(String oppId){
    return [select Id, Name, Order_Status__c from Opportunity where Id =: oppId];
  }

  @AuraEnabled
  public static String changeStatusApex(String oppId){
    String result = '';
    System.debug(oppId);
    Opportunity updateOpp = [
      select Id, Order_Status__c, Ordered_Entry_Time__c, Preparing_Entry_Time__c, Ready_Entry_Time__c, Delivered_Entry_Time__c,
             Ordered_Status_Time_Tracker__c, Preparing_Status_Time_Tracker__c, Ready_Status_Time_Tracker__c, Delivered_Status_Time_Tracker__c
      from Opportunity 
      where id =: oppId
    ];
    System.debug(orderNextStatus);
    System.debug(updateOpp);
    if(orderNextStatus.containsKey(updateOpp.Order_Status__c))  {
      if (orderNextStatus.get(updateOpp.Order_Status__c) == 'Preparing') {
        updateOpp.Preparing_Entry_Time__c = System.now();
        Long preparingTime = DateTime.now().getTime() ;
        Long orderedTime = updateOpp.Ordered_Entry_Time__c.getTime();
        Long milliseconds = preparingTime - orderedTime;
        Long timeDifference = milliseconds / 1000;

        Integer hours = Integer.valueOf(Math.mod(timeDifference, 86400) / 3600);
        Integer minutes = Integer.valueOf(Math.mod(timeDifference, 3600) / 60);
        Integer seconds = Integer.valueOf(Math.mod(timeDifference, 60));

        updateOpp.Ordered_Status_Time_Tracker__c = String.valueOf(hours) + ':' + String.valueOf(minutes) + ':' + String.valueOf(seconds);

      } if (orderNextStatus.get(updateOpp.Order_Status__c) == 'Ready') {
        updateOpp.Ready_Entry_Time__c = System.now();
        Long readyTime = DateTime.now().getTime() ;
        Long preparingTime = updateOpp.Preparing_Entry_Time__c.getTime();
        Long milliseconds = readyTime - preparingTime;
        Long timeDifference = milliseconds / 1000;

        Integer hours = Integer.valueOf(Math.mod(timeDifference, 86400) / 3600);
        Integer minutes = Integer.valueOf(Math.mod(timeDifference, 3600) / 60);
        Integer seconds = Integer.valueOf(Math.mod(timeDifference, 60));

        updateOpp.Preparing_Status_Time_Tracker__c = String.valueOf(hours) + ':' + String.valueOf(minutes) + ':' + String.valueOf(seconds);

      } if (orderNextStatus.get(updateOpp.Order_Status__c) == 'Delivered') {
        updateOpp.Delivered_Entry_Time__c = System.now();
        Long deliveredTime = DateTime.now().getTime() ;
        Long readyTime = updateOpp.Ready_Entry_Time__c.getTime();
        Long milliseconds = deliveredTime - readyTime;
        Long timeDifference = milliseconds / 1000;

        Integer hours = Integer.valueOf(Math.mod(timeDifference, 86400) / 3600);
        Integer minutes = Integer.valueOf(Math.mod(timeDifference, 3600) / 60);
        Integer seconds = Integer.valueOf(Math.mod(timeDifference, 60));

        updateOpp.Ready_Status_Time_Tracker__c = String.valueOf(hours) + ':' + String.valueOf(minutes) + ':' + String.valueOf(seconds);

      }
      updateOpp.Order_Status__c = orderNextStatus.get(updateOpp.Order_Status__c);
      update updateOpp;
      result = Success_Label.replace('{0}', updateOpp.Order_Status__c);
    } else {
      result = Fail_Label;
    }

    return result;
  }

  @AuraEnabled
  public static void cancelOrderApex(String oppId){
    //String result = '';
    Opportunity updateOpp = [select Id, Order_Status__c, Canceled_Approval_Waiting__c from Opportunity where id =: oppId];
    updateOpp.Canceled_Approval_Waiting__c = true;
    update updateOpp;

    Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
    approvalReq.setObjectId(oppId);
    approvalReq.setComments('Submitting request for approval.');
    Approval.ProcessResult result = Approval.process(approvalReq);
    System.debug(result);
  }
  
  @AuraEnabled
  public static Boolean getCancelStatus(String oppId){
    Opportunity updateOpp = [select Id, Order_Status__c, Canceled_Approval_Waiting__c, StageName from Opportunity where id =: oppId];
    return updateOpp.Order_Status__c == 'Canceled' 
    || updateOpp.Canceled_Approval_Waiting__c
    || updateOpp.StageName == 'Closed Won'
    || updateOpp.StageName == 'Closed Lost';
  }

  @AuraEnabled
  public static Integer getDurationApex(String oppId){
    Opportunity opp = [select Id, CreatedDate from Opportunity where id =: oppId];
    Long timeDifference = (System.now().getTime() - opp.CreatedDate.getTime()) / 1000;
    System.debug(timeDifference);
    Integer minutes = Integer.valueOf(timeDifference/60);
    System.debug(minutes);
    return minutes;
  }
}