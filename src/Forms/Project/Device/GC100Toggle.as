import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100Toggle extends Forms.BaseForm {
	private var save_btn:Button;
	private var toggle_type:String;
	private var toggles:Array;
	private var toggle_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var title_lb:Label;
	private var modules:Array;
	private var dataObject:Object;	
	public function onLoad() {
		switch (toggle_type) {
		case "TOGGLE_INPUT" :
			title_lb.text = "Toggle Inputs:";
			var keyType = "Input\nNo. (HEX)";
			break;
		case "TOGGLE_OUTPUT" :
			title_lb.text = "Toggle Outputs:";
			var keyType = "Output\nNo. (HEX)";			
			break;
		}
		var DP = new Array();
		for(var module in modules){
			if((modules[module].type =="IR")&&(toggle_type =="TOGGLE_INPUT")){
				DP.push({label:modules[module].number});
			} else if((modules[module].type =="RELAY")&&(toggle_type =="TOGGLE_OUTPUT")){
				DP.push({label:modules[module].number});
			}
		}
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
		dataGridHandler.setDataGrid(toggle_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false,200);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false,200);
		dataGridHandler.addTextInputColumn("key", keyType, keyRestrictions, false,80);
		dataGridHandler.addComboBoxColumn("module", "Module No.", DP,false,80);		
		dataGridHandler.setDataGridDataProvider(toggles);
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
		dataObject.setData({toggles:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");		
	}
}
