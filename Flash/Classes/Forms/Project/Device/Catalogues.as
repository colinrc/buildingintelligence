import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Catalogues {
	private var node:XMLNode;
	private var catalogues_dg:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var catalogue in node.childNodes) {
			catalogues_dg.addItem({name:node.childNodes[catalogue].attributes["NAME"]});
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
		for (var index = 0; index<catalogues_dg.length; index++) {
			var found = false;
			for (var catalogue in node.childNodes) {
				if (node.childNodes[catalogue].attributes["NAME"] == catalogues_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				newCatalogues.push({name:catalogues_dg.getItemAt(index).name});
			}
		}
		var deletedCatalogues = new Array();
		for (var catalogue in node.childNodes) {
			var found = false;
			for (var index = 0; index<catalogues_dg.length; index++) {
				if (node.childNodes[catalogue].attributes["NAME"] == catalogues_dg.getItemAt(index).name) {
					found = true;
				}
			}
			if (found == false) {
				deletedCatalogues.push({name:node.childNodes[catalogue].attributes["NAME"]});
			}
		}
		for (var delCatalogue in deletedCatalogues) {
			for (var catalogue in node.childNodes) {
				if (deletedCatalogues[delCatalogue].name == node.childNodes[catalogue].attributes["NAME"]) {
					node.childNodes[catalogue].removeNode();
				}
			}
		}
		for (var newCatalogue in newCatalogues) {
			var newNode = new XMLNode(1, "CATALOGUE");
			newNode.attributes["NAME"] = newCatalogues[newCatalogue].name;
			node.appendChild(newNode);
		}
	}
}
