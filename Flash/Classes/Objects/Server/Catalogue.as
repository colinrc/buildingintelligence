class Objects.Server.Catalogue extends Objects.BaseElement {
	private var name:String;
	private var items:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var item in items) {
			if ((items[item].attributes["CODE"] == undefined) || (items[item].attributes["CODE"] == "")) {
				flag = false;
			}
			if ((items[item].attributes["VALUE"] == undefined) || (items[item].attributes["VALUE"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.catalogue";
	}
	public function toXML():XMLNode {
		var newCatalogue = new XMLNode(1, "CATALOGUE");
		newCatalogue.attributes["NAME"] = name;
		for (var item in items) {
			newCatalogue.appendChild(items[item]);
		}
		return newCatalogue;
	}
	public function getName():String {
		return "Catalogue: "+name;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function setData(newData:Object){
		name = newData.name;
		items = newData.items;
	}
	public function getData():Object {
		return new Object({name:name, items:items});
	}
	public function setXML(newData:XMLNode):Void {
		name = newData.attributes["NAME"];
		items = new Array();
		for (var child in newData.childNodes) {
			items.push(newData.childNodes[child]);
		}
	}
}
