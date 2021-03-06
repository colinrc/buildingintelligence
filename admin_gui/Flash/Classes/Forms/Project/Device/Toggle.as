﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Toggle extends Forms.BaseForm {
	private var save_btn:Button;
	private var toggle_type:String;
	private var toggles:Array;
	private var toggle_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var title_lb:Label;
	private var dataObject:Object;
	public function onLoad() {
		switch (toggle_type) {
		case "TOGGLE_INPUT" :
			title_lb.text = "Toggle Inputs:";
			var keyType = "Input\nNo. (DEC)";
			break;
		case "M1_OUTPUT":
		case "TOGGLE_OUTPUT" :
			title_lb.text = "Toggle Outputs:";
			var keyType = "Output\nNo. (DEC)";
			break;
		case "PULSE_OUTPUT" :
			title_lb.text = "Pulse Outputs:";
			var keyType = "Output\nNo. (DEC)";
			break;
		case "OUTPUT" :
			title_lb.text = "Outputs:";
			var keyType = "Output\nName";
			break;
		case "SENSOR":
			title_lb.text = "Sensor:";
			var keyType = "Sensor\nName";
			break;
		case "THERMOSTAT":
			title_lb.text = "Thermostat:";
			var keyType = "Thermostat\nName";
			break;
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9";
		var powerRestrictions = new Object();
		powerRestrictions.maxChars = 3;
		powerRestrictions.restrict = "0-9";		
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(toggle_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false, 150);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false, 150);
		if((toggle_type == "SENSOR")||(toggle_type =="OUTPUT")){
			dataGridHandler.addTextInputColumn("key", keyType, restrictions, false, 200);
		}
		else if (toggle_type == "M1_OUTPUT")
		{
			dataGridHandler.addTextInputColumn("key", keyType, powerRestrictions, false, 200);
		}
		else
		{
			dataGridHandler.addTextInputColumn("key", keyType, keyRestrictions, false, 60);
			dataGridHandler.addTextInputColumn("power", "Power\nRating", powerRestrictions, true, 80);
		}
		dataGridHandler.setDataGridDataProvider(toggles);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function setAdvanced() {
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
		dataObject.setData({toggles:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
