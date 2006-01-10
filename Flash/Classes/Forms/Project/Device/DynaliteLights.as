import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.DynaliteLights {
	private var save_btn:Button;
	private var lights:Array;
	private var lights_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var key_ti:TextInput;
	private var area_ti:TextInput;
	private var power_ti:TextInput;
	private var relay_chk:CheckBox;
	private var active_chk:CheckBox;
	public function init() {
		for (var light in lights) {
			lights_dg.addItem({name:lights[light].attributes["NAME"], display_name:lights[light].attributes["DISPLAY_NAME"], key:lights[light].attributes["KEY"], active:lights[light].attributes["ACTIVE"], area:lights[light].attributes["AREA"], power:lights[light].attributes["POWER_RATING"], relay:lights[light].attributes["RELAY"]});
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
			lights_dg.getItemAt(lights_dg.selectedIndex).area = area_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).power = power_ti.text;
		} else {
			lights_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, area:area_ti.text, relay:relay, power:power_ti.text});
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
			var newLight = new XMLNode(1, "LIGHT_DYNALITE");
			newLight.attributes["NAME"] = lights_dg.getItemAt(index).name;
			newLight.attributes["DISPLAY_NAME"] = lights_dg.getItemAt(index).display_name;
			newLight.attributes["KEY"] = lights_dg.getItemAt(index).key;
			newLight.attributes["ACTIVE"] = lights_dg.getItemAt(index).active;
			newLight.attributes["AREA"] = lights_dg.getItemAt(index).area;
			newLight.attributes["POWER_RATING"] = lights_dg.getItemAt(index).power;
			newLight.attributes["RELAY"] = lights_dg.getItemAt(index).relay;
			newLights.push(newLight);
		}
		_global.left_tree.selectedNode.lights = newLights;
	}
}
