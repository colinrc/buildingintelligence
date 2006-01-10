import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Contact {
	private var save_btn:Button;
	private var closures:Array;
	private var closures_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var key_ti:TextInput;
	private var box_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var closure in closures) {
			closures_dg.addItem({name:closures[closure].attributes["NAME"], display_name:closures[closure].attributes["DISPLAY_NAME"], key:closures[closure].attributes["KEY"], active:closures[closure].attributes["ACTIVE"], box:closures[closure].attributes["BOX"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		closures_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		closures_dg.removeItemAt(closures_dg.selectedIndex);
		closures_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		box_ti.text = "";
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (closures_dg.selectedIndex != undefined) {
			closures_dg.getItemAt(closures_dg.selectedIndex).name = name_ti.text;
			closures_dg.getItemAt(closures_dg.selectedIndex).key = key_ti.text;
			closures_dg.getItemAt(closures_dg.selectedIndex).display_name = dname_ti.text;
			closures_dg.getItemAt(closures_dg.selectedIndex).active = active;
			closures_dg.getItemAt(closures_dg.selectedIndex).box = box_ti.text;
		} else {
			closures_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, box:box_ti.text});
		}
		closures_dg.selectedIndex = undefined;
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		closures_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		box_ti.text = "";
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = closures_dg.selectedItem.name;
		dname_ti.text = closures_dg.selectedItem.display_name;
		key_ti.text = closures_dg.selectedItem.key;
		box_ti.text = closures_dg.selectedItem.box;
		var active = closures_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newClosures = new Array();
		for (var index = 0; index<closures_dg.length; index++) {
			var newClosure = new XMLNode(1, "CONTACT_CLOSURE");
			newClosure.attributes["NAME"] = closures_dg.getItemAt(index).name;
			newClosure.attributes["DISPLAY_NAME"] = closures_dg.getItemAt(index).display_name;
			newClosure.attributes["KEY"] = closures_dg.getItemAt(index).key;
			newClosure.attributes["ACTIVE"] = closures_dg.getItemAt(index).active;
			newClosure.attributes["BOX"] = closures_dg.getItemAt(index).box;
			newClosures.push(newClosure);
		}
		_global.left_tree.selectedNode.closures = newClosures;
	}
}
