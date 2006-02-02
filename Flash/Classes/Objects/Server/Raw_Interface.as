class Objects.Server.Raw_Interface extends Objects.BaseElement {
	private var type = "RAW_INTERFACE";
	private var name:String;
	private var display_name:String;
	private var power:String;
	private var raw_items:Objects.Server.Raw_Items;
	public function getKeys():Array {
		var tempKeys = new Array();
		tempKeys.push(display_name);
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if ((name == undefined) || (name == "")) {
			flag = false;
		}
		if ((display_name == undefined) || (display_name == "")) {
			flag = false;
		}
		if (!raw_items.isValid()) {
			flag = false;
		}
		//need to isValid connection and parameters     
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw_interface";
	}
	public function toXML():XMLNode {
		var newRawInterface = new XMLNode(1, "RAW_INTERFACE");
		if (name != "") {
			newRawInterface.attributes["NAME"] = name;
		}
		if (display_name != "") {
			newRawInterface.attributes["DISPLAY_NAME"] = display_name;
		}
		if (power != "") {
			newRawInterface.attributes["POWER_RATING"] = power;
		}
		var tempRaw_Items = raw_items.toXML();
		for (var child in tempRaw_Items.childNodes) {
			newRawInterface.appendChild(tempRaw_Items.childNodes[child]);
		}
		return newRawInterface;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Raw Interface");
		newNode.appendChild(raw_items.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Custom Output: "+name;
	}
	public function getData():Object {
		return new Object({display_name:display_name, name:name, power:power});
	}
	public function setData(newData:Object) {
		display_name = newData.display_name;
		name = newData.name;
		power = newData.power;
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		display_name = "";
		power = "";
		if (newData.attributes["NAME"] != undefined) {
			name = newData.attributes["NAME"];
		}
		if (newData.attributes["DISPLAY_NAME"] != undefined) {
			display_name = newData.attributes["DISPLAY_NAME"];
		}
		if (newData.attributes["POWER_RATING"] != undefined) {
			power = newData.attributes["POWER_RATING"];
		}
		raw_items = new Objects.Server.Raw_Items();
		var tempCustomInputs = new XMLNode(1, type);
		var tempRawItems = new XMLNode(1, type);
		for (var child in newData.childNodes) {
			switch (newData.childNodes[child].nodeName) {
			case "RAW_ITEMS" :
				tempRawItems.appendChild(newData.childNodes[child]);
				break;
			}
		}
		raw_items.setXML(tempRawItems);
	}
}
