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
	private var dataObject:Object;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		icon_ti.addEventListener("change", changeListener);
		name_ti.text = name;
		icon_ti.text = icon;
		var tempKeys = _global.serverDesign.getKeys();
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
		dataGridHandler.addTextInputColumn("name", "Control Name", restrictions, false, 100);
		dataGridHandler.addTextInputColumn("icon1", "Icon1", restrictions, false, 150);
		dataGridHandler.addTextInputColumn("icon2", "Icon2", restrictions, false, 150);
		//dataGridHandler.addTextInputColumn("icons", "Icons", restrictions,false,150);
		dataGridHandler.addComboBoxColumn("key", "Key", DPKey, false, 100);
		dataGridHandler.addComboBoxColumn("type", "Control Type", DPControl, false, 100);
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
				var newIcons = controls[control].attributes["icons"].split(",");
				if (newIcons[0].length) {
					newControl.icon1 = newIcons[0];
				} else {
					newControl.icon1 = "";
				}
				if (newIcons[1].length) {
					newControl.icon2 = newIcons[1];
				} else {
					newControl.icon2 = "";
				}
			} else {
				newControl.icon1 = "";
				newControl.icon2 = "";
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
			if (DP[index].icon1.length) {
				if (DP[index].icon2.length) {
					var newIcons = new Array();
					newIcons.push(DP[index].icon1);
					newIcons.push(DP[index].icon2);
					item.attributes["icons"] = newIcons.join(",");
				} else {
					item.attributes["icons"] = DP[index].icon1;
				}
			} else {
				if (DP[index].icon2.length) {
					item.attributes["icons"] = DP[index].icon2;
				}
			}
			newControls.push(item);
		}
		dataObject.setData({controls:newControls, name:name_ti.text, icon:icon_ti.text});
		_global.saveFile("Project");
	}
}
