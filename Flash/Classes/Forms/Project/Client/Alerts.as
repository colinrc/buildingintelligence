import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Alerts extends Forms.BaseForm {
	private var alerts:Array;
	private var alerts_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var x_pos:String;
	private var x_ti:TextInput;
	private var y_pos:String;
	private var y_ti:TextInput;
	//******************************//	
	private var left_li:ComboBox;
	private var right_li:ComboBox;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	//******************************//	
	private var dataGridHandler:Object;
	public function init() {
		x_ti.text = x_pos;
		y_ti.text = y_pos;
		var tempKeys = _global.server_test.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
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
		dataGridHandler.addTextInputColumn("name", "Alert Name", restrictions);
		dataGridHandler.addTextInputColumn("icon", "Icon", restrictions);
		dataGridHandler.addTextInputColumn("fadeOutTime", "Fade Out Time", restrictions);
		dataGridHandler.addTextInputColumn("keys", "Selected Keys", restrictions2);
		dataGridHandler.addButtonColumn("selectKeys", "Selected Keys", attributes, Delegate.create(this, saveItem));
		var DP = new Array();
		for (var alert in alerts) {
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
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		save_btn.addEventListener("click", Delegate.create(this, save));
		alerts_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function saveItem(evtObj) {
		var newKeys = "";
		for (var item in right_li.dataProvider) {
			newKeys += right_li.dataProvider[item].label;
			if (item != right_li.dataProvider.length-1) {
				newKeys += ", ";
			}
		}
		alerts_dg.dataProvider[evtObj.itemIndex].keys.label = newKeys;
	}
	private function itemChange(evtObj) {
		remAll();
		var alertKeys:Array = alerts_dg.selectedItem.keys.label.split(",");
		for (var key in alertKeys) {
			right_li.addItem({label:alertKeys[key]});
		}
	}
	public function save():Void {
		var newAlerts = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
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
		_global.left_tree.selectedNode.object.setData(new Object({alerts:newAlerts, x_pos:x_ti.text, y_pos:y_ti.text}));
	}
	private function addSel() {
		if (left_li.selectedItem != undefined) {
			var flag = false;
			for (var index = 0; index<right_li.length; index++) {
				if (left_li.selectedItem.label == right_li.getItemAt(index).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = left_li.selectedItem.label;
				right_li.addItem(newObject);
			}
		}
	}
	private function addAll() {
		for (var leftIndex = 0; leftIndex<left_li.length; leftIndex++) {
			var flag = false;
			for (var rightIndex = 0; rightIndex<right_li.length; rightIndex++) {
				if (left_li.getItemAt(leftIndex).label == right_li.getItemAt(rightIndex).label) {
					flag = true;
				}
			}
			if (!flag) {
				var newObject = new Object();
				newObject.label = left_li.getItemAt(leftIndex).label;
				right_li.addItem(newObject);
			}
		}
	}
	private function remSel() {
		if (right_li.selectedItem != undefined) {
			right_li.removeItemAt(right_li.selectedIndex);
		}
	}
	private function remAll() {
		right_li.removeAll();
	}
}
