@isTest
private with sharing class MoveSalesStatusControllerTest {
  @isTest
  static void testMoveSalesStatusController() {
    Account acc = new Account();
		acc.Name = 'Test Account';
		acc.Discount__c = 15;
		insert acc;

		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opp';
		opp.Pricebook2Id = Test.getStandardPricebookId();
		opp.StageName = 'Qualification';
		opp.CloseDate = System.now().date();
		opp.AccountId = acc.Id;
    opp.Order_Status__c = 'Ordered';
		insert opp;

    Test.startTest();
    MoveSalesStatusController.getOppApex(opp.Id);
    Opportunity getOpp = [select Id, Order_Status__c from Opportunity where Id =: opp.Id];
    System.assertEquals('Ordered', getOpp.Order_Status__c, 'initial order status is ordered');

    String result1 = MoveSalesStatusController.changeStatusApex(opp.Id);
    Opportunity updateeOpp = [select Id, Order_Status__c from Opportunity where Id =: opp.Id];
    System.assertEquals('Preparing', updateeOpp.Order_Status__c, 'preparing');
    System.assertEquals('Success. Status changed to Preparing', result1, 'success');

    String result2 = MoveSalesStatusController.changeStatusApex(opp.Id);
    Opportunity updateeOpp2 = [select Id, Order_Status__c from Opportunity where Id =: opp.Id];
    System.assertEquals('Ready', updateeOpp2.Order_Status__c, 'ready');
    System.assertEquals('Success. Status changed to Ready', result2, 'success');

    String result3 = MoveSalesStatusController.changeStatusApex(opp.Id);
    Opportunity updateeOpp3 = [select Id, Order_Status__c from Opportunity where Id =: opp.Id];
    System.assertEquals('Delivered', updateeOpp3.Order_Status__c, 'delivered');
    System.assertEquals('Success. Status changed to Delivered', result3, 'success');

    String result4 = MoveSalesStatusController.changeStatusApex(opp.Id);
    Opportunity updateeOpp4 = [select Id, Order_Status__c from Opportunity where Id =: opp.Id];
    System.assertEquals('Delivered', updateeOpp4.Order_Status__c, 'delivered');
    System.assertEquals('Error. Can not update order status', result4, 'error');

    MoveSalesStatusController.cancelOrderApex(opp.Id);
    Opportunity updateeOpp5 = [select Id, Order_Status__c, Canceled_Approval_Waiting__c from Opportunity where Id =: opp.Id];
    System.assertEquals('Delivered', updateeOpp5.Order_Status__c, 'delivered');
    System.assertEquals(true, updateeOpp5.Canceled_Approval_Waiting__c, 'checked');
    Boolean result5 = MoveSalesStatusController.getCancelStatus(opp.Id);
    System.assertEquals(true, result5, 'waiting approval reeq');

    Test.stopTest();
  }

  @isTest
  static void testGetCancelStatus(){
    Account acc = new Account();
		acc.Name = 'Test Account';
		acc.Discount__c = 15;
		insert acc;

		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opp';
		opp.Pricebook2Id = Test.getStandardPricebookId();
		opp.StageName = 'Closed Lost';
		opp.CloseDate = System.now().date();
		opp.AccountId = acc.Id;
		insert opp;

    Test.startTest();
    Boolean result = MoveSalesStatusController.getCancelStatus(opp.Id);
    System.assertEquals(true, result, 'canceled');
    Test.stopTest();
  }
}