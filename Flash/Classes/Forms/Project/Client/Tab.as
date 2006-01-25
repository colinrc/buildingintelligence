import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Tab extends Forms.BaseForm {
	private var controls:Array;
	private var controls_dg:DataGrid;
	private var save_btn:Button;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name:String;
	private var name_ti:TextInput;
	private var icon:String;
	private var icon_ti:TextInput;
	private var control_name_ti:TextInput;
	private var icons_ti:TextInput;
	private var key_cmb:ComboBox;
	private var type_cmb:ComboBox;

	public function init() {
		var tempKeys = _global.server_test.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			key_cmb.addItem(tempObject);
		}
		name_ti.text = name;
		icon_ti.text = icon;
		for(var control in controls){
			var newControl = new Object();
			newControl.name = controls[control].attributes["name"];
			newControl.key = controls[control].attributes["key"];
			newControl.type = controls[control].attributes["type"];
			newControl.icons = controls[control].attributes["icons"];
			controls_dg.addItem(newControl);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		controls_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		controls_dg.removeItemAt(controls_dg.selectedIndex);
		controls_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (controls_dg.selectedIndex != undefined) {
			controls_dg.getItemAt(controls_dg.selectedIndex).name = control_name_ti.text;
			controls_dg.getItemAt(controls_dg.selectedIndex).key = key_cmb.text;
			controls_dg.getItemAt(controls_dg.selectedIndex).type = type_cmb.text;
			controls_dg.getItemAt(controls_dg.selectedIndex).icons = icons_ti.text;
		} else {
			controls_dg.addItem({name:control_name_ti.text, key:key_cmb.text, type:type_cmb.text, icons:icons_ti.text});
		}
		controls_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		controls_dg.selectedIndex = undefined;
		control_name_ti.text = "";
		key_cmb.text = "";
		type_cmb.text = "";
		icons_ti.text ="";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		control_name_ti.text = controls_dg.selectedItem.name;
		key_cmb.text = controls_dg.selectedItem.key;
		type_cmb.text = controls_dg.selectedItem.type;
		icons_ti.text = controls_dg.selectedItem.icons;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newControls = new Array();
		for (var index = 0; index<controls_dg.length; index++) {
			var item = new XMLNode(1, "control");
			item.attributes["name"] = controls_dg.getItemAt(index).name;
			item.attributes["key"] = controls_dg.getItemAt(index).key;
			item.attributes["type"] = controls_dg.getItemAt(index).type;
			item.attributes["icons"] = controls_dg.getItemAt(index).icons;
			newControls.push(item);
		}
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls,name:name_ti.text,icon:icon_ti.text}));
	}
}
