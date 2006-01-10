import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Toggle {
	private var save_btn:Button;
	private var node:XMLNode;
	private var toggles:Array;
	private var toggle_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var title_lb:Label;
	private var name_ti:TextInput;
	private var key_ti:TextInput;
	private var dname_ti:TextInput;	
	private var power_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		title_lb.text = node.nodeName;
		for (var toggle in toggles) {
			toggle_dg.addItem({name:toggles[toggle].attributes["NAME"], key:toggles[toggle].attributes["KEY"], display_name:toggles[toggle].attributes["DISPLAY_NAME"],power:toggles[toggle].attributes["POWER_RATING"], active:toggles[toggle].attributes["ACTIVE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		toggle_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		toggle_dg.removeItemAt(toggle_dg.selectedIndex);
		toggle_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text ="";
		power_ti.text = "";
	}
	private function updateItem() {
		if(active_chk.selected){
			var active = "Y";
		}
		else{
			var active = "N";
		}
		if (toggle_dg.selectedIndex != undefined) {
			toggle_dg.getItemAt(toggle_dg.selectedIndex).name = name_ti.text;
			toggle_dg.getItemAt(toggle_dg.selectedIndex).key = key_ti.text;
			toggle_dg.getItemAt(toggle_dg.selectedIndex).display_name = dname_ti.text;
			toggle_dg.getItemAt(toggle_dg.selectedIndex).power = power_ti.text;
			toggle_dg.getItemAt(toggle_dg.selectedIndex).active = active;			
		} else {
			toggle_dg.addItem({name:name_ti.text, key:key_ti.text, display_name:dname_ti.text, power:power_ti.text, active:active});
		}
		toggle_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		toggle_dg.selectedIndex = undefined;
		active_chk.selected = false;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text ="";
		power_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = toggle_dg.selectedItem.name;
		key_ti.text = toggle_dg.selectedItem.key;
		dname_ti.text = toggle_dg.selectedItem.display_name;
		power_ti.text = toggle_dg.selectedItem.power;
		if(toggle_dg.selectedItem.active == "N"){
			active_chk.selected = false;
		}
		else{
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		switch(title_lb.text){
			case"Toggle Inputs":
			var type = "TOGGLE_INPUT";
			break;
			case"Toggle Outputs":
			var type = "TOGGLE_OUTPUT";
			break;
			case"Pulse Outputs":
			var type = "PULSE_OUTPUT";
			break;
		}
		var newToggles = new Array();
		for(var index = 0; index < toggle_dg.length; index++){
			var toggleNode = new XMLNode(1, type);
			toggleNode.attributes["NAME"] = toggle_dg.getItemAt(index).name;
			toggleNode.attributes["KEY"] = toggle_dg.getItemAt(index).key;
			toggleNode.attributes["DISPLAY_NAME"] = toggle_dg.getItemAt(index).display_name;
			toggleNode.attributes["ACTIVE"] = toggle_dg.getItemAt(index).active;
			toggleNode.attributes["POWER_RATING"] = toggle_dg.getItemAt(index).power;
			newToggles.push(toggleNode);
		}
		_global.left_tree.selectedNode.toggles = newToggles;
	}
}
