class Objects.Server.IRs extends Objects.BaseElement {
	private var container:String;
	private var irs:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var ir in irs){
			tempKeys.push(irs[ir].avname);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var ir in irs) {
			if ((irs[ir].attributes["KEY"] == undefined) || (irs[ir].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((irs[ir].attributes["NAME"] == undefined) || (irs[ir].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((irs[ir].attributes["AV_NAME"] == undefined) || (irs[ir].attributes["AV_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.ir";
	}
	public function toXML():XMLNode {
		var irsNode = new XMLNode(1, container);
		for (var ir in irs) {
			irsNode.appendChild(irs[ir]);
		}
		return irsNode;
	}
	public function getName():String {
		return "IR Inputs";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("IRs",newNode);
		return newNode;
	}
	public function setData(newData:Object){
		irs = newData.irs;
	}
	public function getData():Object {
		return new Object({irs:irs});
	}
	public function setXML(newData:XMLNode):Void {
		irs = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			irs.push(newData.childNodes[child]);
		}
	}
}
