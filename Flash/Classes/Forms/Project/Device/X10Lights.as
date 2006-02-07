import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.X10Lights extends Forms.BaseForm {
	private var save_btn:Button;
	private var lights:Array;
	private var lights_dg:DataGrid;
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
		dataGridHandler.setDataGrid(lights_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addTextInputColumn("key", "Key", restrictions);
		dataGridHandler.addTextInputColumn("power", "Power", restrictions);
		dataGridHandler.addTextInputColumn("x10", "Housecode", restrictions);
		dataGridHandler.addCheckColumn("active", "Active", values);
		var DP = new Array();
		for (var light in lights) {
			var newLight = new Object();
			newLight.name = "";
			newLight.key = "";
			newLight.display_name = "";
			newLight.power = "";
			newLight.active = "Y";
			newLight.x10 = "";
			if (lights[light].attributes["NAME"] != undefined) {
				newLight.name = lights[light].attributes["NAME"];
			}
			if (lights[light].attributes["KEY"] != undefined) {
				newLight.key = lights[light].attributes["KEY"];
			}
			if (lights[light].attributes["DISPLAY_NAME"] != undefined) {
				newLight.display_name = lights[light].attributes["DISPLAY_NAME"];
			}
			if (lights[light].attributes["POWER_RATING"] != undefined) {
				newLight.power = lights[light].attributes["POWER_RATING"];
			}
			if (lights[light].attributes["ACTIVE"] != undefined) {
				newLight.active = lights[light].attributes["ACTIVE"];
			}
			if (lights[light].attributes["X10HOUSE_CODE"] != undefined) {
				newLight.x10 = lights[light].attributes["X10HOUSE_CODE"];
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
			var lightNode = new XMLNode(1, "LIGHT_X10");
			if (DP[index].name != "") {
				lightNode.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].key != "") {
				lightNode.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].display_name != "") {
				lightNode.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].active != "") {
				lightNode.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].power != "") {
				lightNode.attributes["POWER_RATING"] = DP[index].power;
			}
			if (DP[index].x10 != "") {
				lightNode.attributes["X10HOUSE_CODE"] = DP[index].x10;
			}
			newLights.push(lightNode);
		}
		_global.left_tree.selectedNode.object.setData({lights:newLights});
	}
}
