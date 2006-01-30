import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Panel extends Forms.BaseForm {
	private var controls:Array;
	private var controls_dg:DataGrid;
	private var save_btn:Button;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name:String;
	private var name_ti:TextInput;
	private var x_pos:String;
	private var x_pos_ti:TextInput;
	private var y_pos:String;
	private var y_pos_ti:TextInput;
	private var height:String;
	private var height_ti:TextInput;
	private var width:String;
	private var width_ti:TextInput;	
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
		var tempControlTypes = _global.client_test.getControlTypes();
		for(var controlType in tempControlTypes.childNodes){
			type_cmb.addItem({label:tempControlTypes.childNodes[controlType].attributes["type"]});
		}
		name_ti.text = name;
		x_pos_ti.text = x_pos;
		y_pos_ti.text = y_pos;
		width_ti.text = width;
		height_ti.text = height;		
		for(var control in controls){
			var newControl = new Object();
			if(controls[control].attributes["name"] != undefined){
				newControl.name = controls[control].attributes["name"];
		    } else {
				newControl.name = "";
			}
			if(controls[control].attributes["key"] != undefined){
				newControl.key = controls[control].attributes["key"];
			} else {
				newControl.key = "";
			}
			if(controls[control].attributes["type"] != undefined) {
				newControl.type = controls[control].attributes["type"];
			} else {
				newControl.type = "";
			}
			if(controls[control].attributes["icons"] != undefined) {
				newControl.icons = controls[control].attributes["icons"];
			} else{
				newControl.icons = "";
			}
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
			if(controls_dg.getItemAt(index).name != ""){
				item.attributes["name"] = controls_dg.getItemAt(index).name;
			}
			if(controls_dg.getItemAt(index).key !=""){
				item.attributes["key"] = controls_dg.getItemAt(index).key;
			}
			if(controls_dg.getItemAt(index).type !=""){
				item.attributes["type"] = controls_dg.getItemAt(index).type;
			}
			if(controls_dg.getItemAt(index).icons !=""){
				item.attributes["icons"] = controls_dg.getItemAt(index).icons;
			}
			newControls.push(item);
		}
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls,name:name_ti.text,x_pos:x_pos_ti.text,y_pos:y_pos_ti.text,width:width_ti.text,height:height_ti.text}));
	}
}
