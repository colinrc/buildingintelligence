import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Alerts extends Forms.BaseForm {
	private var alerts:Array;
	private var alerts_dg:DataGrid;
	private var save_btn:Button;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var x_pos:String;
	private var x_ti:TextInput;
	private var y_pos:String;
	private var y_ti:TextInput;
	private var alert_name_ti:TextInput;
	private var icon_ti:TextInput;
	private var fadeOutTime_ti:TextInput;
	private var left_li:ComboBox;
	private var right_li:ComboBox;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	public function init() {
		x_ti.text = x_pos;
		y_ti.text = y_pos;
		var tempKeys = _global.server_test.getKeys();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			left_li.addItem(tempObject);
		}
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
			alerts_dg.addItem(newAlert);
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		alerts_dg.addEventListener("change", Delegate.create(this, itemChange));
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		alerts_dg.removeItemAt(alerts_dg.selectedIndex);
		alerts_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		var newKeys = "";
		for (var key = 0; key<right_li.length; key++) {
			newKeys += right_li.getItemAt(key).label;
			if (key != right_li.length-1) {
				newKeys += ",";
			}
		}
		if (alerts_dg.selectedIndex != undefined) {
			alerts_dg.getItemAt(alerts_dg.selectedIndex).name = alert_name_ti.text;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).keys = newKeys;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).icon = icon_ti.text;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).fadeOutTime = fadeOutTime_ti.text;
		} else {
			alerts_dg.addItem({name:alert_name_ti.text, keys:newKeys, icon:icon_ti.text, fadeOutTime:fadeOutTime_ti.text});
		}
		alerts_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		alerts_dg.selectedIndex = undefined;
		alert_name_ti.text = "";
		icon_ti.text = "";
		fadeOutTime_ti.text = "";
		remAll();
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		alert_name_ti.text = alerts_dg.selectedItem.name;
		icon_ti.text = alerts_dg.selectedItem.icon;
		var alertKeys:Array = alerts_dg.selectedItem.keys.split(",");
		fadeOutTime_ti.text = alerts_dg.selectedItem.fadeOutTime;
		remAll();
		for (var key in alertKeys) {
			right_li.addItem({label:alertKeys[key]});
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newAlerts = new Array();
		for (var index = 0; index<alerts_dg.length; index++) {
			var item = new XMLNode(1, "alert");
			if (alerts_dg.getItemAt(index).name != "") {
				item.attributes["name"] = alerts_dg.getItemAt(index).name;
			}
			if (alerts_dg.getItemAt(index).icon != "") {
				item.attributes["icon"] = alerts_dg.getItemAt(index).icon;
			}
			if (alerts_dg.getItemAt(index).keys != "") {
				item.attributes["keys"] = alerts_dg.getItemAt(index).keys;
			}
			if (alerts_dg.getItemAt(index).fadeOutTime != "") {
				item.attributes["fadeOutTime"] = alerts_dg.getItemAt(index).fadeOutTime;
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
