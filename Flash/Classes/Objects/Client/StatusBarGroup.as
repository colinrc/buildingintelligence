class Objects.Client.StatusBarGroup extends Objects.BaseElement {
	private var name:String;
	private var icon:String;
	private var show:String;
	private var hide:String;
	private var controls:Array;
	private var attributes:Array;
	private var canOpen:String;
	private var treeNode:XMLNode;
	private var attributeGroups = ["window"];
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (name == null || name == "") {
			flag = "warning";
			appendValidationMsg("Name is missing");
		}
		if (icon == null || icon == "") {
			flag = "warning";
			appendValidationMsg("Icon is missing");
		}
		if (show == null || show == "") {
			flag = "warning";
			appendValidationMsg("Show is missing");
		}
		if (hide == null || hide == "") {
			flag = "warning";
			appendValidationMsg("Hide is missing");
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
			}
			else {
				if (_global.isKeyValid(controls[cont].attributes["key"]) == false) {
					flag = "error";
					appendValidationMsg("Key has changed and is invalid");
				}
			}
		}
		
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.statusbargroup";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "group");
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (icon != "") {
			newNode.attributes["icon"] = icon;
		}
		if (show != "") {
			newNode.attributes["show"] = show;
		}
		if (hide != "") {
			newNode.attributes["hide"] = hide;
		}
		newNode.attributes["canOpen"] = canOpen;
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
		return "StatusBarGroup";
	}
	public function getName():String {
		return "Group: " + name;
	}
	public function getData():Object {
		return {controls:controls, icon:icon, name:name, show:show, hide:hide, canOpen:canOpen, dataObject:this};
	}
	public function getAttributes():Array {
		return attributes;
	}
	public function setAttributes(newAttributes:Array) {
		attributes = newAttributes;
	}
	public function setData(newData:Object):Void {
		controls = newData.controls;
		name = newData.name;
		icon = newData.icon;
		show = newData.show;
		hide = newData.hide;
		canOpen = newData.canOpen;
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		icon = "";
		show = "";
		hide = "";
		canOpen = "";
		controls = new Array();
		attributes = new Array();
		if (newData.nodeName = "group") {
			for (var attribute in newData.attributes) {
				switch (attribute) {
				case "name" :
					if (newData.attributes[attribute] != undefined) {
						name = newData.attributes[attribute];
					}
					break;
				case "icon" :
					if (newData.attributes[attribute] != undefined) {
						icon = newData.attributes[attribute];
					}
					break;
				case "show" :
					if (newData.attributes[attribute] != undefined) {
						show = newData.attributes[attribute];
					}
					break;
				case "hide" :
					if (newData.attributes[attribute] != undefined) {
						hide = newData.attributes[attribute];
					}
					break;
				case "canOpen" :
					canOpen = newData.attributes[attribute];
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
	public function getUsedKeys():Array{
		for (var control in controls) {
			if ((controls[control].attributes["key"] != "") && (controls[control].attributes["key"] != undefined)) {
				addUsedKey(controls[control].attributes["key"]);
			}
		}
		return super.getUsedKeys();
	}
	public function getIcons():Array{
		if (icon != "" && icon != undefined){
			addIcon(icon);
		}
		return super.getIcons();
	}
}
