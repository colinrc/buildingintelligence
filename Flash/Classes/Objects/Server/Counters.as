class Objects.Server.Counters extends Objects.BaseElement {
	private var container:String;
	private var counters:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var counter in counters){
			tempKeys.push(counters[counter].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var counter in counters) {
			if ((counters[counter].attributes["ACTIVE"] != "Y") && (counters[counter].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((counters[counter].attributes["KEY"] == undefined) || (counters[counter].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((counters[counter].attributes["NAME"] == undefined) || (counters[counter].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((counters[counter].attributes["DISPLAY_NAME"] == undefined) || (counters[counter].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
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
				newCounter.attributes["KEY"] = counters[counter].key;
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
		_global.workflow.addNode("Counters",newNode);
		return newNode;
	}
	public function getName():String {
		return "Counters";
	}
	public function getData():Object {
		return new Object({counters:counters});
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
				newCounter.key = newData.childNodes[child].attributes["KEY"];
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
