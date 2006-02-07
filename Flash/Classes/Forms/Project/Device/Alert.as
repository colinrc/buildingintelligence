import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Alert extends Forms.BaseForm {
	private var save_btn:Button;
	private var alerts:Array;
	private var alerts_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alerts_dg);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addTextInputColumn("key", "Key", restrictions);
		dataGridHandler.addTextInputColumn("cat", "Client Catagory", restrictions);
		dataGridHandler.addComboBoxColumn("type", "Alert Type", [{label:"Alarm Type"}, {label:"DoorBell"}, {label:"ID"}, {label:"ModeChange"}, {label:"Phone"}, {label:"System"}, {label:"User"}, {label:"Zone"}]);
		dataGridHandler.addTextInputColumn("message", "Message", restrictions);
		dataGridHandler.addCheckColumn("active", "Active", values);
		var DP = new Array();
		for (var alert in alerts) {
			var newAlert = new Object();
			newAlert.key = "";
			newAlert.display_name = "";
			newAlert.message = "";
			newAlert.active = "Y";
			newAlert.type = "";
			newAlert.cat = "";
			if (alerts[alert].attributes["KEY"] != undefined) {
				newAlert.key = alerts[alert].attributes["KEY"];
			}
			if (alerts[alert].attributes["DISPLAY_NAME"] != undefined) {
				newAlert.display_name = alerts[alert].attributes["DISPLAY_NAME"];
			}
			if (alerts[alert].attributes["CLIENT_CAT"] != undefined) {
				newAlert.cat = alerts[alert].attributes["CLIENT_CAT"];
			}
			if (alerts[alert].attributes["ACTIVE"] != undefined) {
				newAlert.active = alerts[alert].attributes["ACTIVE"];
			}
			if (alerts[alert].attributes["MESSAGE"] != undefined) {
				newAlert.message = alerts[alert].attributes["MESSAGE"];
			}
			if (alerts[alert].attributes["ALERT_TYPE"] != undefined) {
				newAlert.type = alerts[alert].attributes["ALERT_TYPE"];
			}
			DP.push(newAlert);
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
		var newAlerts = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var alertNode = new XMLNode(1, "ALERT");
			if (DP[index].key != "") {
				alertNode.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].display_name != "") {
				alertNode.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].active != "") {
				alertNode.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].cat != "") {
				alertNode.attributes["CLIENT_CAT"] = DP[index].cat;
			}
			if (DP[index].message != "") {
				alertNode.attributes["MESSAGE"] = DP[index].message;
			}
			if (DP[index].type != "") {
				alertNode.attributes["ALERT_TYPE"] = DP[index].type;
			}
			newAlerts.push(alertNode);
		}
		_global.left_tree.selectedNode.object.setData({alerts:newAlerts});
	}
}
