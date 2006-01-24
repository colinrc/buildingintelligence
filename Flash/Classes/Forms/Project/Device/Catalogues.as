import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Catalogues extends Forms.BaseForm {
	private var catalogues:Array;
	private var catalogues_dg:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var catalogue in catalogues) {
			catalogues_dg.addItem({name:catalogues[catalogue].name});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		catalogues_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		catalogues_dg.removeItemAt(catalogues_dg.selectedIndex);
		catalogues_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		catalogues_dg.addItem({name:name_ti.text});
		catalogues_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = catalogues_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newCatalogues = new Array();
		for(var index = 0; index < catalogues_dg.length; index++){
			var Catalogue = new Object();
			Catalogue.name = catalogues_dg.getItemAt(index).name;
			newCatalogues.push(Catalogue);
		}
		_global.left_tree.selectedNode.object.setData(new Object({catalogues:newCatalogues}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for(var child in _global.left_tree.selectedNode.childNodes){
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1,"Placeholder"));
		for(var child in newNode.childNodes){
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,true);
	}
}
