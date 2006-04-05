class Objects.Client.AlertGroups extends Objects.BaseElement {
	var alertgroups:Array;
	var treeNode:XMLNode;
	var room:Object;
	public function AlertGroups() {
		alertgroups = new Array();				
	}
	public function isValid():String {
		/*Build validation array here*/
		var flag = "ok";
		for (var alertgroup in alertgroups) {
			if (!alertgroups[alertgroup].isValid()) {
				flag = "error";
			}
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
		return {alertgroups:alertgroups, dataObject:this, map:room.zone.map, poly:room.poly};
	}
	public function setData(newData:Object) {
		_global.left_tree.setIsOpen(treeNode, false);
		//process alertGroup changes
		var newAlertGroups = new Array();
		for (var index in newData.alertgroups) {
			if (newData.alertgroups[index].id == undefined) {
				newAlertGroups.push({x_pos:newData.alertgroups[index].x_pos, y_pos:newData.alertgroups[index].y_pos});
			}
		}
		for (var alertGroup in alertgroups) {
			var found = false;
			for (var index in newData.alertgroups) {
				if (alertgroups[alertGroup].id == newData.alertgroups[index].id) {
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
}
