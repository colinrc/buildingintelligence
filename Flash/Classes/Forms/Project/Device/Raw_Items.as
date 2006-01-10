import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Items {
	private var node:XMLNode;
	private var raw_items_dg:DataGrid;
	private var delete_btn:Button;
	private var add_btn:Button;
	private var save_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var child in node.childNodes) {
			raw_items_dg.addItem({name:node.childNodes[child].attributes["CATALOGUE"]});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		raw_items_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		raw_items_dg.removeItemAt(raw_items_dg.selectedIndex);
		raw_items_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		raw_items_dg.addItem({name:name_ti.text});
		raw_items_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = raw_items_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newRaw_Items = new Array();
		for (var index = 0; index<raw_items_dg.length; index++) {
			var found = false;
			for (var raw_item in node.childNodes) {
				if (node.childNodes[raw_item].attributes["CATALOGUE"] == raw_items_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				newRaw_Items.push({name:raw_items_dg.getItemAt(index).name});
			}
		}
		var deletedRaw_Items = new Array();
		for (var raw_item in node.childNodes) {
			var found = false;
			for (var index = 0; index<raw_items_dg.length; index++) {
				if (node.childNodes[raw_item].attributes["CATALOGUE"] == raw_items_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				deletedRaw_Items.push({name:node.childNodes[raw_item].attributes["CATALOGUE"]});
			}
		}
		for (var delRaw_Item in deletedRaw_Items) {
			for (var raw_item in node.childNodes) {
				if (deletedRaw_Items[delRaw_Item].name == node.childNodes[raw_item].attributes["CATALOGUE"]) {
					node.childNodes[raw_item].removeNode();
				}
			}
		}
		for (var newRaw_Item in newRaw_Items) {
			var newNode = new XMLNode(1, "RAW_ITEMS");
			newNode.attributes["CATALOGUE"] = newRaw_Items[newRaw_Item].name;
			newNode.attributes["PREFIX"] = "";
			node.appendChild(newNode);
		}
	}
}
