import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.CbusSensors extends Forms.BaseForm {
	private var sensors:Array;
	private var sensors_dg:DataGrid;
	private var dataGridHandler:Object;
	private var save_btn:Button;
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
		dataGridHandler.setDataGrid(sensors_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);		
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "CBUS Key", restrictions,false);
		dataGridHandler.addTextInputColumn("channel", "Channel", restrictions,false);
		dataGridHandler.addTextInputColumn("units", "Units", restrictions,false);		
		dataGridHandler.addTextInputColumn("application", "CBUS App.", restrictions,false);
		dataGridHandler.addTextInputColumn("power", "Power Rating", restrictions,false);
		dataGridHandler.addCheckColumn("relay", "Relay", values,false);
		dataGridHandler.addCheckColumn("active", "Active", values,false);		
		dataGridHandler.setAdvanced(false);//Debug						
		var DP = new Array();		
		for (var sensor in sensors) {
			var newSensor = new Object();
			newSensor.name = "";
			newSensor.display_name = "";
			newSensor.key = "";
			newSensor.active = "Y";
			newSensor.power = "";
			newSensor.relay = "Y";
			newSensor.channel = "";
			newSensor.application = "";
			newSensor.units = "";
			if (sensors[sensor].attributes["NAME"] != undefined) {
				newSensor.name = sensors[sensor].attributes["NAME"];
			}
			if (sensors[sensor].attributes["DISPLAY_NAME"] != undefined) {
				newSensor.display_name = sensors[sensor].attributes["DISPLAY_NAME"];
			}
			if (sensors[sensor].attributes["KEY"] != undefined) {
				newSensor.key = sensors[sensor].attributes["KEY"];
			}
			if (sensors[sensor].attributes["ACTIVE"] != undefined) {
				newSensor.active = sensors[sensor].attributes["ACTIVE"];
			}
			if (sensors[sensor].attributes["POWER_RATING"] != undefined) {
				newSensor.power = sensors[sensor].attributes["POWER_RATING"];
			}
			if (sensors[sensor].attributes["RELAY"] != undefined) {
				newSensor.relay = sensors[sensor].attributes["RELAY"];
			}
			if (sensors[sensor].attributes["CHANNEL"] != undefined) {
				newSensor.channel = sensors[sensor].attributes["CHANNEL"];
			}
			if (sensors[sensor].attributes["CBUS_APPLICATION"] != undefined) {
				newSensor.application = sensors[sensor].attributes["CBUS_APPLICATION"];
			}
			if (sensors[sensor].attributes["UNITS"] != undefined) {
				newSensor.units = sensors[sensor].attributes["UNITS"];
			}
			DP.push(newSensor);
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
		var newSensors = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var newSensor = new XMLNode(1, "LIGHT_DYNALITE");
			if (DP[index].name != "") {
				newSensor.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].display_name != "") {
				newSensor.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].key != "") {
				newSensor.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].active != "") {
				newSensor.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].power != "") {
				newSensor.attributes["POWER_RATING"] = DP[index].power;
			}
			if (DP[index].relay != "") {
				newSensor.attributes["RELAY"] = DP[index].relay;
			}
			if (DP[index].channel != "") {
				newSensor.attributes["CHANNEL"] = DP[index].channel;
			}
			if (DP[index].application != "") {
				newSensor.attributes["CBUS_APPLICATION"] = DP[index].application;
			}
			if (DP[index].units != "") {
				newSensor.attributes["UNITS"] = DP[index].units;
			}
			newSensors.push(newSensor);
		}
		_global.left_tree.selectedNode.object.setData({sensors:newSensors});
	}
}
