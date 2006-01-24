import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.X10Lights extends Forms.BaseForm {
	private var save_btn:Button;
	private var lights:Array;
	private var lights_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var key_ti:TextInput;
	private var dname_ti:TextInput;	
	private var power_ti:TextInput;
	private var x10_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var light in lights) {
			lights_dg.addItem({name:lights[light].attributes["NAME"], key:lights[light].attributes["KEY"], display_name:lights[light].attributes["DISPLAY_NAME"],power:lights[light].attributes["POWER_RATING"], active:lights[light].attributes["ACTIVE"], x10:lights[light].attributes["X10HOUSE_CODE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		lights_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		lights_dg.removeItemAt(lights_dg.selectedIndex);
		lights_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text ="";
		power_ti.text = "";
		x10_ti.text = "";
	}
	private function updateItem() {
		if(active_chk.selected){
			var active = "Y";
		}
		else{
			var active = "N";
		}
		if (lights_dg.selectedIndex != undefined) {
			lights_dg.getItemAt(lights_dg.selectedIndex).name = name_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).key = key_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).display_name = dname_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).power = power_ti.text;
			lights_dg.getItemAt(lights_dg.selectedIndex).active = active;
			lights_dg.getItemAt(lights_dg.selectedIndex).x10 = x10_ti.text;
		} else {
			lights_dg.addItem({name:name_ti.text, key:key_ti.text, display_name:dname_ti.text, power:power_ti.text, active:active, x10:x10_ti.text});
		}
		lights_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		lights_dg.selectedIndex = undefined;
		active_chk.selected = false;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text ="";
		power_ti.text = "";
		x10_ti.text ="";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = lights_dg.selectedItem.name;
		key_ti.text = lights_dg.selectedItem.key;
		dname_ti.text = lights_dg.selectedItem.display_name;
		power_ti.text = lights_dg.selectedItem.power;
		x10_ti.text = lights_dg.selectedItem.x10;
		if(lights_dg.selectedItem.active == "N"){
			active_chk.selected = false;
		}
		else{
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newLights = new Array();
		for(var index = 0; index < lights_dg.length; index++){
			var lightNode = new XMLNode(1, "LIGHT_X10");
			lightNode.attributes["NAME"] = lights_dg.getItemAt(index).name;
			lightNode.attributes["KEY"] = lights_dg.getItemAt(index).key;
			lightNode.attributes["DISPLAY_NAME"] = lights_dg.getItemAt(index).display_name;
			lightNode.attributes["ACTIVE"] = lights_dg.getItemAt(index).active;
			lightNode.attributes["POWER_RATING"] = lights_dg.getItemAt(index).power;
			lightNode.attributes["X10HOUSE_CODE"] = lights_dg.getItemAt(index).x10;
			newLights.push(lightNode);
		}
		_global.left_tree.selectedNode.object.setData(new Object({lights:newLights}));
	}
}
