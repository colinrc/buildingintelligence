import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Raw_Items extends Forms.BaseForm {
	private var raw_items:Array;
	private var raw_items_dg:DataGrid;
	private var delete_btn:Button;
	private var add_btn:Button;
	private var save_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var raw_item in raw_items) {
			raw_items_dg.addItem({name:raw_items[raw_item].catalogue});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		raw_items_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		raw_items_dg.removeItemAt(raw_items_dg.selectedIndex);
		raw_items_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		raw_items_dg.addItem({name:name_ti.text});
		raw_items_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = raw_items_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newRaw_Items = new Array();
		for(var index = 0; index < raw_items_dg.length; index++){
			var Raw_Item = new Object();
			Raw_Item.catalogue = raw_items_dg.getItemAt(index).name;
			newRaw_Items.push(Raw_Item);
		}
		_global.left_tree.selectedNode.object.setData(new Object({raw_items:newRaw_Items}));
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
