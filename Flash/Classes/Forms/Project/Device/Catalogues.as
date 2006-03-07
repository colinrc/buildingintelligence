import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Catalogues extends Forms.BaseForm {
	private var catalogues:Array;
	private var catalogues_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;	
	public function onLoad() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(catalogues_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false,150);
		dataGridHandler.addHiddenColumn("id");
		dataGridHandler.setAdvanced(_global.advanced);//Debug						
		var DP = new Array();
		for (var catalogue in catalogues) {
			var newCatalogue = new Object();
			newCatalogue.name = catalogues[catalogue].name;
			newCatalogue.id = catalogues[catalogue].id;			
			DP.push(newCatalogue);
		}
		dataGridHandler.setDataGridDataProvider(DP);
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
		var newCatalogues = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Catalogue = new Object();
			Catalogue.name = DP[index].name;
			Catalogue.id = DP[index].id;			
			newCatalogues.push(Catalogue);
		}
		dataObject.setData({catalogues:newCatalogues});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
