class Objects.Client.AlertGroups extends Objects.BaseElement {
	var alertgroups:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var alertgroup in alertgroups) {
			if (!alertgroups[alertgroup].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.alertgroups";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "AlertGroups");
		for (var alertgroup in alertgroups) {
			newNode.appendChild(alertgroups[alertgroup].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "AlertGroups");
		for (var alertgroup in alertgroups) {
			newNode.appendChild(alertgroups[alertgroup].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Alert Groups";
	}
	public function getData():Object {
		return {alertgroups:alertgroups};
	}
	public function setData(newData:Object) {
		//process alertGroup changes
		var newAlertGroups = new Array();
		for (var index in newData.alertgroups) {
			var found = false;
			for (var alertGroup in alertgroups) {
				if ((alertgroups[alertGroup].x_pos == newData.alertgroups[index].x_pos)&&(alertgroups[alertGroup].y_pos == newData.alertgroups[index].y_pos)) {
					found = true;
				}
			}
			if (found == false) {
				newAlertGroups.push({x_pos:newData.alertgroups[index].x_pos,y_pos:newData.alertgroups[index].y_pos});
			}
		}
		var deletedAlertGroups = new Array();
		for (var alertGroup in alertgroups) {
			var found = false;
			for (var index in newData.alertgroups) {
				if ((alertgroups[alertGroup].x_pos == newData.alertgroups[index].x_pos)&&(alertgroups[alertGroup].y_pos == newData.alertgroups[index].y_pos)) {
					found = true;
				}
			}
			if (found == false) {
				alertgroups.splice(parseInt(alertGroup), 1);
			}
		}
		for (var newAlertGroup in newAlertGroups) {
			var newNode = new XMLNode(1, "alerts");
			newNode.attributes["x"] = newAlertGroups[newAlertGroup].x_pos;
			newNode.attributes["y"] = newAlertGroups[newAlertGroup].y_pos;
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newNode);
			alertgroups.push(newAlertGroup);
		}
	}	
	public function setXML(newData:XMLNode):Void {
		alertgroups = new Array();
		for (var child in newData.childNodes) {
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newData.childNodes[child]);
			alertgroups.push(newAlertGroup);
		}
	}
}
