import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Alarm extends Forms.BaseForm {
	private var save_btn:Button;
	private var alarms:Array;
	private var alarms_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;	
	public function Alarm(){
	}
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		//alarms_dg.hScrollPolicy = "off";		
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alarms_dg);
		dataGridHandler.addTextInputColumn("display_name","Key",restrictions,false,150);		
		dataGridHandler.addTextInputColumn("name","Description",restrictions,false,150);				
		dataGridHandler.addTextInputColumn("key","Alarm\nCode",restrictions,false,100);
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
		dataObject.setData({alarms:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");				
	}
}
