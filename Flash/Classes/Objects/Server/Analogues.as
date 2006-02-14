class Objects.Server.Analogues extends Objects.BaseElement {
	private var container:String;
	private var analogues:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var analogue in analogues){
			tempKeys.push(analogues[analogue].attributes["DISPLAY_NAME"]);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var analogue in analogues) {
			if ((analogues[analogue].attributes["ACTIVE"] != "Y") && (analogues[analogue].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((analogues[analogue].attributes["KEY"] == undefined) || (analogues[analogue].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((analogues[analogue].attributes["NAME"] == undefined) || (analogues[analogue].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((analogues[analogue].attributes["DISPLAY_NAME"] == undefined) || (analogues[analogue].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.analogue";
	}
	public function toXML():XMLNode {
		var analoguesNode = new XMLNode(1, container);
		for (var analogue in analogues) {
			analoguesNode.appendChild(analogues[analogue]);
		}
		return analoguesNode;
	}
	public function getName():String {
		return "Analogues";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("Analogues",newNode);
		return newNode;
	}
	public function getData():Object {
		return new Object({analogues:analogues});
	}
	public function setData(newData:Object){
		analogues = newData.analogues;
	}
	public function setXML(newData:XMLNode):Void {
		analogues = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			analogues.push(newData.childNodes[child]);
		}
	}
}
