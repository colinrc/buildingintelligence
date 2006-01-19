import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Item {
	private var raws:Array;
	private var save_btn:mx.controls.Button;
	private var raw_dg:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var catalogue:String;
	private var catalogue_ti:TextInput;
	private var prefix:String;
	private var prefix_ti:TextInput;
	public function init():Void {
		for (var raw in raws) {
			raw_dg.addItem({name:raws[raw].command});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		raw_dg.addEventListener("change", Delegate.create(this, itemChange));
		catalogue_ti.text = catalogue;
		prefix_ti.text = prefix;
	}
	private function deleteItem() {
		raw_dg.removeItemAt(raw_dg.selectedIndex);
		raw_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		raw_dg.addItem({name:name_ti.text});
		raw_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = raw_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	private function save():Void {
		var newRaws = new Array();
		for(var index = 0; index < raw_dg.length; index++){
			var Raw = new Object();
			Raw.command = raw_dg.getItemAt(index).name;
			newRaws.push(Raw);
		}
		_global.left_tree.selectedNode.object.setData(new Object({raws:newRaws,catalogue:catalogue_ti.text,prefix:prefix_ti.text}));
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
