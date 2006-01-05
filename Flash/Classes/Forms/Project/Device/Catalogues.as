import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Catalogues {
	private var catalogues:Array;
	private var catalogues_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var catalogue in catalogues) {
			catalogues_dg.addItem({name:catalogues[catalogue], oldName:catalogues[catalogue]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		catalogues_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		catalogues_dg.getItemAt(catalogues_dg.selectedIndex).name = "DELETED";
		catalogues_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateItem() {
		if (catalogues_dg.selectedIndex != undefined) {
			catalogues_dg.getItemAt(catalogues_dg.selectedIndex).name = name_ti.text;
		} else {
			catalogues_dg.addItem({name:name_ti.text});
		}
		catalogues_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		catalogues_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		name_ti.text = catalogues_dg.selectedItem.name;
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Array {
		var newCatalogues = new Array();
		for(var index = 0; index < catalogues_dg.length; index++){
			newCatalogues.push({name:catalogues_dg.getItemAt(index).name,oldName:catalogues_dg.getItemAt(index).oldName});
		}
		return newCatalogues;
	}
}
