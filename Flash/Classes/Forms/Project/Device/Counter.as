import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Counter extends Forms.BaseForm {
	private var save_btn:Button;
	private var counters:Array;
	private var counters_dg:DataGrid;
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
		dataGridHandler.setDataGrid(counters_dg);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false);
		dataGridHandler.addTextInputColumn("key", "?", restrictions, false);
		dataGridHandler.addTextInputColumn("max", "Max", restrictions, false);
		dataGridHandler.addTextInputColumn("power", "Power Rating", restrictions, false);
		dataGridHandler.addCheckColumn("active", "Active", values, false);
		dataGridHandler.setAdvanced(false);
		//Debug						
		var DP = new Array();
		for (var counter in counters) {
			var newCounter = new Object();
			newCounter.name = "";
			newCounter.display_name = "";
			newCounter.key = "";
			newCounter.active = "Y";
			newCounter.max = "";
			newCounter.power = "";
			if (counters[counter].attributes["NAME"] != undefined) {
				newCounter.name = counters[counter].attributes["NAME"];
			}
			if (counters[counter].attributes["DISPLAY_NAME"] != undefined) {
				newCounter.display_name = counters[counter].attributes["DISPLAY_NAME"];
			}
			if (counters[counter].attributes["KEY"] != undefined) {
				newCounter.key = counters[counter].attributes["KEY"];
			}
			if (counters[counter].attributes["ACTIVE"] != undefined) {
				newCounter.active = counters[counter].attributes["ACTIVE"];
			}
			if (counters[counter].attributes["MAX"] != undefined) {
				newCounter.max = counters[counter].attributes["MAX"];
			}
			if (counters[counter].attributes["POWER_RATING"] != undefined) {
				newCounter.power = counters[counter].attributes["POWER_RATING"];
			}
			DP.push(newCounter);
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
		var newCounters = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var newCounter = new XMLNode(1, "COUNTER");
			if (DP[index].name != "") {
				newCounter.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].display_name != "") {
				newCounter.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			if (DP[index].key != "") {
				newCounter.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].active != "") {
				newCounter.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].max != "") {
				newCounter.attributes["MAX"] = DP[index].max;
			}
			if (DP[index].power != "") {
				newCounter.attributes["POWER_RATING"] = DP[index].power;
			}
			newCounters.push(newCounter);
		}
		_global.left_tree.selectedNode.object.setData({counters:newCounters});
	}
}
