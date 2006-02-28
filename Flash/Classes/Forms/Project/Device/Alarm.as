import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Alarm extends Forms.BaseForm {
	private var save_btn:Button;
	private var alarms:Array;
	private var alarms_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function Alarm(){
	}
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "1-0A-Fa-f";		
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alarms_dg);
		dataGridHandler.addTextInputColumn("display_name","Key",restrictions,false);		
		dataGridHandler.addTextInputColumn("key","Comfort Code",keyRestrictions,false);
		dataGridHandler.setAdvanced(_global.advanced);
		dataGridHandler.setDataGridDataProvider(alarms);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setAdvanced(){
		if(_global.advanced){
			dataGridHandler.setAdvanced(_global.advanced);
		} else {
			dataGridHandler.setAdvanced(_global.advanced);
		}
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
		_global.left_tree.selectedNode.object.setData({alarms:dataGridHandler.getDataGridDataProvider()});
	}
}
