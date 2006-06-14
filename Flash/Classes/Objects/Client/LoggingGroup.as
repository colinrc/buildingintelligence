class Objects.Client.LoggingGroup extends Objects.BaseElement {
	private var name:String;
	private var icon:String;
	private var type:String;
	private var listenTo:String;
	private var controls:Array;
	private var attributes:Array;
	private var treeNode:XMLNode;
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (controls.length == 0) {
			flag = "empty";
			appendValidationMsg("No Keys are being used");
		}
		if ((listenTo == undefined) || (listenTo == "")) {
			flag = "empty";
			appendValidationMsg("Listen to is empty");
		}
		if ((name == undefined) || (name == "")) {
			flag = "warning";
			appendValidationMsg("Name is empty");
		}
		if ((icon == undefined) || (icon == "")) {
			flag = "warning";
			appendValidationMsg("Icon is invalid");
		}
		if ((type == undefined) || (type == "")) {
			flag = "warning";
			appendValidationMsg("Type is invalid");
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.logginggroup";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "group");
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (icon != "") {
			newNode.attributes["icon"] = icon;
		}
		if (type != "") {
			newNode.attributes["type"] = type;
		}
		if (listenTo != "") {
			newNode.attributes["listenTo"] = listenTo;
		}
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		for (var control in controls) {
			newNode.appendChild(controls[control]);
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
		return "LoggingGroup";
	}
	public function getName():String {
		return "Group: " + name;
	}
	public function getData():Object {
		return {controls:controls, icon:icon, name:name, listenTo:listenTo, type:type, attributes:attributes, dataObject:this};
	}
	public function setData(newData:Object):Void {
		controls = newData.controls;
		name = newData.name;
		icon = newData.icon;
		listenTo = newData.listenTo;
		type = newData.type;
		attributes = newData.attributes;
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		icon = "";
		listenTo = "";
		type = "";
		controls = new Array();
		attributes = new Array();
		if (newData.nodeName = "group") {
			for (var attribute in newData.attributes) {
				switch (attribute) {
				case "name" :
					name = newData.attributes[attribute];
					break;
				case "icon" :
					icon = newData.attributes[attribute];
					break;
				case "listenTo" :
					listenTo = newData.attributes[attribute];
					break;
				case "type" :
					type = newData.attributes[attribute];
					break;
				default :
					attributes.push({name:attribute, value:newData.attributes[attribute]});
					break;
				}
			}
			for (var child in newData.childNodes) {
				controls.push(newData.childNodes[child]);
			}
		} else {
			trace("Error, received " + newData.nodeName + ", was expecting group");
		}
	}
	public function getUsedKeys():Array {
		usedKeys = new Array();
		for (var cont in controls) {
			if ((controls[cont].attributes["key"] != "") && (controls[cont].attributes["key"] != undefined)) {
				addUsedKey(controls[cont].attributes["key"]);
			}
		}
		return usedKeys;
	}
	public function getIcons():Array {
		usedIcons = new Array();
		if (icon != "" && icon != undefined) {
			addIcon(icon);
		}
		return usedIcons;
	}
}
