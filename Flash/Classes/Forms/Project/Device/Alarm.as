import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Alarm extends Forms.BaseForm {
	private var save_btn:Button;
	private var alarms:Array;
	private var alarms_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alarms_dg);
		dataGridHandler.addTextInputColumn("display_name","Key",restrictions,false);		
		dataGridHandler.addTextInputColumn("key","?",restrictions,false);
		dataGridHandler.setAdvanced(false);//Debug
		var DP = new Array();
		for (var alarm in alarms) {
			var newAlarm = new Object();
			newAlarm.key = "";
			newAlarm.display_name = "";
			if(alarms[alarm].attributes["KEY"]!=undefined){
				newAlarm.key = alarms[alarm].attributes["KEY"];
			}
			if(alarms[alarm].attributes["DISPLAY_NAME"]!=undefined){
				newAlarm.display_name = alarms[alarm].attributes["DISPLAY_NAME"];
			}
			DP.push(newAlarm);
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
		var newAlarms = new Array();
		dataGridHandler.clearSelection();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ALARM");
			if(DP[index].key != ""){
				item.attributes["KEY"] = DP[index].key;
			}
			if(DP[index].display_name != ""){
				item.attributes["DISPLAY_NAME"] = DP[index].display_name;
 		    }
			newAlarms.push(item);
		}
		_global.left_tree.selectedNode.object.setData({alarms:newAlarms});
	}
}
