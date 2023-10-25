({
	getOpp: function (component) {
		var action = component.get("c.getOppApex");

		action.setParams({
			oppId: component.get("v.recordId")
		});

		action.setCallback(this, function (a) {
			if (a.getState() === "SUCCESS") {
				component.set("v.record", a.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	},

	changeStatus: function (component, event, helper) {
		var action = component.get("c.changeStatusApex");

		action.setParams({
			oppId: component.get("v.recordId")
		});

		action.setCallback(this, function (a) {
			console.log(a.getState());
			console.log(a.getReturnValue());
			if (a.getState() === "SUCCESS") {
				var returnValue = a.getReturnValue();
				if (returnValue.includes("Success")) {
					helper.showToast(component, event, helper, "success", "Status Updated", returnValue);
					$A.get('e.force:refreshView').fire();
				} else {
					helper.showToast(component, event, helper, "error", "Status Not Updated", returnValue);
				}

			}
		});

		$A.enqueueAction(action);
	},

	showToast: function (component, event, helper, toastType, title, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": message,
			"type": toastType
		});
		toastEvent.fire();
	}
})
