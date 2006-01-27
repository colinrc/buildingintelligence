import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Doors extends Forms.BaseForm {
	private var doors:Array;
	private var doors_dg:DataGrid;
	private var save_btn:Button;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var pos_ti:TextInput;
	private var key_cmb:ComboBox;
	private var colour_mc:MovieClip;

	public function init() {
		var tempKeys = _global.server_test.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			key_cmb.addItem(tempObject);
		}
		for(var door in doors){
			var newDoor = new Object();
			if(doors[door].attributes["name"] != undefined){
				newDoor.name = doors[door].attributes["name"];
			} else{
				newDoor.name = "";
			}
			if(doors[door].attributes["key"] != undefined){			
				newDoor.key = doors[door].attributes["key"];
			} else {
				newDoor.key = "";
			}
			if(doors[door].attributes["pos"] != undefined){						
				newDoor.pos = doors[door].attributes["pos"];
			} else {
				newDoor.pos = "";
			}				
			if(doors[door].attributes["colour"] != undefined){
				newDoor.colour = doors[door].attributes["colour"];
			} else {
				newDoor.colour = "";
			}
			doors_dg.addItem(newDoor);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		doors_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		doors_dg.removeItemAt(doors_dg.selectedIndex);
		doors_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (doors_dg.selectedIndex != undefined) {
			doors_dg.getItemAt(doors_dg.selectedIndex).name = name_ti.text;
			doors_dg.getItemAt(doors_dg.selectedIndex).key = key_cmb.text;
			doors_dg.getItemAt(doors_dg.selectedIndex).pos = pos_ti.text;
			doors_dg.getItemAt(doors_dg.selectedIndex).colour ="0x"+colour_mc.getColour().toString(16);
		} else {
			doors_dg.addItem({name:name_ti.text, key:key_cmb.text, pos:pos_ti.text, colour:"0x"+colour_mc.getColour().toString(16)});
		}
		doors_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}

	private function newItem() {
		doors_dg.selectedIndex = undefined;
		name_ti.text = "";
		key_cmb.text = "";
		pos_ti.text = "";
		colour_mc.setColour("OxFFFFFF");
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = doors_dg.selectedItem.name;
		key_cmb.text = doors_dg.selectedItem.key;
		pos_ti.text = doors_dg.selectedItem.pos;
		colour_mc.setColour(doors_dg.selectedItem.colour);
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newDoors = new Array();
		for (var index = 0; index<doors_dg.length; index++) {
			var item = new XMLNode(1, "door");
			if(doors_dg.getItemAt(index).name != ""){
				item.attributes["name"] = doors_dg.getItemAt(index).name;
			}
			if(doors_dg.getItemAt(index).key != ""){
				item.attributes["key"] = doors_dg.getItemAt(index).key;
			}
			if(doors_dg.getItemAt(index).pos !=""){
				item.attributes["pos"] = doors_dg.getItemAt(index).pos;
			}
			if(doors_dg.getItemAt(index).colour != "") {
				item.attributes["colour"] = doors_dg.getItemAt(index).colour;
			}
			newDoors.push(item);
		}
		_global.left_tree.selectedNode.object.setData(new Object({doors:newDoors}));
	}
}
