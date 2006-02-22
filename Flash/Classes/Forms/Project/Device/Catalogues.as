import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Catalogues extends Forms.BaseForm {
	private var catalogues:Array;
	private var catalogues_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(catalogues_dg);
		dataGridHandler.addTextInputColumn("name", "Name", restrictions,false);
		dataGridHandler.setAdvanced(false);//Debug						
		var DP = new Array();
		for (var catalogue in catalogues) {
			var newCatalogue = new Object();
			newCatalogue.name = catalogues[catalogue].name;
			DP.push(newCatalogue);
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
		dataGridHandler.clearSelection();		
		var newCatalogues = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index<DP.length; index++) {
			var Catalogue = new Object();
			Catalogue.name = DP[index].name;
			newCatalogues.push(Catalogue);
		}
		_global.left_tree.selectedNode.object.setData({catalogues:newCatalogues});
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for (var child in _global.left_tree.selectedNode.childNodes) {
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1, "Placeholder"));
		for (var child in newNode.childNodes) {
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
