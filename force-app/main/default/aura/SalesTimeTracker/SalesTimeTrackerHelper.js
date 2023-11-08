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

	getDuration: function (component, event, helper) {
		var action = component.get("c.getDurationApex");

		action.setParams({
			oppId: component.get("v.recordId")
		});

		action.setCallback(this, function (a) {
			if (a.getState() === "SUCCESS") {
				component.set("v.duration", a.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	}
})
