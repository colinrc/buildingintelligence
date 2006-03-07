class Objects.Client.AlertGroups extends Objects.BaseElement {
	var alertgroups:Array;
	private var treeNode:XMLNode;		
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
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String{
		return "AlertGroups";
	}	
	public function getName():String {
		return "Alert Groups";
	}
	public function getData():Object {
		return {alertgroups:alertgroups, dataObject:this};
	}
	public function setData(newData:Object) {
		_global.left_tree.setIsOpen(treeNode, false);
		//process alertGroup changes
		var newAlertGroups = new Array();
		for (var index in newData.alertgroups) {
			if (newData.alertgroups[index].id == undefined) {
				newAlertGroups.push({x_pos:newData.alertgroups[index].x_pos,y_pos:newData.alertgroups[index].y_pos});
			}
		}
		for (var alertGroup in alertgroups) {
			var found = false;
			for (var index in newData.alertgroups) {
				if (alertgroups[alertGroup].id == newData.alertgroups[index].id) {
					found = true;
				}
			}
			if (found == false) {
				alertgroups[alertGroup].deleteSelf();
				alertgroups.splice(parseInt(alertGroup), 1);
			}
		}
		for (var newAlertGroup in newAlertGroups) {
			var newNode = new XMLNode(1, "alerts");
			newNode.attributes["x"] = newAlertGroups[newAlertGroup].x_pos;
			newNode.attributes["y"] = newAlertGroups[newAlertGroup].y_pos;
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newNode);
			newAlertGroup.id = _global.formDepth++;			
			treeNode.appendChild(newAlertGroup.toTree());				
			alertgroups.push(newAlertGroup);
		}
		_global.left_tree.setIsOpen(treeNode, true);		
	}	
	public function setXML(newData:XMLNode):Void {
		alertgroups = new Array();
		for (var child in newData.childNodes) {
			var newAlertGroup = new Objects.Client.Alerts();
			newAlertGroup.setXML(newData.childNodes[child]);
			newAlertGroup.id = _global.formDepth++;
			alertgroups.push(newAlertGroup);
		}
	}
}
