﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.AudioVideo {
	private var node:XMLNode;
	private var inputs_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var zone_ti:TextInput;
	private var name_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var child in node.childNodes) {
			if (node.childNodes[child].attributes["ACTIVE"] == "N") {
				var active = "N";
			} else {
				var active = "Y";
			}
			inputs_dg.addItem({key:node.childNodes[child].attributes["KEY"], name:node.childNodes[child].attributes["DISPLAY_NAME"], active:active});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		inputs_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		inputs_dg.removeItemAt(inputs_dg.selectedIndex);
		inputs_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (inputs_dg.selectedIndex != undefined) {
			inputs_dg.getItemAt(inputs_dg.selectedIndex).key = zone_ti.text;
			inputs_dg.getItemAt(inputs_dg.selectedIndex).name = name_ti.text;
			inputs_dg.getItemAt(inputs_dg.selectedIndex).active = active;
		} else {
			inputs_dg.addItem({key:zone_ti.text, name:name_ti.text, active:active});
		}
		inputs_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		inputs_dg.selectedIndex = undefined;
		zone_ti.text = "";
		name_ti.text = "";
		active_chk.selected = true;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		zone_ti.text = inputs_dg.selectedItem.key;
		name_ti.text = inputs_dg.selectedItem.name;
		var active = inputs_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Object {
		var itemType:String;
		switch (node.nodeName) {
		case "HAL":
		case "TUTONDO" :
			itemType = "AUDIO";
			break;
		case "KRAMER":
			itemType = "AV";
			break;
		}
		var inputs = new XMLNode(1, node.nodeName);
		for (var index = 0; index<inputs_dg.length; index++) {
			var item = new XMLNode(1, itemType);
			item.attributes["KEY"] = inputs_dg.getItemAt(index).key;
			item.attributes["DISPLAY_NAME"] = inputs_dg.getItemAt(index).name;
			item.attributes["ACTIVE"] = inputs_dg.getItemAt(index).active;
			inputs.appendChild(item);
		}
		return inputs;
	}
}
