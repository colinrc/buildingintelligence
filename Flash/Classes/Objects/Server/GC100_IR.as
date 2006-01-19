class Objects.Server.GC100_IR extends Objects.BaseElement {
	private var type:String = "GC100_IR";
	private var name:String;
	private var irs:Objects.Server.IRs;
	private var toggle_inputs:Objects.Server.Toggles;
	private var parameters:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(irs.getKeys());
		tempKeys = tempKeys.concat(toggle_inputs.getKeys());
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if ((name == undefined) || (name == "")) {
			flag = false;
		}
		if (!irs.isValid()) {
			flag = false;
		}
		if (!toggle_inputs.isValid()) {
			flag = false;
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100ir";
	}
	public function toXML():XMLNode {
		var newDevice = new XMLNode(1, type);
		newDevice.attributes["NAME"] = name;
		newDevice.appendChild(parameters);
		var tempIRs = irs.toXML();
		for (var child in tempIRs.childNodes) {
			newDevice.appendChild(tempIRs.childNodes[child]);
		}
		var tempToggleInputs = toggle_inputs.toXML();
		for (var child in tempToggleInputs.childNodes) {
			newDevice.appendChild(tempToggleInputs.childNodes[child]);
		}
		return newDevice;
	}
	public function getName():String {
		return type+" : "+name;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(irs.toTree());
		newNode.appendChild(toggle_inputs.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({name:name, parameters:parameters});
	}
	public function setData(newData:Object){
		name = newData.name;
		parameters = newData.parameters;
	}
	public function setXML(newData:XMLNode):Void {
		irs = new Objects.Server.IRs();
		toggle_inputs = new Objects.Server.Toggles("TOGGLE_INPUT");
		if (newData.nodeName == "GC100_IR") {
			name = newData.attributes["NAME"];
			var tempIRs = new XMLNode(1, "irs");
			var tempToggleInputs = new XMLNode(1, "Toggle Inputs");
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "IR" :
					tempIRs.appendChild(newData.childNodes[child]);
					break;
				case "TOGGLE_INPUT" :
					tempToggleInputs.appendChild(newData.childNodes[child]);
					break;
				case "PARAMETERS" :
					parameters = newData.childNodes[child];
					break;
				}
			}
			irs.setXML(tempIRs);
			toggle_inputs.setXML(tempToggleInputs);
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting GC100_IR");
		}
	}
}
