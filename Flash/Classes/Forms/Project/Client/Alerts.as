import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Alerts extends Forms.BaseForm {
	private var alerts:Array;
	private var alerts_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name:String;
	private var name_ti:TextInput;
	private var x_pos:String;
	private var x_lb:Label;
	private var y_pos:String;
	private var y_lb:Label;
	//******************************//	
	private var left_li:List;
	private var right_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	//******************************//	
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		name_ti.text = name;
		x_lb.text = x_pos;
		y_lb.text = y_pos;
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path + "lib\\icons", "*.png");
		var IconDP = new Array();
		for (var myIcon = 0; myIcon < myIcons.length; myIcon++) {
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path + "lib\\icons\\" + myIcons[myIcon];
			IconDP.push(newIcon);
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var restrictions2 = new Object();
		restrictions2.maxChars = undefined;
		restrictions2.restrict = "";
		restrictions2.editable = false;
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alerts_dg);
		var attributes = new Object();
		attributes.label = "Set Keys";
		dataGridHandler.addTextInputColumn("name", "Alert Name", restrictions, false, 150);
		dataGridHandler.addIconComboBoxColumn("icon", "Icon", IconDP, false, 150);
		dataGridHandler.addTextInputColumn("fadeOutTime", "Fade Out Time", restrictions, false, 150);
		dataGridHandler.addHiddenColumn("keys");
		var DP = new Array();
		for (var alert = 0; alert < alerts.length; alert++) {
			var newAlert = new Object();
			if (alerts[alert].attributes["name"] != undefined) {
				newAlert.name = alerts[alert].attributes["name"];
			} else {
				newAlert.name = "";
			}
			if (alerts[alert].attributes["keys"] != undefined) {
				newAlert.keys = alerts[alert].attributes["keys"];
			} else {
				newAlert.keys = "";
			}
			if (alerts[alert].attributes["icon"] != undefined) {
				newAlert.icon = alerts[alert].attributes["icon"];
			} else {
				newAlert.icon = "";
			}
			if (alerts[alert].attributes["fadeOutTime"] != undefined) {
				newAlert.fadeOutTime = alerts[alert].attributes["fadeOutTime"];
			} else {
				newAlert.fadeOutTime = "";
			}
			DP.push(newAlert);
		}
		right_li.multipleSelection = true;
		left_li.multipleSelection = true;
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		save_btn.addEventListener("click", Delegate.create(this, save));
		alerts_dg.addEventListener("change", Delegate.create(this, itemChange));
		hideButtons(false);
	}
	private function deleteItem() {
		hideButtons(false);
		dataGridHandler.removeRow();
		_global.unSaved = true;
	}
	private function newItem() {
		hideButtons(false);
		dataGridHandler.addBlankRow();
		_global.unSaved = true;
	}
	private function itemChange(evtObj) {
		hideButtons(true);
		var alertKeys:Array = alerts_dg.selectedItem.keys.split(",");
		for (var key in alertKeys) {
			if (alertKeys[key].length) {
				var leftLength = left_li.dataProvider.length;
				for (var index = 0; index < leftLength; index++) {
					if (alertKeys[key] == left_li.getItemAt(index).label) {
						right_li.addItem(left_li.removeItemAt(index));
						break;
					}
				}
			}
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
		_global.unSaved = true;
	}
	public function save():Void {
		var newAlerts = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var item = new XMLNode(1, "alert");
			if (DP[index].name != "") {
				item.attributes["name"] = DP[index].name;
			}
			if (DP[index].icon != "") {
				item.attributes["icon"] = DP[index].icon;
			}
			if (DP[index].keys != "") {
				item.attributes["keys"] = DP[index].keys;
			}
			if (DP[index].fadeOutTime != "") {
				item.attributes["fadeOutTime"] = DP[index].fadeOutTime;
			}
			newAlerts.push(item);
		}
		dataObject.setData({name:name_ti.text, alerts:newAlerts});
		hideButtons(false);
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
	private function addSel() {
		if (left_li.selectedItems.length > 0) {
			for (var item = left_li.selectedIndices.length - 1; item >= 0; item--) {
				right_li.addItem(left_li.removeItemAt(left_li.selectedIndices[item]));
			}
			right_li.sortItemsBy("label", "ASC");
			left_li.sortItemsBy("label", "ASC");
			var newKeys = new Array();
			for (var item in right_li.dataProvider) {
				newKeys.push(right_li.dataProvider[item].label);
			}
			alerts_dg.selectedItem.keys = newKeys.join(",");
			_global.unSaved = true;
		}
	}
	private function addAll() {
		_global.unSaved = true;
		left_li.removeAll();
		right_li.removeAll();
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			right_li.addItem(tempObject);
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
		var newKeys = new Array();
		for (var item in right_li.dataProvider) {
			newKeys.push(right_li.dataProvider[item].label);
		}
		_global.unSaved = true;
		alerts_dg.selectedItem.keys = newKeys.join(",");
	}
	private function remSel() {
		if (right_li.selectedItems.length > 0) {
			for (var item = right_li.selectedIndices.length - 1; item >= 0; item--) {
				left_li.addItem(right_li.removeItemAt(right_li.selectedIndices[item]));
			}
			right_li.sortItemsBy("label", "ASC");
			left_li.sortItemsBy("label", "ASC");
			var newKeys = new Array();
			for (var item in right_li.dataProvider) {
				newKeys.push(right_li.dataProvider[item].label);
			}
			alerts_dg.selectedItem.keys = newKeys.join(",");
			_global.unSaved = true;
		}
	}
	private function remAll() {
		left_li.removeAll();
		right_li.removeAll();
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
		right_li.sortItemsBy("label", "ASC");
		left_li.sortItemsBy("label", "ASC");
		var newKeys = new Array();
		for (var item in right_li.dataProvider) {
			newKeys.push(right_li.dataProvider[item].label);
		}
		alerts_dg.selectedItem.keys = newKeys.join(",");
		_global.unSaved = true;
	}
	private function hideButtons(visible:Boolean) {
		left_li._visible = visible;
		right_li._visible = visible;
		addSelected_btn._visible = visible;
		addAll_btn._visible = visible;
		removeSelected_btn._visible = visible;
		removeAll_btn._visible = visible;
		right_li.removeAll();
		left_li.removeAll();
		var tempKeys = _global.serverDesign.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
	}
}
