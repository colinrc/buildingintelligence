class Objects.Server.Raw_Item extends Objects.BaseElement {
	var raws:Array;
	var catalogue:String;
	var prefix:String;
	public function isValid():Boolean {
		var flag = true;
		if((catalogue == undefined)||(catalogue == "")){
			flag = false;
		}
		for (var raw in raws) {
			if (!raws[raw].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raws";
	}
	public function toXML():XMLNode {
		var newRaw_Item = new XMLNode(1, "RAW ITEMS");
		newRaw_Item.attributes["CATALOGUE"] = catalogue;
		newRaw_Item.attributes["PREFIX"] = prefix;
		for (var raw in raws) {
			newRaw_Item.appendChild(raws[raw].toXML());
		}
		return newRaw_Item;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		for (var raw in raws) {
			newNode.appendChild(raws[raw].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return catalogue;
	}
	public function getData():Object {
		return new Object({raws:raws, catalogue:catalogue, prefix:prefix});
	}
	public function setData(newData:Object){
		//process raw changes
		catalogue = newData.catalogue;
		prefix = newData.prefix;
	}
	public function setXML(newData:XMLNode):Void {
		catalogue = newData.attributes["CATALOGUE"];
		prefix = newData.attributes["PREFIX"];
		raws = new Array();
		for (var child in newData.childNodes) {
			var tempRaw = new Objects.Server.Raw();
			tempRaw.setXML(newData.childNodes[child]);
			raws.push(tempRaw);
		}
	}
}
