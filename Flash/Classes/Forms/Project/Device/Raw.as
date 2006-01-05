import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw {
	private var node:XMLNode;
	private var device:XMLNode;
	private var vars_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var name_lb:TextInput;
	private var name_ti:TextInput;
	private var value_ti:TextInput;
	public function init() {
		name_lb.text = node.attributes["COMMAND"];
		for (var child in device.childNodes) {
			vars_dg.addItem({name:device.childNodes[child].attributes["NAME"], value:device.childNodes[child].attributes["VALUE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click",Delegate.create(this,save));
		vars_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		vars_dg.removeItemAt(vars_dg.selectedIndex);
		vars_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (vars_dg.selectedIndex != undefined) {
			vars_dg.getItemAt(vars_dg.selectedIndex).name = name_ti.text;
			vars_dg.getItemAt(vars_dg.selectedIndex).value = value_ti.text;
		} else {
			vars_dg.addItem({name:name_ti.text, value:value_ti.text});
		}
		vars_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		vars_dg.selectedIndex = undefined;
		name_ti.text = "";
		value_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = vars_dg.selectedItem.name;
		value_ti.text = vars_dg.selectedItem.value;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	private function save():Void{
		var newItems = new XMLNode(1,"RAW");
		for(var index = 0; index < vars_dg.length; index++){
			var item = new XMLNode(1, "VARS");
			item.attributes["NAME"] = vars_dg.getItemAt(index).name;
			item.attributes["VALUE"] = vars_dg.getItemAt(index).value;
			newItems.appendChild(item);
		}
		_global.left_tree.selectedNode.device = newItems;
	}
}
