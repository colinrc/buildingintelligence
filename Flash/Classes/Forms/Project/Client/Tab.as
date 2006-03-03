import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Tab extends Forms.BaseForm {
	private var controls:Array;
	private var controls_dg:DataGrid;
	private var name:String;
	private var name_ti:TextInput;
	private var icon:String;
	private var icon_ti:TextInput;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function onLoad() {
		name_ti.text = name;
		icon_ti.text = icon;
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
		dataGridHandler.addTextInputColumn("name", "Control Name", restrictions,100);
		dataGridHandler.addTextInputColumn("icons", "Icons", restrictions,150);
		dataGridHandler.addComboBoxColumn("key", "Key", DPKey,100);
		dataGridHandler.addComboBoxColumn("type", "Control Type", DPControl,100);
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
		for (var index = 0; index < DP.length; index++) {
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
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls, name:name_ti.text, icon:icon_ti.text}));
		_global.needSave();						
		_global.refreshTheTree();		
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);		
	}
}
