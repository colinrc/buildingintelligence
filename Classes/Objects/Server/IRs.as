class Objects.Server.IRs extends Objects.BaseElement {
	private var container:String;
	private var irs:Array;
	private var treeNode:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var ir in irs){
			tempKeys.push(irs[ir].avname);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var ir in irs) {
			if ((irs[ir].name == undefined) || (irs[ir].name == "")) {
				flag = "empty";
				appendValidationMsg("Description is empty");
			}
			if ((irs[ir].key == undefined) || (irs[ir].key == "")) {
				flag = "error";
				appendValidationMsg("Key is invalid");
			}
			if ((irs[ir].avname == undefined) || (irs[ir].avname == "")) {
				flag = "error";
				appendValidationMsg("AV Name is empty");
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
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "IRs";
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
			irs.push(newData.childNodes[child]);
		}
	}
}
