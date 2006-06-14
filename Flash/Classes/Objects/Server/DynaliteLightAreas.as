class Objects.Server.DynaliteLightAreas extends Objects.BaseElement {
	private var container:String;
	private var lightAreas:Array;
	private var treeNode:XMLNode;	
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var lightArea in lightAreas){
			tempKeys.push(lightAreas[lightArea].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var lightArea in lightAreas) {
			if ((lightAreas[lightArea].active != "Y") && (lightAreas[lightArea].active != "N")) {
				flag = "error";
				appendValidationMsg("Active Flag is invalid");
			} 
			else {
				if (lightAreas[lightArea].active =="Y"){
					if ((lightAreas[lightArea].name == undefined) || (lightAreas[lightArea].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((lightAreas[lightArea].key == undefined) || (lightAreas[lightArea].key == "")) {
						flag = "error";
						appendValidationMsg("Dynalite Code is empty");
					}
					if ((lightAreas[lightArea].display_name == undefined) || (lightAreas[lightArea].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyUsed(lightAreas[lightArea].display_name) == false) {
							flag = "error";
							appendValidationMsg(lightAreas[lightArea].display_name+" key is not used");
						}
					}
				}
				else {
					if (lightAreas[lightArea].active =="N"){
						flag = "empty";
						appendValidationMsg("Dynalite Light Areas is not active");
					}
				}
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
		return "Areas";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "DynaliteLightAreas";
	}
	public function setData(newData:Object){
		lightAreas = newData.lightAreas;
	}
	public function getData():Object {
		return {lightAreas:lightAreas, dataObject:this};
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
