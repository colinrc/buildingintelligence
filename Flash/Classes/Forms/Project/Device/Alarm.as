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
		dataGridHandler.addTextInputColumn("dname","eLife Name",restrictions);		
		dataGridHandler.addTextInputColumn("key","Key",restrictions);
		var DP = new Array();
		for (var alarm in alarms) {
			var newAlarm = new Object();
			newAlarm.key = "";
			newAlarm.dname = "";
			if(alarms[alarm].attributes["KEY"]!=undefined){
				newAlarm.key = alarms[alarm].attributes["KEY"];
			}
			if(alarms[alarm].attributes["DISPLAY_NAME"]!=undefined){
				newAlarm.dname = alarms[alarm].attributes["DISPLAY_NAME"];
			}
			DP.push(newAlarm);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
		delete_btn.enabled = false;
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
		delete_btn.enabled = false;
	}
	public function save():Void {
		var newAlarms = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "ALARM");
			//if(DP[index]["key"] != ""){
				item.attributes["KEY"] = DP[index]["key"];
			//}
			//if(DP[index]["dname"] != ""){
				item.attributes["DISPLAY_NAME"] = DP[index]["dname"];
 		    //}
			newAlarms.push(item);
		}
		_global.left_tree.selectedNode.object.setData({alarms:newAlarms});
	}
}
