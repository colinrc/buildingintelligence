class Objects.Server.Catalogue extends Objects.BaseElement {
	private var name:String;
	private var items:Array;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		treeNode.removeNode();
	}			
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var item in items) {
			
			if ((items[item].attributes["CODE"] == undefined) || (items[item].attributes["CODE"] == "")) {
				flag = "error";
				appendValidationMsg("Code is invalid");
			}
			if ((items[item].attributes["VALUE"] == undefined) || (items[item].attributes["VALUE"] == "")) {
				flag = "error";
				appendValidationMsg("Value is invalid");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.catalogue";
	}
	public function toXML():XMLNode {
		var newCatalogue = new XMLNode(1, "CATALOGUE");
		if (name != "") {
			newCatalogue.attributes["NAME"] = name;
		}
		for (var item in items) {
			newCatalogue.appendChild(items[item]);
		}
		return newCatalogue;
	}
	public function getName():String {
		return name;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode =newNode;
		return newNode;
	}
	public function getKey():String {
		return "Catalogue";
	}
	public function setData(newData:Object) {
		items = newData.items;
	}
	public function getData():Object {
		return {name:name, items:items, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		if (newData.attributes["NAME"] != undefined) {
			name = newData.attributes["NAME"];
		}
		items = new Array();
		for (var child in newData.childNodes) {
			items.push(newData.childNodes[child]);
		}
	}
}
