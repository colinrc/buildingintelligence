import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.AlertGroups extends Forms.BaseForm {
	private var alertgroups:Array;
	private var alertgroups_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		var restrictions = new Object();
		var restrictions2 = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		restrictions2.editable = false;
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(alertgroups_dg);
		dataGridHandler.addTextInputColumn("alert", "Alert Group", restrictions2,false,100);
		dataGridHandler.addTextInputColumn("x_pos", "x Pos", restrictions,false,150);
		dataGridHandler.addTextInputColumn("y_pos", "y Pos", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");		
		var DP = new Array();
		for (var alertgroup in alertgroups) {
			var newAlertGroup = new Object();
			newAlertGroup.alert = "Alert";
			newAlertGroup.x_pos = alertgroups[alertgroup].x_pos;
			newAlertGroup.y_pos = alertgroups[alertgroup].y_pos;
			newAlertGroup.id = alertgroups[alertgroup].id;			
			DP.push(newAlertGroup);
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
		alertgroups_dg.getItemAt(0).alert.label = "Alert";
	}
	public function save():Void {
		var newAlertGroup = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var AlertGroup = new Object();
			AlertGroup.x_pos = DP[index].x_pos;
			AlertGroup.y_pos = DP[index].y_pos;
			AlertGroup.id = DP[index].id;
			newAlertGroup.push(AlertGroup);
		}
		dataObject.setData({alertgroups:newAlertGroup});
		_global.saveFile("Project");
	}
}
