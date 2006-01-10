import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Catalogue {
	private var node:XMLNode;
	private var items:XMLNode;
	private var items_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var name_ti:TextInput;
	private var code_ti:TextInput;
	private var value_ti:TextInput;
	public function init() {
		name_ti.text = node.attributes["NAME"];
		for (var child in items.childNodes) {
			items_dg.addItem({code:items.childNodes[child].attributes["CODE"], value:items.childNodes[child].attributes["VALUE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click",Delegate.create(this,save));
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
			items_dg.getItemAt(items_dg.selectedIndex).code = code_ti.text;
			items_dg.getItemAt(items_dg.selectedIndex).value = value_ti.text;
		} else {
			items_dg.addItem({code:code_ti.text, value:value_ti.text});
		}
		items_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		items_dg.selectedIndex = undefined;
		code_ti.text = "";
		value_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		code_ti.text = items_dg.selectedItem.code;
		value_ti.text = items_dg.selectedItem.value;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	private function save():Void{
		var newItems = new XMLNode(1,"CATALOGUE");
		newItems.attributes["NAME"] = name_ti.text;
		for(var index = 0; index < items_dg.length; index++){
			var item = new XMLNode(1, "ITEM");
			item.attributes["CODE"] = items_dg.getItemAt(index).code;
			item.attributes["VALUE"] = items_dg.getItemAt(index).value;
			newItems.appendChild(item);
		}
		_global.left_tree.selectedNode.items = newItems;
		_global.left_tree.selectedNode.attributes["NAME"] = name_ti.text
	}
}
