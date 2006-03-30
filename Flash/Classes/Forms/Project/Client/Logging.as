import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Logging extends Forms.BaseForm {
	private var groups:Array;
	private var groups_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;	
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
		dataGridHandler.setDataGrid(groups_dg);
		dataGridHandler.addTextInputColumn("name", "Logging Group", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var group = 0; group<groups.length;group++){		
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
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));		
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function moveUp() {
		if (groups_dg.selectedIndex != undefined) {
			if (groups_dg.selectedIndex != groups_dg.length-1) {
				var tempObj = groups_dg.getItemAt(groups_dg.selectedIndex+1);
				groups_dg.replaceItemAt(groups_dg.selectedIndex+1, groups_dg.selectedItem);
				groups_dg.replaceItemAt(groups_dg.selectedIndex, tempObj);
				var tempIndex = groups_dg.selectedIndex+1;
				groups_dg.dataProvider.updateViews("change");
				groups_dg.selectedIndex = undefined;
				groups_dg.selectedIndices = undefined;
				//groups_dg.selectedIndex = tempIndex;
			}
			_global.unSaved = true;			
		}
	}
	private function moveDown() {
		if (groups_dg.selectedIndex != undefined) {
			if (groups_dg.selectedIndex != 0) {
				var tempObj = groups_dg.getItemAt(groups_dg.selectedIndex-1);
				groups_dg.replaceItemAt(groups_dg.selectedIndex-1, groups_dg.selectedItem);
				groups_dg.replaceItemAt(groups_dg.selectedIndex, tempObj);
				var tempIndex = groups_dg.selectedIndex-1;
				groups_dg.dataProvider.updateViews("change");
				groups_dg.selectedIndex = undefined;
				groups_dg.selectedIndices = undefined;
				//groups_dg.selectedIndex = tempIndex;
			}
			_global.unSaved = true;			
		}
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
