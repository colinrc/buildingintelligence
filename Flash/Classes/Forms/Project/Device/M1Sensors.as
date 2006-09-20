import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.M1Sensors extends Forms.BaseForm {
	private var sensors:Array;
	private var sensors_dg:DataGrid;
	private var dataGridHandler:Object;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataObject:Object;			
	public function M1Sensors(){
	}
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.rescrict = "";
		//var keyRestrictions = new Object();		
		//keyRestrictions.maxChars = 2;
		//keyRestrictions.restrict = "0-9";
		//var groupRestrictions.maxChars = 1;
		//groupRestrictions.restrict = "0-2";
		//var unitRestrictions.maxChars = 1;
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(sensors_dg);
		dataGridHandler.addActiveColumn("active", values);			
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false,200);		
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false,200);
/*		dataGridHandler.addTextInputColumn("key", "Device Number", keyRestrictions,false,100);
		dataGridHandler.addTextInputColumn("group", "Group", groupRestrictions,false,50); //decimal
		dataGridHandler.addTextInputColumn("units", "Units", keyRestrictions,false,50); //*/
		dataGridHandler.addComboBoxColumn("key", "Device\nNumber (HEX)", [{label:"01"}, {label:"02"}, {label:"03"}, {label:"04"}, {label:"05"}, {label:"06"}, {label:"07"}, {label:"08"}, {label:"09"}, {label:"10"}, {label:"11"}, {label:"12"}, {label:"13"}, {label:"14"}, {label:"15"}, {label:"16"}],false,120);
		dataGridHandler.addComboBoxColumn("group", "Group (HEX)", [{label:"0"}, {label:"1"}, {label:"2"}],false,80);
		dataGridHandler.addComboBoxColumn("units", "Units (HEX)", [{label:"C"}, {label:"F"}],false,80);
		dataGridHandler.setDataGridDataProvider(sensors);		
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
		dataObject.setData({sensors:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
