class Objects.Server.Controls extends Objects.BaseElement {
	private var variables:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var variable in variables.childNodes){
			tempKeys.push(variables.childNodes[variable].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var child in variables.childNodes) {
			if ((variables.childNodes[child].attributes["NAME"] == undefined) || (variables.childNodes[child].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((variables.childNodes[child].attributes["DISPLAY_NAME"] == undefined) || (variables.childNodes[child].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
			if ((variables.childNodes[child].attributes["ACTIVE"] != "Y") && (variables.childNodes[child].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.variables";
	}
	public function toXML():XMLNode {
		return variables;
	}
	public function getName():String {
		return "Variables";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Controls");
		newNode.object = this;
		_global.workflow.addNode("Controls",newNode);
		return newNode;
	}
	public function getData():Object {
		return new Object({variables:variables});
	}
	public function setData(newData:Object):Void {
		variables = newData.variables;
	}
	public function setXML(newData:XMLNode):Void {
		variables = new XMLNode();
		if (newData.nodeName == "VARIABLES") {
			variables = newData;
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting VARIABLES");
		}
	}
}
