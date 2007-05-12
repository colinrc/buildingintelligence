class Objects.Client.Tab extends Objects.BaseElement {
	private var controls:Array;
	private var name:String;
	private var icon:String;
	private var attributes:Array;
	private var attributeGroups = ["tabs"];
	private var treeNode:XMLNode;
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (controls.length == 0) {
			flag = "empty";
			appendValidationMsg("No Controls are defined");
		}
		if (name == null || name == "") {
			flag = "warning";
			appendValidationMsg("Name is empty");
		}
		if (icon == null || icon == "") {
			flag = "warning";
			appendValidationMsg("Icon is missing");
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.tab";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "tab");
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (icon != "") {
			newNode.attributes["icon"] = icon;
		}
		for (var control in controls) {
			newNode.appendChild(controls[control]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Tab");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "ClientTab";
	}
	public function getName():String {
		return "Tab : " + name;
	}
	public function getData():Object {
		return {controls:controls, name:name, icon:icon, dataObject:this};
	}
	public function getAttributes():Array {
		return attributes;
	}
	public function setAttributes(newAttributes:Array) {
		attributes = newAttributes;
	}
	public function setXML(newData:XMLNode):Void {
		attributes = new Array();
		name = "";
		icon = "";
		if (newData.nodeName == "tab") {
			for (var attribute in newData.attributes) {
				switch (attribute) {
				case "name" :
					name = newData.attributes["name"];
					break;
				case "icon" :
					icon = newData.attributes["icon"];
					break;
				default :
					attributes.push({name:attribute, value:newData.attributes[attribute]});
					break;
				}
			}
			controls = new Array();
			for (var child in newData.childNodes) {
				controls.push(newData.childNodes[child]);
			}
		} else {
			trace("Error, found " + newData.nodeName + ", was expecting tab");
		}
	}
	public function setData(newData:Object):Void {
		controls = newData.controls;
		name = newData.name;
		icon = newData.icon;
	}
	public function getUsedKeys():Array {
		usedKeys = new Array();
		for (var control in controls) {
			if ((controls[control].attributes["key"] != "") && (controls[control].attributes["key"] != undefined)) {
				addUsedKey(controls[control].attributes["key"]);
			}
		}
		return usedKeys;
	}
	public function getIcons():Array {
		usedIcons = new Array();
		if (icon != "" && icon != undefined) {
			addIcon(icon);
		}
		for (var control in controls) {
			if ((controls[control].attributes["icons"] != "") && (controls[control].attributes["icons"] != undefined)) {
				var tempIcons = controls[control].attributes["icons"].split(",");
				for (var tempIcon in tempIcons) {
					if (tempIcons[tempIcon].length) {
						addIcon(tempIcons[tempIcon]);
					}
				}
			}
		}
		return usedIcons;
	}
}
