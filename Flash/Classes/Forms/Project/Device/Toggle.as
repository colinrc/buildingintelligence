import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Toggle extends Forms.BaseForm {
	private var save_btn:Button;
	private var toggle_type:String;
	private var toggles:Array;
	private var toggle_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var title_lb:Label;
	public function init() {
		switch (toggle_type) {
		case "TOGGLE_INPUT" :
			title_lb.text = "Toggle Inputs";
			break;
		case "TOGGLE_OUTPUT" :
			title_lb.text = "Toggle Outputs";
			break;
		case "PULSE_OUTPUT" :
			title_lb.text = "Pulse Outputs";
			break;
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(toggle_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false);
		dataGridHandler.addTextInputColumn("key", "?", restrictions, false);
		dataGridHandler.addTextInputColumn("power", "Power Rating", restrictions, false);
		dataGridHandler.addCheckColumn("active", "Active", values, false);
		dataGridHandler.setAdvanced(false);
		//Debug				
		var DP = new Array();
		for (var toggle in toggles) {
			var newToggle = new Object();
			newToggle.name = "";
			newToggle.key = "";
			newToggle.display_name = "";
			newToggle.power = "";
			newToggle.active = "Y";
			if (toggles[toggle].attributes["NAME"] != undefined) {
				newToggle.name = toggles[toggle].attributes["NAME"];
			}
			if (toggles[toggle].attributes["KEY"] != undefined) {
				newToggle.key = toggles[toggle].attributes["KEY"];
			}
			if (toggles[toggle].attributes["DISPLAY_NAME"] != undefined) {
				newToggle.display_name = toggles[toggle].attributes["DISPLAY_NAME"];
			}
			if (toggles[toggle].attributes["POWER_RATING"] != undefined) {
				newToggle.power = toggles[toggle].attributes["POWER_RATING"];
			}
			if (toggles[toggle].attributes["ACTIVE"] != undefined) {
				newToggle.active = toggles[toggle].attributes["ACTIVE"];
			}
			DP.push(newToggle);
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
		var newToggles = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var toggleNode = new XMLNode(1, toggle_type);
			if (DP[index].name != "") {
				toggleNode.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].key != "") {
				toggleNode.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].display_name != "") {
				toggleNode.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].active != "") {
				toggleNode.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].power != "") {
				toggleNode.attributes["POWER_RATING"] = DP[index].power;
			}
			newToggles.push(toggleNode);
		}
		_global.left_tree.selectedNode.object.setData(new Object({toggles:newToggles}));
	}
}
