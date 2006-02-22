import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Contact extends Forms.BaseForm {
	private var save_btn:Button;
	private var contacts:Array;
	private var contacts_dg:DataGrid;
	private var dataGridHandler:Object;
	private var new_btn:Button;
	private var delete_btn:Button;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(contacts_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false);
		dataGridHandler.addTextInputColumn("key", "?", restrictions, false);
		dataGridHandler.addTextInputColumn("box", "Box", restrictions, false);
		dataGridHandler.addCheckColumn("active", "Active", values, false);
		dataGridHandler.setAdvanced(false);
		//Debug						
		var DP = new Array();
		for (var contact in contacts) {
			var newContact = new Object();
			newContact.name = "";
			newContact.display_name = "";
			newContact.key = "";
			newContact.active = "Y";
			newContact.box = "";
			if (contacts[contact].attributes["NAME"] != undefined) {
				newContact.name = contacts[contact].attributes["NAME"];
			}
			if (contacts[contact].attributes["DISPLAY_NAME"] != undefined) {
				newContact.display_name = contacts[contact].attributes["DISPLAY_NAME"];
			}
			if (contacts[contact].attributes["KEY"] != undefined) {
				newContact.key = contacts[contact].attributes["KEY"];
			}
			if (contacts[contact].attributes["ACTIVE"] != undefined) {
				newContact.active = contacts[contact].attributes["ACTIVE"];
			}
			if (contacts[contact].attributes["BOX"] != undefined) {
				newContact.box = contacts[contact].attributes["BOX"];
			}
			DP.push(newContact);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		dataGridHandler.clearSelection();
		var newContacts = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var newContact = new XMLNode(1, "CONTACT_CLOSURE");
			if (DP[index].name != "") {
				newContact.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].display_name != "") {
				newContact.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].key != "") {
				newContact.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].active != "") {
				newContact.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].box != "") {
				newContact.attributes["BOX"] = DP[index].box;
			}
			newContacts.push(newContact);
		}
		_global.left_tree.selectedNode.object.setData({contacts:newContacts});
	}
}
