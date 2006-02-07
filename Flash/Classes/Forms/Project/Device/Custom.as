import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Custom extends Forms.BaseForm {
	private var save_btn:Button;
	private var customs:Array;
	private var customs_dg:DataGrid;
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
		dataGridHandler.setDataGrid(customs_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addTextInputColumn("key", "Key", restrictions);
		dataGridHandler.addTextInputColumn("command", "Command", restrictions);
		dataGridHandler.addTextInputColumn("extra", "Extra", restrictions);
		dataGridHandler.addTextInputColumn("power", "Power Rating", restrictions);
		dataGridHandler.addCheckColumn("regex", "Key is Regex.", values);
		dataGridHandler.addCheckColumn("active", "Active", values);
		var DP = new Array();
		for (var custom in customs) {
			var newCustom = new Object();
			newCustom.name = "";
			newCustom.display_name = "";
			newCustom.key = "";
			newCustom.active = "Y";
			newCustom.command = "";
			newCustom.power = "";
			newCustom.regex = "Y";
			newCustom.extra = "";
			if (customs[custom].attributes["NAME"] != undefined) {
				newCustom.name = customs[custom].attributes["NAME"];
			}
			if (customs[custom].attributes["DISPLAY_NAME"] != undefined) {
				newCustom.display_name = customs[custom].attributes["DISPLAY_NAME"];
			}
			if (customs[custom].attributes["KEY"] != undefined) {
				newCustom.key = customs[custom].attributes["KEY"];
			}
			if (customs[custom].attributes["ACTIVE"] != undefined) {
				newCustom.active = customs[custom].attributes["ACTIVE"];
			}
			if (customs[custom].attributes["COMMAND"] != undefined) {
				newCustom.command = customs[custom].attributes["COMMAND"];
			}
			if (customs[custom].attributes["POWER_RATING"] != undefined) {
				newCustom.power = customs[custom].attributes["POWER_RATING"];
			}
			if (customs[custom].attributes["KEY_IS_REGEX"] != undefined) {
				newCustom.regex = customs[custom].attributes["KEY_IS_REGEX"];
			}
			if (customs[custom].attributes["EXTRA"] != undefined) {
				newCustom.extra = customs[custom].attributes["EXTRA"];
			}
			DP.push(newCustom);
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
		var newCustoms = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var newCustom = new XMLNode(1, "CUSTOM_INPUT");
			if (DP[index].name != "") {
				newCustom.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].display_name != "") {
				newCustom.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].key != "") {
				newCustom.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].active != "") {
				newCustom.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].command != "") {
				newCustom.attributes["COMMAND"] = DP[index].command;
			}
			if (DP[index].power != "") {
				newCustom.attributes["POWER_RATING"] = DP[index].power;
			}
			if (DP[index].regex != "") {
				newCustom.attributes["KEY_IS_REGEX"] = DP[index].regex;
			}
			if (DP[index].extra != "") {
				newCustom.attributes["EXTRA"] = DP[index].extra;
			}
			newCustoms.push(newCustom);
		}
		_global.left_tree.selectedNode.object.setData({customs:newCustoms});
	}
}
