﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.DMXLights extends Forms.BaseForm {
	private var save_btn:Button;
	private var lights:Array;
	private var lights_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9A-Fa-f";
		var powerRestrictions = new Object();
		powerRestrictions.maxChars = 3;
		powerRestrictions.restrict = "0-9";		
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(lights_dg);
		dataGridHandler.addActiveColumn("active", values);	
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false,150);		
		dataGridHandler.addTextInputColumn("name", "Descriptions", restrictions,false,150);
		dataGridHandler.addTextInputColumn("key", "DMX\nCode", keyRestrictions,false,60);
		dataGridHandler.setDataGridDataProvider(lights);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setAdvanced(){
		dataGridHandler.setAdvanced();
	}	
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		dataGridHandler.clearSelection();		
		dataObject.setData({lights:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
