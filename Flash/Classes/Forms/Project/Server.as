﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Server extends Forms.BaseForm {
	private var devices:Array;
	private var description:String;
	private var description_ta:TextArea;
	private var devices_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;	
	public function onLoad() {
		description_ta.text = description;
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
		    _global.unSaved = true;
		};
		description_ta.addEventListener("change", changeListener);		
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(devices_dg);
		dataGridHandler.addComboBoxColumn("device_type", "Device Type", [{label:"IR_LEARNER"}, {label:"PELCO"}, {label:"GC100"}, {label:"TUTONDO"}, {label:"DYNALITE"}, {label:"COMFORT"}, {label:"RAW_CONNECTION"}, {label:"HAL"}, {label:"OREGON"}, {label:"KRAMER"}, {label:"CBUS"}],false,120);
		dataGridHandler.addTextInputColumn("description", "Description", restrictions,false,150);
		dataGridHandler.setAdvanced(_global.advanced);		
		var DP = new Array();
		for (var device in devices) {
			var newDevice = new Object();
			newDevice.device_type = devices[device].device_type;
			newDevice.description = devices[device].description;
			DP.push(newDevice);
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
		var newDevices = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var device = new Object();
			device.device_type = DP[index].device_type;
			device.description = DP[index].description;
			newDevices.push(device);
		}
		dataObject.setData({description:description_ta.text, devices:newDevices});
		_global.saveFile("Project");				
		_global.refreshTheTree();		
		dataGridHandler.clearSelection();		
	}
}
