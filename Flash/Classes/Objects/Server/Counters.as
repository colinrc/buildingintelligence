class Objects.Server.Counters extends Objects.BaseElement {
	private var container:String;
	private var counters:Array;
	var treeNode:XMLNode;		
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var counter in counters){
			tempKeys.push(counters[counter].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var counter in counters) {
			if ((counters[counter].active != "Y") && (counters[counter].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			if (counters[counter].active =="Y"){
				if ((counters[counter].name == undefined) || (counters[counter].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((counters[counter].display_name == undefined) || (counters[counter].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
				else {
					if (_global.isKeyUsed(counters[counter].display_name) == false) {
						flag = "error";
						appendValidationMsg(counters[counter].display_name+" key is not used");
					}
				}
				if ((counters[counter].key == undefined) || (counters[counter].key == "")) {
					flag = "error";
					appendValidationMsg("Counter No. is empty");
				}
				if ((counters[counter].max == undefined) || (counters[counter].max == "")) {
					flag = "error";
					appendValidationMsg("Max is empty");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("Counters is not Active");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.counter";
	}
	public function toXML():XMLNode {
		var countersNode = new XMLNode(1, container);
		for (var counter in counters) {
			var newCounter = new XMLNode(1, "COUNTER");
			if (counters[counter].name != "") {
				newCounter.attributes["NAME"] = counters[counter].name;
			}
			if (counters[counter].display_name != "") {
				newCounter.attributes["DISPLAY_NAME"] = counters[counter].display_name;
			}
			if (counters[counter].key != "") {
				newCounter.attributes["KEY"] = parseInt(counters[counter].key).toString(16);
			}
			if (counters[counter].active != "") {
				newCounter.attributes["ACTIVE"] = counters[counter].active;
			}
			if (counters[counter].max != "") {
				newCounter.attributes["MAX"] = counters[counter].max;
			}
			if (counters[counter].power != "") {
				newCounter.attributes["POWER_RATING"] = counters[counter].power;
			}
			countersNode.appendChild(newCounter);
		}
		return countersNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Counters";
	}
	public function getName():String {
		return "Counters";
	}
	public function getData():Object {
		return {counters:counters, dataObject:this};
	}
	public function setData(newData:Object){
		counters = newData.counters;
	}
	public function setXML(newData:XMLNode):Void {
		counters = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newCounter = new Object();
			newCounter.name = "";
			newCounter.display_name = "";
			newCounter.key = "";
			newCounter.active = "Y";
			newCounter.max = "";
			newCounter.power = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newCounter.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newCounter.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newCounter.key = parseInt(newData.childNodes[child].attributes["KEY"],16);
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newCounter.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["MAX"] != undefined) {
				newCounter.max = newData.childNodes[child].attributes["MAX"];
			}
			if (newData.childNodes[child].attributes["POWER_RATING"] != undefined) {
				newCounter.power = newData.childNodes[child].attributes["POWER_RATING"];
			}
			counters.push(newCounter);
		}
	}
}
