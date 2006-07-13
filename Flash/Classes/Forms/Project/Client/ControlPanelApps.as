import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlPanelApps extends Forms.BaseForm {
	private var save_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var apps_dg:DataGrid;
	private var apps:Array;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad():Void {	
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(apps_dg);
		dataGridHandler.addTextInputColumn("label", "Program Label", restrictions,false,150);
		dataGridHandler.addTextInputColumn("program", "Program Location", restrictions,false,150);
		var DP = new Array();
		for (var app =0; app < apps.length;app++) {
			var newApp = new Object();
			newApp.label = "";
			newApp.program = "";
			if (apps[app].attributes["label"] != undefined) {
				newApp.label = apps[app].attributes["label"];
			}
			if (apps[app].attributes["program"] != undefined) {
				newApp.program = apps[app].attributes["program"];
			}
			DP.push(newApp);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		save_btn.addEventListener("click", Delegate.create(this, save));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function save() {
		var newApps = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var newApp = new XMLNode(1, "app");
			if (DP[index].label.length) {
				newApp.attributes["label"] = DP[index].label;
			}
			if (DP[index].program.length) {
				newApp.attributes["program"] = DP[index].program;
			}
			newApps.push(newApp);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		dataObject.setData({apps:newApps});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
