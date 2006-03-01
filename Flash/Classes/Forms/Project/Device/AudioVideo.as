import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.AudioVideo extends Forms.BaseForm {
	private var audiovideos:Array;
	private var container:String;
	private var inputs_dg:DataGrid;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataGridHandler:Object;
	private var title_lb:Label;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(inputs_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions,false);
		var itemType:String;
		switch (container) {
		case "HAL" :
		case "TUTONDO" :
			itemType = "Audio\nZone";
			title_lb.text = "Audio Zones";
			break;
		case "KRAMER" :
			itemType = "AV\nZone";
			title_lb.text = "AV Zones";
			break;
		}
		dataGridHandler.addTextInputColumn("key", itemType, restrictions,false);
		dataGridHandler.setAdvanced(_global.advanced);					
		dataGridHandler.setDataGridDataProvider(audiovideos);	
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
		_global.left_tree.selectedNode.object.setData({audiovideos:dataGridHandler.getDataGridDataProvider()});
	}
}
