import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.CbusSensors {
	private var sensors:Array;
	private var sensors_dg:DataGrid;
	private var save_btn:Button;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var key_ti:TextInput;
	private var power_ti:TextInput;
	private var channel_ti:TextInput;
	private var application_ti:TextInput;
	private var units_ti:TextInput;
	private var relay_chk:CheckBox;
	private var active_chk:CheckBox;
	public function init() {
		for (var sensor in sensors) {
			sensors_dg.addItem({name:sensors[sensor].attributes["NAME"], display_name:sensors[sensor].attributes["DISPLAY_NAME"], key:sensors[sensor].attributes["KEY"], active:sensors[sensor].attributes["ACTIVE"], power:sensors[sensor].attributes["POWER_RATING"], relay:sensors[sensor].attributes["RELAY"], channel:sensors[sensor].attributes["CHANNEL"], application:sensors[sensor].attributes["CBUS_APPLICATION"], units:sensors[sensor].attributes["UNITS"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		sensors_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		sensors_dg.removeItemAt(sensors_dg.selectedIndex);
		sensors_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		power_ti.text = "";
		channel_ti.text = "";
		application_ti.text = "";
		units_ti.text = "";
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
		if (sensors_dg.selectedIndex != undefined) {
			sensors_dg.getItemAt(sensors_dg.selectedIndex).name = name_ti.text;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).key = key_ti.text;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).display_name = dname_ti.text;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).active = active;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).relay = relay;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).power = power_ti.text;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).channel = channel_ti.text;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).application = application_ti.text;
			sensors_dg.getItemAt(sensors_dg.selectedIndex).units = units_ti.text;
		} else {
			sensors_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, relay:relay, power:power_ti.text, channel:channel_ti.text, application:application_ti.text, units:units_ti.text, relay:relay});
		}
		sensors_dg.selectedIndex = undefined;
		active_chk.selected = false;
		relay_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		sensors_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		power_ti.text = "";
		channel_ti.text = "";
		application_ti.text = "";
		units_ti.text = "";
		active_chk.selected = false;
		relay_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = sensors_dg.selectedItem.name;
		dname_ti.text = sensors_dg.selectedItem.display_name;
		key_ti.text = sensors_dg.selectedItem.key;
		power_ti.text = sensors_dg.selectedItem.power;
		channel_ti.text = sensors_dg.selectedItem.channel;
		application_ti.text = sensors_dg.selectedItem.application;
		units_ti.text = sensors_dg.selectedItem.units;
		var active = sensors_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		var relay = sensors_dg.selectedItem.relay;
		if (relay == "N") {
			relay_chk.selected = false;
		} else {
			relay_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newSensors = new Array();
		for (var index = 0; index<sensors_dg.length; index++) {
			var newSensor = new XMLNode(1, "LIGHT_DYNALITE");
			newSensor.attributes["NAME"] = sensors_dg.getItemAt(index).name;
			newSensor.attributes["DISPLAY_NAME"] = sensors_dg.getItemAt(index).display_name;
			newSensor.attributes["KEY"] = sensors_dg.getItemAt(index).key;
			newSensor.attributes["ACTIVE"] = sensors_dg.getItemAt(index).active;
			newSensor.attributes["POWER_RATING"] = sensors_dg.getItemAt(index).power;
			newSensor.attributes["RELAY"] = sensors_dg.getItemAt(index).relay;
			newSensor.attributes["CHANNEL"] = sensors_dg.getItemAt(index).relay;
			newSensor.attributes["CBUS_APPLICATION"] = sensors_dg.getItemAt(index).relay;
			newSensor.attributes["UNITS"] = sensors_dg.getItemAt(index).units;
			newSensors.push(newSensor);
		}
		_global.left_tree.selectedNode.sensors = newSensors;
	}
}
