import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Tab extends Forms.BaseForm {
	private var controls:Array;
	private var controls_dg:DataGrid;
	private var name:String;
	private var name_ti:TextInput;
	private var icon:String;
	private var icon_cmb:ComboBox;
	private var icon_ldr:Loader;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		icon_ldr.autoLoad = true;
		icon_ldr.scaleContent = true;
		icon_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path + "lib\\icons", "*.png");
		var IconDP = new Array();
		for (var myIcon = 0; myIcon < myIcons.length; myIcon++) {
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path + "lib\\icons\\" + myIcons[myIcon];
			IconDP.push(newIcon);
		}
		icon_cmb.dataProvider = IconDP;
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		name_ti.text = name;
		if (icon.length) {
			icon_cmb.text = icon;
			icon_ldr.load(mdm.Application.path + "lib\\icons\\" + icon + ".png");
		}
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		var foundNode = _global.searchProject(_global.left_tree.dataProvider, dataObject);
		var tempNode = foundNode.parentNode;
		while (tempNode.nodeName != "Client") {
			tempNode = tempNode.parentNode;
		}
		var tempControlTypes = tempNode.object.getControlTypes();
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
		dataGridHandler.addIconComboBoxColumn("icon1", "Icon 1", IconDP, false, 150);
		dataGridHandler.addIconComboBoxColumn("icon2", "Icon 2", IconDP, false, 150);
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
		icon_cmb.addEventListener("change", Delegate.create(this, loadIcon));
	}
	public function loadIcon(eventObject) {
		_global.unSaved = true;
		icon_ldr.load(icon_cmb.selectedItem.icon);
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
		dataObject.setData({controls:newControls, name:name_ti.text, icon:icon_cmb.text});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
