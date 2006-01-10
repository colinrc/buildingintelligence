import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Messages {
	private var node:XMLNode;
	private var items_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var value_ti:TextInput;
	public function init() {
		for (var child in node.childNodes) {
			items_dg.addItem({name:node.childNodes[child].attributes["NAME"], value:node.childNodes[child].attributes["VALUE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		items_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		items_dg.removeItemAt(items_dg.selectedIndex);
		items_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (items_dg.selectedIndex != undefined) {
			items_dg.getItemAt(items_dg.selectedIndex).name = name_ti.text;
			items_dg.getItemAt(items_dg.selectedIndex).value = value_ti.text;
		} else {
			items_dg.addItem({name:name_ti.text, value:value_ti.text});
		}
		items_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		items_dg.selectedIndex = undefined;
		name_ti.text = "";
		value_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = items_dg.selectedItem.name;
		value_ti.text = items_dg.selectedItem.value;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	private function getData():XMLNode {
		var newItems = new XMLNode(1, "CALENDAR_MESSAGES");
		for (var index = 0; index<items_dg.length; index++) {
			var item = new XMLNode(1, "ITEM");
			item.attributes["NAME"] = items_dg.getItemAt(index).name;
			item.attributes["VALUE"] = items_dg.getItemAt(index).value;
			newItems.appendChild(item);
		}
		return newItems;
	}
}
