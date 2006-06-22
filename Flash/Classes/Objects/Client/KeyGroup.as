class Objects.Client.KeyGroup extends Objects.BaseElement {
	private var name:String;
	private var icon1:String;
	private var icon2:String;
	private var controlType:String;
	private var treeNode:XMLNode;
	private var keys:Array;
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
/*		if (name == null || name == "") {
			flag = "warning";
			appendValidationMsg("Name is empty");
		}
		if (icon == null || icon == "") {
			flag = "warning";
			appendValidationMsg("Icon is missing");
		}
		if (show == null || show == "") {
			flag = "warning";
			appendValidationMsg("Show is empty");
		}
		if (hide == null || hide == "") {
			flag = "warning";
			appendValidationMsg("Hide is empty");
		}
		if (canOpen == null || canOpen == "") {
		flag = "warning";
		appendValidationMsg("Can Open is missing");
		}
		if (controls.length == 0) {
			flag = "error";
			appendValidationMsg("No Keys are used");
		}
		for (var cont in controls) {
			if (controls[cont].attributes["key"] == null || controls[cont].attributes["key"] == "") {
				flag = "error";
				appendValidationMsg("Key Name is missing");
			} else {
				if (_global.isKeyValid(controls[cont].attributes["key"]) == false) {
					flag = "error";
					appendValidationMsg("Key has changed and is invalid");
				}
			}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.keygroup";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "keygroup");
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (icon1 != "") {
			newNode.attributes["icon1"] = icon1;
		}
		if (icon2 != "") {
			newNode.attributes["icon2"] = icon2;
		}
		if (controlType != "") {
			newNode.attributes["controlType"] = controlType;
		}
		for(var key in keys){
			var newKeyNode = new XMLNode(1,"key");
			newKeyNode.attributes.name = keys[key];
			newNode.appendChild(newKeyNode);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getKey());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "KeyGroup";
	}
	public function getName():String {
		return "Key Group: " + name;
	}
	public function getData():Object {
		mdm.Dialogs.prompt(controlType);
		return {keys:keys, icon1:icon1, name:name, icon2:icon2, controlType:controlType, dataObject:this};
	}
	public function setData(newData:Object):Void {
		keys = newData.keys;
		name = newData.name;
		icon1 = newData.icon1;
		icon2 = newData.icon2;
		controlType = newData.controlType;
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		icon1 = "";
		icon2 = "";
		controlType = "";
		keys = new Array();
		if (newData.nodeName = "keygroup") {
			for (var attribute in newData.attributes) {
				switch (attribute) {
				case "name" :
					if (newData.attributes[attribute] != undefined) {
						name = newData.attributes[attribute];
					}
					break;
				case "icon1" :
					if (newData.attributes[attribute] != undefined) {
						icon1 = newData.attributes[attribute];
					}
					break;
				case "icon2" :
					if (newData.attributes[attribute] != undefined) {
						icon2 = newData.attributes[attribute];
					}
					break;
				case "controlType" :
					if (newData.attributes[attribute] != undefined) {
						controlType = newData.attributes[attribute];
					}
					break;
				}
			}
			for (var child in newData.childNodes) {
				keys.push(newData.childNodes[child].attributes.name);
			}
		} else {
			trace("Error, received " + newData.nodeName + ", was expecting keygroup");
		}
	}
}
