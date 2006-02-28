﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Camera extends Forms.BaseForm {
	private var cameras:Array;
	private var cameras_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "1-0A-Fa-f";					
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(cameras_dg);
		dataGridHandler.addActiveColumn("active", values);		
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);
		dataGridHandler.addTextInputColumn("key", "Camera Zone", keyRestrictions,false);
		dataGridHandler.addTextInputColumn("zoom", "Camera Zoom", keyRestrictions,false);		
		dataGridHandler.setAdvanced(_global.advanced);				
		dataGridHandler.setDataGridDataProvider(cameras);
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
		_global.left_tree.selectedNode.object.setData({cameras:dataGridHandler.getDataGridDataProvider()});
	}
}
