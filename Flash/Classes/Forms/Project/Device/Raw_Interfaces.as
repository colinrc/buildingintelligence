import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Interfaces {
	private var interfaces:Array;
	private var interfaces_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var power_ti:TextInput;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	public function init() {
		for (var index in interfaces) {
			interfaces_dg.addItem({name:interfaces[index].attributes["NAME"],dname:interfaces[index].attributes["DISPLAY_NAME"],power:interfaces[index].attributes["POWER_RATING"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		interfaces_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		interfaces_dg.removeItemAt(interfaces_dg.selectedIndex);
		interfaces_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (interfaces_dg.selectedIndex != undefined) {
			interfaces_dg.getItemAt(interfaces_dg.selectedIndex).power = power_ti.text;
			interfaces_dg.getItemAt(interfaces_dg.selectedIndex).name = name_ti.text;
			interfaces_dg.getItemAt(interfaces_dg.selectedIndex).dname = dname_ti.text;
		} else {
			interfaces_dg.addItem({power:power_ti.text, name:name_ti.text, dname:dname_ti.text});
		}
		interfaces_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		interfaces_dg.selectedIndex = undefined;
		power_ti.text = "";
		name_ti.text = "";
		dname_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		power_ti.text = interfaces_dg.selectedItem.power;
		name_ti.text = interfaces_dg.selectedItem.name;
		dname_ti.text = interfaces_dg.selectedItem.dname;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var newRaw_Interfaces = new Array();
		for (var index = 0; index<interfaces_dg.length; index++) {
			var item = new XMLNode(1, "RAW_INTERFACE");
			item.attributes["POWER_RATING"] = interfaces_dg.getItemAt(index).power;
			item.attributes["NAME"] = interfaces_dg.getItemAt(index).name;
			item.attributes["DISPLAY_NAME"] = interfaces_dg.getItemAt(index).dname;
			newRaw_Interfaces.push(item);
		}
		return newRaw_Interfaces;
	}
}
