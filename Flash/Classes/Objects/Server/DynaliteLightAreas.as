class Objects.Server.DynaliteLightAreas extends Objects.BaseElement {
	private var container:String;
	private var lightAreas:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var lightArea in lightAreas){
			tempKeys.push(lightAreas[lightArea].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var lightArea in lightAreas) {
			if ((lightAreas[lightArea].attributes["ACTIVE"] != "Y") && (lightAreas[lightArea].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((lightAreas[lightArea].attributes["KEY"] == undefined) || (lightAreas[lightArea].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((lightAreas[lightArea].attributes["NAME"] == undefined) || (lightAreas[lightArea].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((lightAreas[lightArea].attributes["DISPLAY_NAME"] == undefined) || (lightAreas[lightArea].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.dynalitelightAreas";
	}
	public function toXML():XMLNode {
		var lightAreasNode = new XMLNode(1, container);
		for (var lightArea in lightAreas) {
			var newLightArea = new XMLNode(1, "LIGHT_DYNALITE_AREA");
			if (lightAreas[lightArea].name != "") {
				newLightArea.attributes["NAME"] = lightAreas[lightArea].name;
			}
			if (lightAreas[lightArea].display_name != "") {
				newLightArea.attributes["DISPLAY_NAME"] = lightAreas[lightArea].display_name;
			}
			if (lightAreas[lightArea].key != "") {
				newLightArea.attributes["KEY"] = lightAreas[lightArea].key;
			}
			if (lightAreas[lightArea].active != "") {
				newLightArea.attributes["ACTIVE"] = lightAreas[lightArea].active;
			}
			lightAreasNode.appendChild(newLightArea);
		}
		return lightAreasNode;
	}
	public function getName():String {
		return "Light Areas";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("DynaliteLightAreas",newNode);
		return newNode;
	}
	public function setData(newData:Object){
		lightAreas = newData.lightAreas;
	}
	public function getData():Object {
		return {lightAreas:lightAreas};
	}
	public function setXML(newData:XMLNode):Void {
		lightAreas = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newLightArea = new Object();
			newLightArea.name = "";
			newLightArea.display_name = "";
			newLightArea.key = "";
			newLightArea.active = "Y";
			newLightArea.box = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newLightArea.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newLightArea.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newLightArea.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newLightArea.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["BOX"] != undefined) {
				newLightArea.box = newData.childNodes[child].attributes["BOX"];
			}
			lightAreas.push(newLightArea);
		}
	}
}
