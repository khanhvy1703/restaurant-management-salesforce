({
	doInit: function (component, event, helper) { 
		helper.getOpp(component);
		helper.cancelStatus(component);
	},

	change: function (component, event, helper) {
		helper.changeStatus(component, event, helper);
	},

	cancel: function (component, event, helper) {
		helper.cancelOrder(component, event, helper);
	}
})
