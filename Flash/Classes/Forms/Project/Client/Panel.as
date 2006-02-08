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
	private var dataGridHandler:Object;
	public function init() {
		name_ti.text = name;
		x_pos_ti.text = x_pos;
		y_pos_ti.text = y_pos;
		width_ti.text = width;
		height_ti.text = height;
		var tempKeys = _global.server_test.getKeys();
		var DPKey = new Array();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		var tempControlTypes = _global.client_test.getControlTypes();
		var DPControl = new Array();
		for (var controlType in tempControlTypes.childNodes) {
			var tempObject = new Object();
			tempObject.label = tempControlTypes.childNodes[controlType].attributes["type"];
			DPControl.push(tempObject);
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(controls_dg);
		dataGridHandler.addTextInputColumn("name", "Control Name", restrictions);
		dataGridHandler.addTextInputColumn("icons", "Icons", restrictions);
		dataGridHandler.addComboBoxColumn("key", "Key", DPKey);
		dataGridHandler.addComboBoxColumn("type", "Control Type", DPControl);
		var DP = new Array();
		for (var control in controls) {
			var newControl = new Object();
			if (controls[control].attributes["name"] != undefined) {
				newControl.name = controls[control].attributes["name"];
			} else {
				newControl.name = "";
			}
			if (controls[control].attributes["key"] != undefined) {
				newControl.key = controls[control].attributes["key"];
			} else {
				newControl.key = "";
			}
			if (controls[control].attributes["type"] != undefined) {
				newControl.type = controls[control].attributes["type"];
			} else {
				newControl.type = "";
			}
			if (controls[control].attributes["icons"] != undefined) {
				newControl.icons = controls[control].attributes["icons"];
			} else {
				newControl.icons = "";
			}
			DP.push(newControl);
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
		var newControls = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "control");
			if (DP[index].name.length) {
				item.attributes["name"] = DP[index].name;
			}
			if (DP[index].key.length) {
				item.attributes["key"] = DP[index].key;
			}
			if (DP[index].type.length) {
				item.attributes["type"] = DP[index].type;
			}
			if (DP[index].icons.length) {
				item.attributes["icons"] = DP[index].icons;
			}
			newControls.push(item);
		}
		_global.left_tree.selectedNode.object.setData({controls:newControls, name:name_ti.text, x_pos:x_pos_ti.text, y_pos:y_pos_ti.text, width:width_ti.text, height:height_ti.text});
	}
}
