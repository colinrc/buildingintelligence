import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Alarm {
	private var alarms:Array;
	private var alarms_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var key_ti:TextInput;
	private var dname_ti:TextInput;
	public function init() {
		for (var alarm in alarms) {
			alarms_dg.addItem({key:alarms[alarm].attributes["KEY"], dname:alarms[alarm].attributes["DISPLAY_NAME"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		alarms_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		alarms_dg.removeItemAt(alarms_dg.selectedIndex);
		alarms_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (alarms_dg.selectedIndex != undefined) {
			alarms_dg.getItemAt(alarms_dg.selectedIndex).key = key_ti.text;
			alarms_dg.getItemAt(alarms_dg.selectedIndex).dname = dname_ti.text;
		} else {
			alarms_dg.addItem({key:key_ti.text, dname:dname_ti.text});
		}
		alarms_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		alarms_dg.selectedIndex = undefined;
		key_ti.text = "";
		dname_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		key_ti.text = alarms_dg.selectedItem.key;
		dname_ti.text = alarms_dg.selectedItem.dname;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var newAlarms = new Array();
		for (var index = 0; index<alarms_dg.length; index++) {
			var item = new XMLNode(1, "ALARM");
			item.attributes["KEY"] = alarms_dg.getItemAt(index).key;
			item.attributes["DISPLAY_NAME"] = alarms_dg.getItemAt(index).dname;
			newAlarms.push(item);
		}
		return newAlarms;
	}
}
