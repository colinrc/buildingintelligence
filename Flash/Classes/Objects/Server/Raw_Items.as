class Objects.Server.Raw_Items extends Objects.BaseElement {
	var raw_items:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var raw_item in raw_items) {
			if (!raw_items[raw_item].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw_items";
	}
	public function toXML():XMLNode {
		var newModules = new XMLNode(1, "Raw Items");
		for (var raw_item in raw_items) {
			newModules.appendChild(raw_items[raw_item].toXML());
		}
		return newModules;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,getName());
		for (var raw_item in raw_items) {
			newNode.appendChild(raw_items[raw_item].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Raw Items";
	}
	public function getData():Object {
		return new Object({raw_items:raw_items});
	}
	public function setData(newData:Object){
		//process raw items changes
	}
	public function setXML(newData:XMLNode):Void {
		raw_items = new Array();
		for (var child in newData.childNodes) {
			var tempRaw_item = new Objects.Server.Raw_Item();
			tempRaw_item.setXML(newData.childNodes[child]);
			raw_items.push(tempRaw_item);
		}
	}
}
