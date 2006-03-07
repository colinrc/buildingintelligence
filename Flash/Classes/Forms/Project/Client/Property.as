import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Property extends Forms.BaseForm {
	private var zones:Array;
	private var zones_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(zones_dg);
		dataGridHandler.addTextInputColumn("name", "Zone Name", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var zone in zones) {
			var newZone = new Object();
			newZone.name = zones[zone].name;
			newZone.id = zones[zone].id;
			DP.push(newZone);
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
		var newZones = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Zone = new Object();
			Zone.name = DP[index].name;
			Zone.id = DP[index].id;			
			newZones.push(Zone);
		}
		dataObject.setData({zones:newZones});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
