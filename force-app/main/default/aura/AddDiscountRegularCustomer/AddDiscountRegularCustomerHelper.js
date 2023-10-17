({
	doInit: function (component, event, helper) {
		var action = component.get("c.checkDiscountApex");

		action.setCallback(this, function (a) {
			console.log(a);
			if (a.getState() === "SUCCESS") {
				console.log(a.getReturnValue());
				component.set("v.addDiscount", a.getReturnValue());
				component.set("v.removeDiscount", !a.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	},

	add: function (component, event, helper) {
		var action = component.get("c.addRegularDiscountApex");

		action.setCallback(this, function (a) {
			console.log(a);
			if (a.getState() === "SUCCESS") {
				component.set("v.addDiscount", true);
				component.set("v.removeDiscount", false);
			}
		});

		$A.enqueueAction(action);
	},

	remove: function (component, event, helper) {
		var action = component.get("c.removeRegularDiscountApex");

		action.setCallback(this, function (a) {
			console.log(a);
			if (a.getState() === "SUCCESS") {
				component.set("v.addDiscount", false);
				component.set("v.removeDiscount", true);
			}
		});

		$A.enqueueAction(action);
	}
})
