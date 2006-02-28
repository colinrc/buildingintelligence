class Objects.Server.Toggles extends Objects.BaseElement {
	private var container:String;
	private var toggle_type:String;
	private var toggles:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var toggle in toggles){
			tempKeys.push(toggles[toggle].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function Toggles(inToggle_type:String) {
		toggle_type = inToggle_type;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var toggle in toggles) {
			if ((toggles[toggle].attributes["ACTIVE"] != "Y") && (toggles[toggle].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["KEY"] == undefined) || (toggles[toggle].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["NAME"] == undefined) || (toggles[toggle].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["DISPLAY_NAME"] == undefined) || (toggles[toggle].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.toggle";
	}
	public function toXML():XMLNode {
		var togglesNode = new XMLNode(1, container);
		for (var toggle in toggles) {
			var toggleNode = new XMLNode(1, toggle_type);
			if (toggles[toggle].name != "") {
				toggleNode.attributes["NAME"] = toggles[toggle].name;
			}
			if (toggles[toggle].key != "") {
				toggleNode.attributes["KEY"] = toggles[toggle].key;
			}
			if (toggles[toggle].display_name != "") {
				toggleNode.attributes["DISPLAY_NAME"] = toggles[toggle].display_name;
			}
			if (toggles[toggle].active != "") {
				toggleNode.attributes["ACTIVE"] = toggles[toggle].active;
			}
			if (toggles[toggle].power != "") {
				toggleNode.attributes["POWER_RATING"] = toggles[toggle].power;
			}
			togglesNode.appendChild(toggleNode);
		}
		return togglesNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("Toggles",newNode);
		return newNode;
	}
	public function getName():String {
		switch(toggle_type){
			case"TOGGLE_INPUT":
			return "Toggle Inputs";
			break;
			case"TOGGLE_OUTPUT":
			return "Toggle Outputs";
			break;
			case"PULSE_OUTPUT":
			return "Pulse Outputs";
			break;
		}
	}
	public function getData():Object {
		return new Object({toggles:toggles,toggle_type:toggle_type});
	}
	public function setData(newData:Object):Void{
		toggles = newData.toggles;
	}
	public function setXML(newData:XMLNode):Void {
		toggles = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newToggle = new Object();
			newToggle.name = "";
			newToggle.key = "";
			newToggle.display_name = "";
			newToggle.power = "";
			newToggle.active = "Y";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newToggle.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newToggle.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newToggle.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newToggle.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newToggle.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			toggles.push(newToggle);
		}
	}
}
