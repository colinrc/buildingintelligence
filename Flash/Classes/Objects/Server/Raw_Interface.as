class Objects.Server.Raw_Interface extends Objects.BaseElement {
	private var type = "RAW_INTERFACE";
	private var name:String;
	private var display_name:String;
	private var power:String;
	private var customs:Objects.Server.Customs;
	private var raw_items:Objects.Server.Raw_Items;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(customs.getKeys());
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
		if (!customs.isValid()) {
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
		newRawInterface.attributes["NAME"] = name;
		newRawInterface.attributes["DISPLAY_NAME"] = display_name;
		newRawInterface.attributes["POWER_RATING"] = power;
		var tempCustoms = customs.toXML();
		for (var child in tempCustoms.childNodes) {
			newRawInterface.appendChild(tempCustoms.childNodes[child]);
		}
		var tempRaw_Items = raw_items.toXML();
		for (var child in tempRaw_Items.childNodes) {
			newRawInterface.appendChild(tempRaw_Items.childNodes[child]);
		}
		return newRawInterface;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Raw Interface");
		newNode.appendChild(customs.toTree());
		newNode.appendChild(raw_items.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "RAW INTERFACE: "+name;
	}
	public function getData():Object {
		return new Object({display_name:display_name, name:name, power:power});
	}
	public function setData(newData:Object){
		display_name = newData.display_name;
		name = newData.name;
		power = newData.power;
	}
	public function setXML(newData:XMLNode):Void {
		name = newData.attributes["NAME"];
		display_name = newData.attributes["DISPLAY_NAME"];
		power = newData.attributes["POWER_RATING"];
		raw_items = new Objects.Server.Raw_Items();
		customs = new Objects.Server.Customs();
		var tempCustomInputs = new XMLNode(1, type);
		var tempRawItems = new XMLNode(1, type);
		for (var child in newData.childNodes) {
			switch (newData.childNodes[child].nodeName) {
			case "CUSTOM_INPUT" :
				tempCustomInputs.appendChild(newData.childNodes[child]);
				break;
			case "RAW_ITEMS" :
				tempRawItems.appendChild(newData.childNodes[child]);
				break;
			}
		}
		customs.setXML(tempCustomInputs);
		raw_items.setXML(tempRawItems);
	}
}
