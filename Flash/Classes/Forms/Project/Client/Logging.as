import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Logging extends Forms.BaseForm {
	private var groups:Array;
	private var group_dg:DataGrid;
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
		dataGridHandler.setDataGrid(group_dg);
		dataGridHandler.addTextInputColumn("name", "Logging Group", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var group in groups) {
			var newGroup = new Object();
			newGroup.name = "";
			if (groups[group].name.length) {
				newGroup.name = groups[group].name;
				newGroup.id = groups[group].id;				
			}
			DP.push(newGroup);
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
		var newGroups = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var Group = new Object();
			Group.name = DP[index].name;
			Group.id = DP[index].id;			
			newGroups.push(Group);
		}
		dataObject.setData({groups:newGroups});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
