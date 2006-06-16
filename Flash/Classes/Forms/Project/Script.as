import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Script extends Forms.BaseForm {
	private var save_btn:Button;
	private var scriptInfo:Array;
	private var scripts_dg:DataGrid;
	private var preview_ta:TextArea;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var import_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var values = new Object();
		values.True = "ENABLED";
		values.False = "DISABLED";
		scripts_dg.hScrollPolicy = "auto";
		var attributes = new Object();
		attributes.label = "Edit";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(scripts_dg);
		dataGridHandler.addTextInputColumn("name", "Script", restrictions, false, 300);
		dataGridHandler.addActiveColumn("enabled", values);
		dataGridHandler.addButtonColumn("Edit", "Edit", attributes, Delegate.create(this, editItem), false, 100);
		dataGridHandler.addHiddenColumn("status");
		dataGridHandler.setDataGridDataProvider(scriptInfo);
		dataGridHandler.setChangeCallBack(Delegate.create(this, change));
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		import_btn.addEventListener("click", Delegate.create(this, importScript));
	}
	public function setAdvanced() {
		dataGridHandler.setAdvanced();
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
		change(scripts_dg.length - 1);
	}
	private function importScript() {
		mdm.Dialogs.BrowseFile.buttonText = "Open";
		mdm.Dialogs.BrowseFile.title = "Please select a Script file to open";
		mdm.Dialogs.BrowseFile.dialogText = "Select a Script file to Use";
		mdm.Dialogs.BrowseFile.defaultExtension = "py";
		mdm.Dialogs.BrowseFile.filterList = "Python|*.py";
		mdm.Dialogs.BrowseFile.filterText = "Python files";
		var file = mdm.Dialogs.BrowseFile.show();
		if (file != "false") {
			//file
			//project_xml.load(file);
			if (!mdm.FileSystem.fileExists(_global.project.path + "server/script/" + file.substring(file.lastIndexOf("\\") + 1))) {
				mdm.FileSystem.copyFile(file, _global.project.path + "server/script/" + file.substring(file.lastIndexOf("\\") + 1));
			}
			dataGridHandler.addBlankRow();
			var script = scripts_dg.getItemAt(scripts_dg.length - 1);
			script.sel = false;
			script.name.label = file.substring(file.lastIndexOf("\\") + 1, file.lastIndexOf(".py"));
			scripts_dg.selectedIndex = scripts_dg.dataProvider.length - 1;
			scripts_dg.dataProvider.updateViews("change");
		}
		change(scripts_dg.length - 1);
	}
	private function change(itemIndex) {
		var file = scripts_dg.dataProvider[itemIndex].name.label + ".py";
		if (file != ".py") {
			if (mdm.FileSystem.fileExists(_global.project.path + "server/script/" + file)) {
				preview_ta.text = mdm.FileSystem.loadFile(_global.project.path + "server/script/" + file);
			} else {
				preview_ta.text = "<No data in script>";
			}
		}
	}
	private function editItem(itemLocation:Object) {
		var DP = dataGridHandler.getDataGridDataProvider();
		var file = DP[itemLocation.itemIndex].name + ".py";
		_global.Python_Editor(file);
	}
	public function save():Void {
		dataGridHandler.clearSelection();
		dataObject.setData({scriptInfo:dataGridHandler.getDataGridDataProvider()});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
