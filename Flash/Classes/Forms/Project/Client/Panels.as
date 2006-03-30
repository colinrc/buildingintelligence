import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Panels extends Forms.BaseForm {
	private var panels:Array;
	private var save_btn:Button;	
	private var dataGridHandler2:Object;
	private var panels_dg:DataGrid;
	private var add_panel_btn:Button;
	private var del_panel_btn:Button;
	private var dataObject:Object;	
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";		
		dataGridHandler2 = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler2.setDataGrid(panels_dg);
		dataGridHandler2.addTextInputColumn("name", "Panel Name", restrictions,false,150);
		dataGridHandler2.addHiddenColumn("id");		
		var DP2 = new Array();
		for (var panel in panels) {
			var newPanel = new Object();
			newPanel.name = panels[panel].name;
			newPanel.id = panels[panel].id;			
			DP2.push(newPanel);
		}
		dataGridHandler2.setDataGridDataProvider(DP2);
		del_panel_btn.addEventListener("click", Delegate.create(this, deletePanel));
		add_panel_btn.addEventListener("click", Delegate.create(this, addPanel));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deletePanel() {
		dataGridHandler2.removeRow();
	}
	private function addPanel() {
		dataGridHandler2.addBlankRow();
	}
	public function save():Void {
		var newPanels = new Array();
		var DP = dataGridHandler2.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Panel = new Object();
			Panel.name = DP[index].name;
			Panel.id = DP[index].id;			
			newPanels.push(Panel);
		}
		dataObject.setPanels({panels:newPanels});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
