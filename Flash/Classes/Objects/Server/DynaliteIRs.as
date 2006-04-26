class Objects.Server.DynaliteIRs extends Objects.BaseElement {
	private var container:String;
	private var irs:Array;
	private var treeNode:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var ir in irs){
			tempKeys.push(irs[ir].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var ir in irs) {
			if ((irs[ir].active != "Y") && (irs[ir].active != "N")) {
				flag = "error";
				appendValidationMsg("Active Flag is invalid");
			}
			else {
				if (irs[ir].active =="Y"){
					if ((irs[ir].key == undefined) || (irs[ir].key == "")) {
						flag = "error";
						appendValidationMsg("Dynalite Code is invalid");
					}
					if ((irs[ir].box == undefined) || (irs[ir].box == "")) {
						flag = "error";
						appendValidationMsg("Box is invalid");
					}			
					if ((irs[ir].name == undefined) || (irs[ir].name == "")) {
						flag = "warning";
						appendValidationMsg("Description is invalid");
					}
					if ((irs[ir].display_name == undefined) || (irs[ir].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyUsed(irs[ir].display_name) == false) {
							flag = "error";
							appendValidationMsg(irs[ir].display_name+" key is not used");
						}
					}
				}
				else {
					if (irs[ir].active =="N"){
						flag = "empty";
						appendValidationMsg("Dynalite IRs is not active");
					}
				}
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
		return "IR Inputs";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "DynaliteIRs";
	}	
	public function setData(newData:Object){
		irs = newData.irs;
	}
	public function getData():Object {
		return {irs:irs, dataObject:this};
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
