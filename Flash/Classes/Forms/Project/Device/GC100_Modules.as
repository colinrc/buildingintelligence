import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_Modules {
	private var modules:Array;
	private var modules_dg:DataGrid;
	private var type_cb:ComboBox;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var module in modules) {
			modules_dg.addItem({name:modules[module].name, type:modules[module].type});
		}
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		modules_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		modules_dg.getItemAt(modules_dg.selectedIndex).name = "DELETED";
		modules_dg.selectedIndex = undefined;
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (modules_dg.selectedIndex != undefined) {
			modules_dg.getItemAt(modules_dg.selectedIndex).name = name_ti.text;
			modules_dg.getItemAt(modules_dg.selectedIndex).type = type_cb.selectedItem;
		} else {
			modules_dg.addItem({name:name_ti.text, type:type_cb.selectedItem});
		}
		modules_dg.selectedIndex = undefined;
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		modules_dg.selectedIndex = undefined;
		name_ti.text = "";
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = modules_dg.selectedItem.name;
		if(modules_dg.selectedItem.type == "GC100_Relay"){
			type_cb.selectedIndex = 1;
		}
		else{
			type_cb.selectedIndex = 0;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Array {
		var newModules = new Array();
		for(var index = 0; index < modules_dg.length; index++){
			newModules.push({name:modules_dg.getItemAt(index).name,type:modules_dg.getItemAt(index).type});
		}
		return newModules;
	}
}
