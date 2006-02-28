class Objects.Server.DynaliteIRs extends Objects.BaseElement {
	private var container:String;
	private var irs:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var ir in irs){
			tempKeys.push(irs[ir].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var ir in irs) {
			if ((irs[ir].attributes["ACTIVE"] != "Y") && (irs[ir].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((irs[ir].attributes["KEY"] == undefined) || (irs[ir].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((irs[ir].attributes["BOX"] == undefined) || (irs[ir].attributes["BOX"] == "")) {
				flag = false;
			}			
			if ((irs[ir].attributes["NAME"] == undefined) || (irs[ir].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((irs[ir].attributes["DISPLAY_NAME"] == undefined) || (irs[ir].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.dynaliteirs";
	}
	public function toXML():XMLNode {
		var irsNode = new XMLNode(1, container);
		for (var ir in irs) {
			var newIR = new XMLNode(1, "IR");
			if (irs[ir].name != "") {
				newIR.attributes["NAME"] = irs[ir].name;
			}
			if (irs[ir].display_name != "") {
				newIR.attributes["DISPLAY_NAME"] = irs[ir].display_name;
			}
			if (irs[ir].key != "") {
				newIR.attributes["KEY"] = irs[ir].key;
			}
			if (irs[ir].active != "") {
				newIR.attributes["ACTIVE"] = irs[ir].active;
			}
			if (irs[ir].box != "") {
				newIR.attributes["BOX"] = irs[ir].box;
			}
			irsNode.appendChild(newIR);
		}
		return irsNode;
	}
	public function getName():String {
		return "IRs";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("DynaliteIRs",newNode);
		return newNode;
	}
	public function setData(newData:Object){
		irs = newData.irs;
	}
	public function getData():Object {
		return {irs:irs};
	}
	public function setXML(newData:XMLNode):Void {
		irs = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newIR = new Object();
			newIR.name = "";
			newIR.display_name = "";
			newIR.key = "";
			newIR.active = "Y";
			newIR.box = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newIR.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newIR.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newIR.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newIR.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["BOX"] != undefined) {
				newIR.box = newData.childNodes[child].attributes["BOX"];
			}
			irs.push(newIR);
		}
	}
}
