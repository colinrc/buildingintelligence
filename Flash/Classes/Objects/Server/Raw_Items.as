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
		var newRaw_Items = new XMLNode(1, "Raw Items");
		for (var raw_item in raw_items) {
			newRaw_Items.appendChild(raw_items[raw_item].toXML());
		}
		return newRaw_Items;
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
		var newRaw_Items = new Array();
		for (var index in newData.raw_items) {
			var found = false;
			for (var raw_item in raw_items) {
				if (raw_items[raw_item].catalogue == newData.raw_items[index].catalogue) {
					found = true;
				}
			}
			if (found == false) {
				newRaw_Items.push({catalogue:newData.raw_items[index].catalogue});
			}
		}
		var deletedRaw_Items = new Array();
		for (var raw_item in raw_items) {
			var found = false;
			for (var index in newData.raw_items) {
				if (raw_items[raw_item].catalogue == newData.raw_items[index].catalogue) {
					found = true;
				}
			}
			if (found == false) {
				raw_items.splice(parseInt(raw_item), 1);
			}
		}
		for (var newRaw_Item in newRaw_Items) {
			var newNode = new XMLNode(1, "RAW_ITEMS");
			newNode.attributes["CATALOGUE"] = newRaw_Items[newRaw_Item].catalogue;
			var newRaw_Item = new Objects.Server.Raw_Item();
			newRaw_Item.setXML(newNode);
			raw_items.push(newRaw_Item);
		}
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
