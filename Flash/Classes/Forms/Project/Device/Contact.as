import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Contact extends Forms.BaseForm {
	private var save_btn:Button;
	private var closure_type:String;
	private var contacts:Array;
	private var contacts_dg:DataGrid;
	private var dataGridHandler:Object;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataObject:Object;		
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();		
		keyRestrictions.maxChars = 3;
		keyRestrictions.restrict = "0-9";			
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(contacts_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false,200);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false,200);
		dataGridHandler.addTextInputColumn("key", "Input Key", keyRestrictions, false,80);
		if (closure_type == "DYNA"){
			dataGridHandler.addTextInputColumn("box", "Box", keyRestrictions, false,80);
		}
		dataGridHandler.setDataGridDataProvider(contacts);
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
		dataObject.setData({contacts:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");		
	}
}
