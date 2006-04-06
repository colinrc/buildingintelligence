import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.CbusRelays extends Forms.BaseForm {
	private var relays:Array;
	private var relays_dg:DataGrid;
	private var dataGridHandler:Object;
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var dataObject:Object;	
	public function CbusRelays() {
	}
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var keyRestrictions = new Object();
		keyRestrictions.maxChars = 2;
		keyRestrictions.restrict = "0-9A-Fa-f";
		var powerRestrictions = new Object();
		powerRestrictions.maxChars = 3;
		powerRestrictions.restrict = "0-9";		
		var values = new Object();
		values.True = "Y";
		values.False = "N";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(relays_dg);
		dataGridHandler.addActiveColumn("active", values);
		dataGridHandler.addTextInputColumn("display_name", "Key", restrictions, false,150);
		dataGridHandler.addTextInputColumn("name", "Description", restrictions, false,150);
		dataGridHandler.addTextInputColumn("key", "Group\nAddr.", keyRestrictions, false,60);
		dataGridHandler.addTextInputColumn("application", "CBUS\nApp.", keyRestrictions, true,60);
		dataGridHandler.addTextInputColumn("power", "Power\nRating", powerRestrictions, true,60);
		dataGridHandler.setDataGridDataProvider(relays);
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
		dataObject.setData({relays:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
