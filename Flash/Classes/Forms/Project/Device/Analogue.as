import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Analogue {
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
			if (analogues[analogue].attributes["ACTIVE"] == "N") {
				var active = "N";
			} else {
				var active = "Y";
			}
			analogues_dg.addItem({key:analogues[analogue].attributes["KEY"], name:analogues[analogue].attributes["NAME"], active:active, dname:analogues[analogue].attributes["DISPLAY_NAME"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		analogues_dg.addEventListener("change", Delegate.create(this, itemChange));
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
	public function getData():Object {
		var newAnalogues = new Array();
		for (var index = 0; index<analogues_dg.length; index++) {
			var item = new XMLNode(1, "ANALOGUE");
			item.attributes["KEY"] = analogues_dg.getItemAt(index).key;
			item.attributes["NAME"] = analogues_dg.getItemAt(index).name;
			item.attributes["ACTIVE"] = analogues_dg.getItemAt(index).active;
			item.attributes["DISPLAY_NAME"] = analogues_dg.getItemAt(index).dname;
			newAnalogues.push(item);
		}
		return newAnalogues;
	}
}
