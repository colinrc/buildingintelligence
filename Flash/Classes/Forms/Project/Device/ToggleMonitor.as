import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.ToggleMonitor extends Forms.BaseForm {
	private var monitors:Array;
	private var monitors_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;	
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(monitors_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions);
		dataGridHandler.addTextInputColumn("display_name", "eLife Name", restrictions);
		dataGridHandler.addTextInputColumn("key", "Key", restrictions);
		dataGridHandler.addCheckColumn("active", "Active", values);
		var DP = new Array();		
		for (var monitor in monitors) {
			var newMonitor = new Object();
			newMonitor.key = "";
			newMonitor.name = "";
			newMonitor.display_name = "";
			newMonitor.active = "Y";			
			if (monitors[monitor].attributes["KEY"] != undefined) {
				newMonitor.key = monitors[monitor].attributes["KEY"];
			}
			if (monitors[monitor].attributes["NAME"] != undefined) {
				newMonitor.name = monitors[monitor].attributes["NAME"];
			}
			if (monitors[monitor].attributes["DISPLAY_NAME"] != undefined) {
				newMonitor.display_name = monitors[monitor].attributes["DISPLAY_NAME"];
			}
			if (monitors[monitor].attributes["ACTIVE"] != undefined) {
				newMonitor.active = monitors[monitor].attributes["ACTIVE"];
			}			
			DP.push(newMonitor);
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
		var newMonitors = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "TOGGLE_OUTPUT_MONITOR");
			if (DP[index].key != "") {
				item.attributes["KEY"] = DP[index].key;
			}
			if (DP[index].name != "") {
				item.attributes["NAME"] = DP[index].name;
			}
			if (DP[index].active != "") {
				item.attributes["ACTIVE"] = DP[index].active;
			}
			if (DP[index].display_name != "") {
				item.attributes["DISPLAY_NAME"] = DP[index].display_name;
			}
			newMonitors.push(item);
		}
		_global.left_tree.selectedNode.object.setData({monitors:newMonitors});
	}
}
