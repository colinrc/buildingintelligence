﻿class Objects.Server.GC100_Relay extends Objects.BaseElement {
	private var type:String = "GC100_Relay";
	private var name:String;
	private var toggle_outputs:Objects.Server.Toggles;
	private var parameters:XMLNode;
	public function isValid():Boolean {
		var flag = true;
		if ((name == undefined) || (name == "")) {
			flag = false;
		}
		if (!toggle_outputs.isValid()) {
			flag = false;
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100_relay";
	}
	public function toXML():XMLNode {
		var newDevice = new XMLNode(1, type);
		newDevice.attributes["NAME"] = name;
		newDevice.appendChild(parameters);
		var tempToggleOutputs = toggle_outputs.toXML();
		for (var child in tempToggleOutputs.childNodes) {
			newDevice.appendChild(tempToggleOutputs.childNodes[child]);
		}
		return newDevice;
	}
	public function getName():String {
		return type+" : "+name;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(toggle_outputs.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({name:name, parameters:parameters});
	}
	public function setData(newData:Object):Void{
		name = newData.name;
		parameters = newData.parameters;
	}
	public function setXML(newData:XMLNode):Void {
		toggle_outputs = new Objects.Server.Toggles();
		if (newData.nodeName == "GC100_Relay") {
			name = newData.attributes["NAME"];
			var tempToggleOutputs = new XMLNode(1, "Toggle Outputs");
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "TOGGLE_OUTPUT" :
					tempToggleOutputs.appendChild(newData.childNodes[child]);
					break;
				case "PARAMETERS" :
					parameters = newData.childNodes[child];
					break;
				}
			}
			toggle_outputs.setXML(tempToggleOutputs);
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting GC100_Relay");
		}
	}
}
