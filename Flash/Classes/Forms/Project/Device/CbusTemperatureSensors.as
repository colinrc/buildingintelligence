﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.CbusTemperatureSensors extends Forms.BaseForm {
	private var sensors:Array;
	private var sensors_dg:DataGrid;
	private var dataGridHandler:Object;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	public function CbusTemperatureSensors(){
	}
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9A-Fa-f";		
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(sensors_dg);
		dataGridHandler.addActiveColumn("active", values);		
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);		
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Unit Address", keyRestrictions,false);
		dataGridHandler.setAdvanced(_global.advanced );
		dataGridHandler.setDataGridDataProvider(sensors);
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
		dataGridHandler.clearSelection();		
		_global.left_tree.selectedNode.object.setData({sensors:dataGridHandler.getDataGridDataProvider()});
	}
}
