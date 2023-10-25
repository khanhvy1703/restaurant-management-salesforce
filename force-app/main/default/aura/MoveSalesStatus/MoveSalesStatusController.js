({
	doInit: function (component, event, helper) { 
		helper.getOpp(component);
	},

	change: function (component, event, helper) {
		helper.changeStatus(component, event, helper);
	}
})
