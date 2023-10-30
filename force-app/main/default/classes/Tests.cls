@isTest
private with sharing class Tests {
	static testMethod void testLoadDiscountSetting() {
		Test.startTest();
    AddDiscountRegularCustomerController.loadDiscountSetting();
    System.assertEquals(5, AddDiscountRegularCustomerController.discount, 'Should added discount of 5%');
		Test.stopTest();
  }

	static testMethod void testCheckDiscountApex() {
		Test.startTest();		

		Account testAccount = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = true
		);
		insert testAccount;

    Boolean result = AddDiscountRegularCustomerController.checkDiscountApex();
		System.assertEquals(true, result, 'should have regular discount');

		delete testAccount;
		Account testAccount2 = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = false
		);
		insert testAccount2;

		Boolean result2 = AddDiscountRegularCustomerController.checkDiscountApex();
		System.assertEquals(false, result2, 'should have regular discount');

		Test.stopTest();
  }

	static testMethod void testAddRegularDiscountApex() {
		Test.startTest();
		Account testAccount2 = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = false
		);
		insert testAccount2;

		List<Account> result = AddDiscountRegularCustomerController.addRegularDiscountApex();
		for (Account a : result) {
			System.assertEquals(false, a.VIP__c, 'not VIP acc');
			System.assertEquals(true, a.Is_Regular_Discount_Added__c, 'add regular discount');
			System.assertEquals(5, a.Discount__c, '5% discount added');
		}

		Test.stopTest();
	}

	static testMethod void testRemoveRegularDiscountApex() {
		Test.startTest();
		Account testAccount2 = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = true,
			Discount__c = 5
		);
		insert testAccount2;

		List<Account> result = AddDiscountRegularCustomerController.removeRegularDiscountApex();
		for (Account a : result) {
			System.assertEquals(false, a.VIP__c, 'not VIP acc');
			System.assertEquals(false, a.Is_Regular_Discount_Added__c, 'removed regular discount');
			System.assertEquals(0, a.Discount__c, 'no discount');
		}

		Test.stopTest();
	}
}