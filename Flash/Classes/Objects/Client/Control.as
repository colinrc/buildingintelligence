class Objects.Client.Control extends Objects.BaseElement {
	private var type:String;
	private var rows:Array;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		treeNode.removeNode();
	}
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.control";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "control");
		newNode.attributes["type"] = type;
		for (var row in rows) {
			newNode.appendChild(rows[row]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Control");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "ClientControl";
	}
	public function getName():String {
		return "Control : " + type;
	}
	public function getData():Object {
		return {rows:rows, type:type, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		rows = new Array();
		if (newData.nodeName == "control") {
			type = newData.attributes["type"];
			for (var child in newData.childNodes) {
				rows.push(newData.childNodes[child]);
			}
		} else {
			trace("Error, found " + newData.nodeName + ", was expecting control");
		}
	}
	public function setData(newData:Object):Void {
		type = newData.type;
		rows = newData.rows;
	}
}
