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
			countersNode.appendChild(counters[counter]);
		}
		return countersNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
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
			counters.push(newData.childNodes[child]);
		}
	}
}
