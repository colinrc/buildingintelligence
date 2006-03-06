import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Alert extends Forms.BaseForm {
	private var save_btn:Button;
	private var alerts:Array;
	private var alerts_dg:DataGrid;
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
		keyRestrictions.restrict = "1-0A-Fa-f";				
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		alerts_dg.hScrollPolicy = "auto";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alerts_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false,150);
		dataGridHandler.addTextInputColumn("key", "Comfort\nCode", keyRestrictions,false,40);
		dataGridHandler.addTextInputColumn("cat", "Client\nCatagory", restrictions,false,100);
		dataGridHandler.addComboBoxColumn("type", "Alert\nType", [{label:"Alarm Type"}, {label:"DoorBell"}, {label:"ID"}, {label:"ModeChange"}, {label:"Phone"}, {label:"System"}, {label:"User"}, {label:"Zone"}],false,100);
		dataGridHandler.addTextInputColumn("message", "Message", restrictions,false,100);
		dataGridHandler.setAdvanced(_global.advanced);	
		dataGridHandler.setDataGridDataProvider(alerts);
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
		dataObject.setData({alerts:dataGridHandler.getDataGridDataProvider()});
		_global.saveFile("Project");		
	}
}
