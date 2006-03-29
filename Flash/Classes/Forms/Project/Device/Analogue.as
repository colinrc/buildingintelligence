import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Analogue extends Forms.BaseForm {
	private var save_btn:Button;
	private var analogues:Array;
	private var analogues_dg:DataGrid;
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
		//analogues_dg.hScrollPolicy = "off";						
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(analogues_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false,150);		
		dataGridHandler.addTextInputColumn("name", "Description", restrictions,false,150);
		dataGridHandler.addTextInputColumn("key", "Input\nNo.", keyRestrictions,false,50);
		dataGridHandler.setAdvanced(_global.advanced);		
		dataGridHandler.setDataGridDataProvider(analogues);
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
		dataObject.setData({analogues:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile();		
	}
}
