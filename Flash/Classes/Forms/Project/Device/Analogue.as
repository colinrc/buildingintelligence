import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Analogue extends Forms.BaseForm {
	private var save_btn:Button;
	private var analogues:Array;
	private var analogues_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var key_ti:TextInput;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var analogue in analogues) {
			var newAnalogue = new Object();
			if (analogues[analogue].attributes["ACTIVE"] == "N") {
				newAnalogue.active = "N";
			} else {
				newAnalogue.active = "Y";
			}
			newAnalogue.key = "";
			newAnalogue.name = "";
			newAnalogue.dname = "";
			if (analogues[analogue].attributes["KEY"] != undefined) {
				newAnalogue.key = analogues[analogue].attributes["KEY"];
			}
			if (analogues[analogue].attributes["NAME"] != undefined) {
				newAnalogue.name = analogues[analogue].attributes["NAME"];
			}
			if (analogues[analogue].attributes["DISPLAY_NAME"] != undefined) {
				newAnalogue.dname = analogues[analogue].attributes["DISPLAY_NAME"];
			}
			analogues_dg.addItem(newAnalogue);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		analogues_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		analogues_dg.removeItemAt(analogues_dg.selectedIndex);
		analogues_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (analogues_dg.selectedIndex != undefined) {
			analogues_dg.getItemAt(analogues_dg.selectedIndex).key = key_ti.text;
			analogues_dg.getItemAt(analogues_dg.selectedIndex).name = name_ti.text;
			analogues_dg.getItemAt(analogues_dg.selectedIndex).dname = dname_ti.text;
			analogues_dg.getItemAt(analogues_dg.selectedIndex).active = active;
		} else {
			analogues_dg.addItem({key:key_ti.text, name:name_ti.text, active:active, dname:dname_ti.text});
		}
		analogues_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		analogues_dg.selectedIndex = undefined;
		key_ti.text = "";
		name_ti.text = "";
		dname_ti.text = "";
		active_chk.selected = true;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		key_ti.text = analogues_dg.selectedItem.key;
		name_ti.text = analogues_dg.selectedItem.name;
		dname_ti.text = analogues_dg.selectedItem.dname;
		var active = analogues_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newAnalogues = new Array();
		for (var index = 0; index<analogues_dg.length; index++) {
			var item = new XMLNode(1, "ANALOG");
			if (analogues_dg.getItemAt(index).key != "") {
				item.attributes["KEY"] = analogues_dg.getItemAt(index).key;
			}
			if (analogues_dg.getItemAt(index).name != "") {
				item.attributes["NAME"] = analogues_dg.getItemAt(index).name;
			}
			if (analogues_dg.getItemAt(index).active != "") {
				item.attributes["ACTIVE"] = analogues_dg.getItemAt(index).active;
			}
			if (analogues_dg.getItemAt(index).dname != "") {
				item.attributes["DISPLAY_NAME"] = analogues_dg.getItemAt(index).dname;
			}
			newAnalogues.push(item);
		}
		_global.left_tree.selectedNode.analogues = newAnalogues;
	}
}
