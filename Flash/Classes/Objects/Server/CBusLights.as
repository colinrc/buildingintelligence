class Objects.Server.CBusLights extends Objects.BaseElement {
	private var container:String;
	private var lights:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var light in lights){
			tempKeys.push(lights[light].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var light in lights) {
			if ((lights[light].attributes["ACTIVE"] != "Y") && (lights[light].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((lights[light].attributes["KEY"] == undefined) || (lights[light].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((lights[light].attributes["CHANNEL"] == undefined) || (lights[light].attributes["CHANNEL"] == "")) {
				flag = false;
			}
			if ((lights[light].attributes["NAME"] == undefined) || (lights[light].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((lights[light].attributes["DISPLAY_NAME"] == undefined) || (lights[light].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.cbuslights";
	}
	public function toXML():XMLNode {
		var lightsNode = new XMLNode(1, container);
		for (var light in lights) {
			lightsNode.appendChild(lights[light]);
		}
		return lightsNode;
	}
	public function getName():String {
		return "Lights";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function setData(newData:Object){
		lights = newData.lights;
	}
	public function getData():Object {
		return new Object({lights:lights});
	}
	public function setXML(newData:XMLNode):Void {
		lights = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			lights.push(newData.childNodes[child]);
		}
	}
}
