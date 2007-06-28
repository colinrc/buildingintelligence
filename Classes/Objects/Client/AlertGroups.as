class Objects.Client.AlertGroups extends Objects.BaseElement {
	var alertgroups:Array;
	var treeNode:XMLNode;
	var room:Object;
	public function AlertGroups() {
		alertgroups = new Array();				
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (alertgroups.length == 0) {
			flag = "empty";
			appendValidationMsg("No AlertGroups are defined");
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.alertgroups";
	}
	public function setRoom(inRoom:Object) {
		room = inRoom;
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
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "AlertGroups";
	}
	public function getName():String {
		return "Alert Groups";
	}
	public function getData():Object {
		return {alertgroups:alertgroups, dataObject:this, map:room.zone.map, background:room.zone.background, poly:room.poly};
	}
	public function setData(newData:Object) {
		_global.left_tree.setIsOpen(treeNode, false);
		//process alertGroup changes
		var newAlertGroups = new Array();
		for (var index in newData.alertgroups) {
			if (newData.alertgroups[index].id == undefined) {
				newAlertGroups.push({name:newData.alertgroups[index].name, x_pos:newData.alertgroups[index].x_pos, y_pos:newData.alertgroups[index].y_pos});
			}
		}
		for (var alertGroup in alertgroups) {
			var found = false;
			for (var index in newData.alertgroups) {
				if (alertgroups[alertGroup].id == newData.alertgroups[index].id) {
					alertgroups[alertGroup].name = newData.alertgroups[index].name;
					alertgroups[alertGroup].x_pos = newData.alertgroups[index].x_pos;
					alertgroups[alertGroup].y_pos = newData.alertgroups[index].y_pos;
					found = true;
				}
			}
			if (found == false) {
				alertgroups[alertGroup].deleteSelf();
				alertgroups.splice(parseInt(alertGroup), 1);
			}
		}
		for (var AlertGroup in newAlertGroups) {
			var newNode = new XMLNode(1, "alerts");
			newNode.attributes["name"] = newAlertGroups[AlertGroup].name;
			newNode.attributes["x"] = newAlertGroups[AlertGroup].x_pos;
			newNode.attributes["y"] = newAlertGroups[AlertGroup].y_pos;
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newNode);
			newAlertGroup.id = _global.formDepth++;
			treeNode.appendChild(newAlertGroup.toTree());
			alertgroups.push(newAlertGroup);
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
	public function setXML(newData:XMLNode):Void {
		for (var child in newData.childNodes) {
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newData.childNodes[child]);
			newAlertGroup.id = _global.formDepth++;
			alertgroups.push(newAlertGroup);
		}
	}
	public function getUsedKeys():Array{
		usedKeys = new Array();
		for (var alerts in alertgroups) {
			usedKeys=usedKeys.concat(alertgroups[alerts].getUsedKeys());
		}
		return usedKeys;
	}
	public function getIcons():Array{
		usedIcons = new Array();
		for (var alerts in alertgroups) {
			//var newAlerts = new Objects.Client.Alerts();
			usedIcons=usedIcons.concat(alertgroups[alerts].getIcons());
		}
		return usedIcons;
	}
}
