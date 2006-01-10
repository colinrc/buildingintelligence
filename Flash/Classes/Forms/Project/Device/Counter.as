import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Counter {
	private var save_btn:Button;
	private var counters:Array;
	private var counters_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var key_ti:TextInput;
	private var max_ti:TextInput;
	private var power_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var counter in counters) {
			counters_dg.addItem({name:counters[counter].attributes["NAME"], display_name:counters[counter].attributes["DISPLAY_NAME"], key:counters[counter].attributes["KEY"], active:counters[counter].attributes["ACTIVE"], max:counters[counter].attributes["MAX"], power:counters[counter].attributes["POWER_RATING"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		counters_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		counters_dg.removeItemAt(counters_dg.selectedIndex);
		counters_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		max_ti.text = "";
		power_ti.text = "";
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
		if (counters_dg.selectedIndex != undefined) {
			counters_dg.getItemAt(counters_dg.selectedIndex).name = name_ti.text;
			counters_dg.getItemAt(counters_dg.selectedIndex).key = key_ti.text;
			counters_dg.getItemAt(counters_dg.selectedIndex).display_name = dname_ti.text;
			counters_dg.getItemAt(counters_dg.selectedIndex).active = active;
			counters_dg.getItemAt(counters_dg.selectedIndex).max = max_ti.text;
			counters_dg.getItemAt(counters_dg.selectedIndex).power = power_ti.text;
		} else {
			counters_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, max:max_ti.text, power:power_ti.text});
		}
		counters_dg.selectedIndex = undefined;
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		counters_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		max_ti.text = "";
		power_ti.text = "";
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = counters_dg.selectedItem.name;
		dname_ti.text = counters_dg.selectedItem.display_name;
		key_ti.text = counters_dg.selectedItem.key;
		power_ti.text = counters_dg.selectedItem.power;
		max_ti.text = counters_dg.selectedItem.max;
		var active = counters_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newCounters = new Array();
		for (var index = 0; index<counters_dg.length; index++) {
			var newCounter = new XMLNode(1, "COUNTER");
			newCounter.attributes["NAME"] = counters_dg.getItemAt(index).name;
			newCounter.attributes["DISPLAY_NAME"] = counters_dg.getItemAt(index).display_name;
			newCounter.attributes["KEY"] = counters_dg.getItemAt(index).key;
			newCounter.attributes["ACTIVE"] = counters_dg.getItemAt(index).active;
			newCounter.attributes["MAX"] = counters_dg.getItemAt(index).max;
			newCounter.attributes["POWER_RATING"] = counters_dg.getItemAt(index).power;
			newCounters.push(newCounter);
		}
		_global.left_tree.selectedNode.counters = newCounters;
	}
}
