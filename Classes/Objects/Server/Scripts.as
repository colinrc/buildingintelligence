class Objects.Server.Scripts extends Objects.BaseElement {
	private var scriptInfo:Array = new Array();
	private var treeNode:XMLNode;	
/*	public function isValid():Boolean {
		var flag = "ok";
		clearValidationMsg();
		
		var autoClose:Boolean = false;
		var iconSet:Boolean = false;
		for (var child in settings.childNodes) {
			if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
				autoClose = true;
			}
			if (settings.childNodes[child].attributes["NAME"] == "ICON") {
				iconSet = true;
			}
		}
		if (autoClose == false) {
			flag = "error";
			appendValidationMsg("Autoclose is empty");
		}
		if (iconSet == false) {
			flag = "error";
			appendValidationMsg("Icon is empty");
		}
		return flag;
	}*/
	public function getForm():String {
		return "forms.project.script";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"SCRIPT_STATUS");
		for(var script in scriptInfo){
			var newScript = new XMLNode(1,"SCRIPT");
			newScript.attributes.NAME = scriptInfo[script].name;
			newScript.attributes.ENABLED = scriptInfo[script].enabled;
			if(scriptInfo[script].status != undefined){
				newScript.attributes.STATUS = scriptInfo[script].status;
			} else{
				newScript.attributes.STATUS = "";
			}
			newNode.appendChild(newScript);
		}
		return newNode;
	}
	public function getName():String {
		return "Scripts";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Scripts");
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Scripts";
	}
	public function getData():Object {
		return {scriptInfo:scriptInfo, dataObject:this};
	}
	public function setData(newData:Object):Void {
		scriptInfo = newData.scriptInfo;
	}
	public function setXML(newData:XMLNode):Void {
		scriptInfo = new Array();
		if (newData.nodeName == "SCRIPT_STATUS") {
			for(var child in newData.childNodes){
				var script = new Object;
				script.name = "";
				script.enabled = "";
				script.status = "";
				if(newData.childNodes[child].attributes["NAME"]!= undefined){
					script.name = newData.childNodes[child].attributes["NAME"];
				}
				if(newData.childNodes[child].attributes["ENABLED"]!= undefined){
					script.enabled = newData.childNodes[child].attributes["ENABLED"];
				}
				if(newData.childNodes[child].attributes["STATUS"]!= undefined){
					script.status = newData.childNodes[child].attributes["STATUS"];
				}
				scriptInfo.push(script);
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting SCRIPT_STATUS");
		}
	}
}