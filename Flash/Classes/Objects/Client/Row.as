class Objects.Client.Row extends Objects.BaseElement {
	private var cases:String;
	private var items:Array;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.row";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "row");
		newNode.attributes["cases"] = cases;
		for (var item in items) {
			newNode.appendChild(items[item].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		for (var item in items) {
			newNode.appendChild(items[item].toTree());
		}
		_global.workflow.addNode("ClientRow",newNode);
		return newNode;
	}
	public function getName():String {
		var rowName = "Row ";
		if (items.length !=0 ) {
			for (var item in items) {
				var label_str:String = items[item].type+" ";
				var name = "";
				for (var attribute in items[item].attributes) {
					if ((items[item].attributes[attribute].name == "label") || (items[item].attributes[attribute].name == "icon")) {
						name += ": "+items[item].attributes[attribute].value+", ";
					}
				}
				if (name == "") {
					name = ": No Name, ";
				}
				label_str += name;
				rowName += label_str;
			}
		} else {
			rowName += ": No Items";
		}
		return rowName;
	}
	public function getData():Object {
		return new Object({cases:cases, items:items});
	}
	public function setXML(newData:XMLNode):Void {
		items = new Array();
		if (newData.nodeName == "row") {
			cases = newData.attributes["cases"];
			for (var child in newData.childNodes) {
				var newItem = new Objects.Client.Item();
				newItem.setXML(newData.childNodes[child]);
				items.push(newItem);
			}
		} else {
			trace("Error, found "+newData.nodeName+", was expecting row");
		}
	}
	public function setData(newData:Object):Void {
		cases = newData.cases;
		items = newData.items;
	}
}
