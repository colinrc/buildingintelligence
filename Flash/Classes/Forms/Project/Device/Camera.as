import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Camera extends Forms.BaseForm {
	private var cameras:Array;
	private var cameras_dg:DataGrid;
	private var save_btn:Button;
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
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		//cameras_dg.hScrollPolicy = "off";		
		dataGridHandler.setDataGrid(cameras_dg);
		dataGridHandler.addActiveColumn("active", values);		
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false,150);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false,150);
		dataGridHandler.addTextInputColumn("key", "Camera\nZone", keyRestrictions,false,60);
		dataGridHandler.addTextInputColumn("zoom", "Camera\nZoom", keyRestrictions,false,60);		
		dataGridHandler.setDataGridDataProvider(cameras);
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
		dataObject.setData({cameras:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
