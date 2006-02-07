import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.CbusLights extends Forms.BaseForm {
	private var lights:Array;
	private var lights_dg:DataGrid;
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
		dataGridHandler.setDataGrid(lights_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addTextInputColumn("key", "CBUS Key", restrictions);
		dataGridHandler.addTextInputColumn("area", "CBUS Area", restrictions);
		dataGridHandler.addTextInputColumn("application", "CBUS App.", restrictions);
		dataGridHandler.addTextInputColumn("power", "Power Rating", restrictions);
		dataGridHandler.addCheckColumn("relay", "Relay", values);
		dataGridHandler.addCheckColumn("active", "Active", values);
		var DP = new Array();
		for (var light in lights) {
			var newLight = new Object();
			newLight.name = "";
			newLight.display_name = "";
			newLight.key = "";
			newLight.active = "Y";
			newLight.area = "";
			newLight.power = "";
			newLight.relay = "Y";
			newLight.application = "";
			if (lights[light].attributes["NAME"] != undefined) {
				newLight.name = lights[light].attributes["NAME"];
			}
			if (lights[light].attributes["DISPLAY_NAME"] != undefined) {
				newLight.display_name = lights[light].attributes["DISPLAY_NAME"];
			}
			if (lights[light].attributes["KEY"] != undefined) {
				newLight.key = lights[light].attributes["KEY"];
			}
			if (lights[light].attributes["ACTIVE"] != undefined) {
				newLight.active = lights[light].attributes["ACTIVE"];
			}
			if (lights[light].attributes["AREA"] != undefined) {
				newLight.area = lights[light].attributes["AREA"];
			}
			if (lights[light].attributes["POWER_RATING"] != undefined) {
				newLight.power = lights[light].attributes["POWER_RATING"];
			}
			if (lights[light].attributes["RELAY"] != undefined) {
				newLight.relay = lights[light].attributes["RELAY"];
			}
			if (lights[light].attributes["CBUS_APPLICATION"] != undefined) {
				newLight.application = lights[light].attributes["CBUS_APPLICATION"];
			}
			DP.push(newLight);
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
		var newLights = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var newLight = new XMLNode(1, "LIGHT_CBUS");
			if (DP[index].name != "") {
				newLight.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].display_name != "") {
				newLight.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].key != "") {
				newLight.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].active != "") {
				newLight.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].area != "") {
				newLight.attributes["AREA"] = DP[index].area;
			}
			if (DP[index].power != "") {
				newLight.attributes["POWER_RATING"] = DP[index].power;
			}
			if (DP[index].relay != "") {
				newLight.attributes["RELAY"] = DP[index].relay;
			}
			if (DP[index].application != "") {
				newLight.attributes["CBUS_APPLICATION"] = DP[index].application;
			}
			newLights.push(newLight);
		}
		_global.left_tree.selectedNode.object.setData({lights:newLights});
	}
}
