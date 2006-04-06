import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Custom extends Forms.BaseForm {
	private var save_btn:Button;
	private var customs:Array;
	private var customs_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;		
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		customs_dg.hScrollPolicy = "auto";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(customs_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false,150);		
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false,150);
		dataGridHandler.addTextInputColumn("key", "Input\nNumber", restrictions,false,100);
		dataGridHandler.addCheckColumn("regex", "Key is\nRegEx.", values,false,70);		
		dataGridHandler.addTextInputColumn("command", "Command", restrictions,false,100);
		dataGridHandler.addTextInputColumn("extra", "Extra", restrictions,true,100);
		dataGridHandler.addTextInputColumn("extra2", "Extra2", restrictions,true,100);		
		dataGridHandler.addTextInputColumn("extra3", "Extra3", restrictions,true,100);		
		dataGridHandler.addTextInputColumn("extra4", "Extra4", restrictions,true,100);		
		dataGridHandler.addTextInputColumn("extra5", "Extra5", restrictions,true,100);		
		dataGridHandler.addTextInputColumn("power", "Power\nRating", restrictions,true,800);
		dataGridHandler.setDataGridDataProvider(customs);
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
		dataObject.setData({customs:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");		
	}
}
