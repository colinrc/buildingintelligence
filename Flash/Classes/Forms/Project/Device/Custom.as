import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Custom extends Forms.BaseForm {
	private var save_btn:Button;
	private var customs:Array;
	private var customs_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var key_ti:TextInput;
	private var command_ti:TextInput;
	private var extra_ti:TextInput;
	private var power_ti:TextInput;
	private var active_chk:CheckBox;
	private var regex_chk:CheckBox;
	public function init() {
		for (var custom in customs) {
			var newCustom = new Object();
			newCustom.name = "";
			newCustom.display_name = "";
			newCustom.key = "";
			newCustom.active = "Y";
			newCustom.command = "";
			newCustom.power = "";
			newCustom.regex = "Y";
			newCustom.extra = "";
			if (customs[custom].attributes["NAME"] != undefined) {
				newCustom.name = customs[custom].attributes["NAME"];
			}
			if (customs[custom].attributes["DISPLAY_NAME"] != undefined) {
				newCustom.display_name = customs[custom].attributes["DISPLAY_NAME"];
			}
			if (customs[custom].attributes["KEY"] != undefined) {
				newCustom.key = customs[custom].attributes["KEY"];
			}
			if (customs[custom].attributes["ACTIVE"] != undefined) {
				newCustom.active = customs[custom].attributes["ACTIVE"];
			}
			if (customs[custom].attributes["COMMAND"] != undefined) {
				newCustom.command = customs[custom].attributes["COMMAND"];
			}
			if (customs[custom].attributes["POWER_RATING"] != undefined) {
				newCustom.power = customs[custom].attributes["POWER_RATING"];
			}
			if (customs[custom].attributes["KEY_IS_REGEX"] != undefined) {
				newCustom.regex = customs[custom].attributes["KEY_IS_REGEX"];
			}
			if (customs[custom].attributes["EXTRA"] != undefined) {
				newCustom.extra = customs[custom].attributes["EXTRA"];
			}
			customs_dg.addItem(newCustom);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		customs_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		customs_dg.removeItemAt(customs_dg.selectedIndex);
		customs_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		command_ti.text = "";
		power_ti.text = "";
		extra_ti.text = "";
		active_chk.selected = false;
		regex_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (regex_chk.selected) {
			var regex = "Y";
		} else {
			var regex = "N";
		}
		if (customs_dg.selectedIndex != undefined) {
			customs_dg.getItemAt(customs_dg.selectedIndex).name = name_ti.text;
			customs_dg.getItemAt(customs_dg.selectedIndex).key = key_ti.text;
			customs_dg.getItemAt(customs_dg.selectedIndex).display_name = dname_ti.text;
			customs_dg.getItemAt(customs_dg.selectedIndex).active = active;
			customs_dg.getItemAt(customs_dg.selectedIndex).regex = regex;
			customs_dg.getItemAt(customs_dg.selectedIndex).command = command_ti.text;
			customs_dg.getItemAt(customs_dg.selectedIndex).extra = extra_ti.text;
			customs_dg.getItemAt(customs_dg.selectedIndex).power = power_ti.text;
		} else {
			customs_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, command:command_ti.text, power:power_ti.text, regex:regex, extra:extra_ti.text});
		}
		customs_dg.selectedIndex = undefined;
		active_chk.selected = false;
		regex_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		customs_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		command_ti.text = "";
		power_ti.text = "";
		extra_ti.text = "";
		active_chk.selected = false;
		regex_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = customs_dg.selectedItem.name;
		dname_ti.text = customs_dg.selectedItem.display_name;
		key_ti.text = customs_dg.selectedItem.key;
		power_ti.text = customs_dg.selectedItem.power;
		command_ti.text = customs_dg.selectedItem.command;
		extra_ti.text = customs_dg.selectedItem.extra;
		var active = customs_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		if (customs_dg.selectedItem.regex == "N") {
			regex_chk.selected = false;
		} else {
			regex_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newCustoms = new Array();
		for (var index = 0; index<customs_dg.length; index++) {
			var newCustom = new XMLNode(1, "CUSTOM_INPUT");
			if (customs_dg.getItemAt(index).name != "") {
				newCustom.attributes["NAME"] = customs_dg.getItemAt(index).name;
			}
			if (customs_dg.getItemAt(index).display_name != "") {
				newCustom.attributes["DISPLAY_NAME"] = customs_dg.getItemAt(index).display_name;
			}
			if (customs_dg.getItemAt(index).key != "") {
				newCustom.attributes["KEY"] = customs_dg.getItemAt(index).key;
			}
			if (customs_dg.getItemAt(index).active != "") {
				newCustom.attributes["ACTIVE"] = customs_dg.getItemAt(index).active;
			}
			if (customs_dg.getItemAt(index).command != "") {
				newCustom.attributes["COMMAND"] = customs_dg.getItemAt(index).command;
			}
			if (customs_dg.getItemAt(index).power != "") {
				newCustom.attributes["POWER_RATING"] = customs_dg.getItemAt(index).power;
			}
			if (customs_dg.getItemAt(index).regex != "") {
				newCustom.attributes["KEY_IS_REGEX"] = customs_dg.getItemAt(index).regex;
			}
			if (customs_dg.getItemAt(index).extra != "") {
				newCustom.attributes["EXTRA"] = customs_dg.getItemAt(index).extra;
			}
			newCustoms.push(newCustom);
		}
		_global.left_tree.selectedNode.object.setData({customs:newCustoms});
	}
}
