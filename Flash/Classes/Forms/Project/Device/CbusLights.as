import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.CbusLights extends Forms.BaseForm {
	private var lights:Array;
	private var lights_dg:DataGrid;
	private var save_btn:Button;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var application_ti:TextInput;
	private var key_ti:TextInput;
	private var area_ti:TextInput;
	private var power_ti:TextInput;
	private var relay_chk:CheckBox;
	private var active_chk:CheckBox;
	public function init() {
		for (var light in lights) {
			var newLight = new Object();
			newLight.name = "";
			newLight.display_name = "";
			newLight.key = "";
			newLight.active = "Y";
			newLight.area = "";
			newLight.power = "";
			newLight.relay = "Y";
			newLight.application = "";
			if (lights[light].attributes["NAME"] != undefined) {
				newLight.name = lights[light].attributes["NAME"];
			}
			if (lights[light].attributes["DISPLAY_NAME"] != undefined) {
				newLight.display_name = lights[light].attributes["DISPLAY_NAME"];
			}
			if (newLight.key=lights[light].attributes["KEY"] != undefined) {
				newLight.key = lights[light].attributes["KEY"];
			}
			if (lights[light].attributes["ACTIVE"] != undefined) {
				newLight.active = lights[light].attributes["ACTIVE"];
			}
			if (lights[light].attributes["AREA"] != undefined) {
				newLight.area = lights[light].attributes["AREA"];
			}
			if (lights[light].attributes["POWER_RATING"] != undefined) {
				newLight.power = lights[light].attributes["POWER_RATING"];
			}
			if (lights[light].attributes["RELAY"] != undefined) {
				newLight.relay = lights[light].attributes["RELAY"];
			}
			if (lights[light].attributes["CBUS_APPLICATION"] != undefined) {
				newLight.application = lights[light].attributes["CBUS_APPLICATION"];
			}
			lights_dg.addItem(newLight);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		lights_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		lights_dg.removeItemAt(lights_dg.selectedIndex);
		lights_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		area_ti.text = "";
		power_ti.text = "";
		application_ti.text = "";
		active_chk.selected = false;
		relay_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (relay_chk.selected) {
			var relay = "Y";
		} else {
			var relay = "N";
		}
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (lights_dg.selectedIndex != undefined) {
			lights_dg.getItemAt(lights_dg.selectedIndex).name = name_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).key = key_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).display_name = dname_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).active = active;
			lights_dg.getItemAt(lights_dg.selectedIndex).relay = relay;
			lights_dg.getItemAt(lights_dg.selectedIndex).area = area_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).power = power_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).application = application_ti.text;
		} else {
			lights_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, area:area_ti.text, relay:relay, power:power_ti.text, application:application_ti.text});
		}
		lights_dg.selectedIndex = undefined;
		active_chk.selected = false;
		relay_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		lights_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		area_ti.text = "";
		power_ti.text = "";
		application_ti.text = "";
		active_chk.selected = false;
		relay_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = lights_dg.selectedItem.name;
		dname_ti.text = lights_dg.selectedItem.display_name;
		key_ti.text = lights_dg.selectedItem.key;
		power_ti.text = lights_dg.selectedItem.power;
		area_ti.text = lights_dg.selectedItem.area;
		application_ti.text = lights_dg.selectedItem.application;
		var active = lights_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		var relay = lights_dg.selectedItem.relay;
		if (relay == "N") {
			relay_chk.selected = false;
		} else {
			relay_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newLights = new Array();
		for (var index = 0; index<lights_dg.length; index++) {
			var newLight = new XMLNode(1, "LIGHT_CBUS");
			if (lights_dg.getItemAt(index).name != "") {
				newLight.attributes["NAME"] = lights_dg.getItemAt(index).name;
			}
			if (lights_dg.getItemAt(index).display_name != "") {
				newLight.attributes["DISPLAY_NAME"] = lights_dg.getItemAt(index).display_name;
			}
			if (lights_dg.getItemAt(index).key != "") {
				newLight.attributes["KEY"] = lights_dg.getItemAt(index).key;
			}
			if (lights_dg.getItemAt(index).active != "") {
				newLight.attributes["ACTIVE"] = lights_dg.getItemAt(index).active;
			}
			if (lights_dg.getItemAt(index).area != "") {
				newLight.attributes["AREA"] = lights_dg.getItemAt(index).area;
			}
			if (lights_dg.getItemAt(index).power != "") {
				newLight.attributes["POWER_RATING"] = lights_dg.getItemAt(index).power;
			}
			if (lights_dg.getItemAt(index).relay != "") {
				newLight.attributes["RELAY"] = lights_dg.getItemAt(index).relay;
			}
			if (lights_dg.getItemAt(index).application != "") {
				newLight.attributes["CBUS_APPLICATION"] = lights_dg.getItemAt(index).application;
			}
			newLights.push(newLight);
		}
		_global.left_tree.selectedNode.object.setData(new Object({lights:newLights}));
	}
}
