import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.ToggleMonitor extends Forms.BaseForm {
	private var monitors:Array;
	private var monitors_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var key_ti:TextInput;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var active_chk:CheckBox;
	private var save_btn:Button;
	public function init() {
		for (var monitor in monitors) {
			if (monitors[monitor].attributes["ACTIVE"] == "N") {
				var active = "N";
			} else {
				var active = "Y";
			}
			monitors_dg.addItem({key:monitors[monitor].attributes["KEY"], name:monitors[monitor].attributes["NAME"], active:active, dname:monitors[monitor].attributes["DISPLAY_NAME"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		monitors_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		monitors_dg.removeItemAt(monitors_dg.selectedIndex);
		monitors_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (monitors_dg.selectedIndex != undefined) {
			monitors_dg.getItemAt(monitors_dg.selectedIndex).key = key_ti.text;
			monitors_dg.getItemAt(monitors_dg.selectedIndex).name = name_ti.text;
			monitors_dg.getItemAt(monitors_dg.selectedIndex).dname = dname_ti.text;
			monitors_dg.getItemAt(monitors_dg.selectedIndex).active = active;
		} else {
			monitors_dg.addItem({key:key_ti.text, name:name_ti.text, active:active, dname:dname_ti.text});
		}
		monitors_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		monitors_dg.selectedIndex = undefined;
		key_ti.text = "";
		name_ti.text = "";
		dname_ti.text = "";
		active_chk.selected = true;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		key_ti.text = monitors_dg.selectedItem.key;
		name_ti.text = monitors_dg.selectedItem.name;
		dname_ti.text = monitors_dg.selectedItem.dname;
		var active = monitors_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newMonitors = new Array();
		for (var index = 0; index<monitors_dg.length; index++) {
			var item = new XMLNode(1, "TOGGLE_OUTPUT_MONITOR");
			item.attributes["KEY"] = monitors_dg.getItemAt(index).key;
			item.attributes["NAME"] = monitors_dg.getItemAt(index).name;
			item.attributes["ACTIVE"] = monitors_dg.getItemAt(index).active;
			item.attributes["DISPLAY_NAME"] = monitors_dg.getItemAt(index).dname;
			newMonitors.push(item);
		}
		_global.left_tree.selectedNode.object.setData(new Object({monitors:newMonitors}));
	}
}
