import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Contact {
	private var save_btn:Button;
	private var contacts:Array;
	private var contacts_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var key_ti:TextInput;
	private var box_ti:TextInput;
	private var active_chk:CheckBox;
	public function init() {
		for (var contact in contacts) {
			contacts_dg.addItem({name:contacts[contact].attributes["NAME"], display_name:contacts[contact].attributes["DISPLAY_NAME"], key:contacts[contact].attributes["KEY"], active:contacts[contact].attributes["ACTIVE"], box:contacts[contact].attributes["BOX"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		contacts_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		contacts_dg.removeItemAt(contacts_dg.selectedIndex);
		contacts_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		box_ti.text = "";
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (active_chk.selected) {
			var active = "Y";
		} else {
			var active = "N";
		}
		if (contacts_dg.selectedIndex != undefined) {
			contacts_dg.getItemAt(contacts_dg.selectedIndex).name = name_ti.text;
			contacts_dg.getItemAt(contacts_dg.selectedIndex).key = key_ti.text;
			contacts_dg.getItemAt(contacts_dg.selectedIndex).display_name = dname_ti.text;
			contacts_dg.getItemAt(contacts_dg.selectedIndex).active = active;
			contacts_dg.getItemAt(contacts_dg.selectedIndex).box = box_ti.text;
		} else {
			contacts_dg.addItem({name:name_ti.text, display_name:dname_ti.text, key:key_ti.text, active:active, box:box_ti.text});
		}
		contacts_dg.selectedIndex = undefined;
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		contacts_dg.selectedIndex = undefined;
		name_ti.text = "";
		dname_ti.text = "";
		key_ti.text = "";
		box_ti.text = "";
		active_chk.selected = false;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = contacts_dg.selectedItem.name;
		dname_ti.text = contacts_dg.selectedItem.display_name;
		key_ti.text = contacts_dg.selectedItem.key;
		box_ti.text = contacts_dg.selectedItem.box;
		var active = contacts_dg.selectedItem.active;
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newContacts = new Array();
		for (var index = 0; index<contacts_dg.length; index++) {
			var newContact = new XMLNode(1, "CONTACT_CLOSURE");
			newContact.attributes["NAME"] = contacts_dg.getItemAt(index).name;
			newContact.attributes["DISPLAY_NAME"] = contacts_dg.getItemAt(index).display_name;
			newContact.attributes["KEY"] = contacts_dg.getItemAt(index).key;
			newContact.attributes["ACTIVE"] = contacts_dg.getItemAt(index).active;
			newContact.attributes["BOX"] = contacts_dg.getItemAt(index).box;
			newContacts.push(newContact);
		}
		_global.left_tree.selectedNode.object.setData(new Object({contacts:newContacts}));
	}
}
