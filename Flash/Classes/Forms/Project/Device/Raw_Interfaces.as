import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Interfaces {
	private var raw_interfaces:Array;
	private var interfaces_dg:DataGrid;
	private var save_btn:Button;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var raw_interface in raw_interfaces) {
			interfaces_dg.addItem({name:raw_interfaces[raw_interface].name});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		interfaces_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		interfaces_dg.removeItemAt(interfaces_dg.selectedIndex);
		interfaces_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		interfaces_dg.addItem({name:name_ti.text});
		interfaces_dg.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = interfaces_dg.selectedItem.name;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newRaw_Interfaces = new Array();
		for(var index = 0; index < interfaces_dg.length; index++){
			var Raw_Interface = new Object();
			Raw_Interface.name = interfaces_dg.getItemAt(index).name;
			newRaw_Interfaces.push(Raw_Interface);
		}
		_global.left_tree.selectedNode.object.setData(new Object({raw_interfaces:newRaw_Interfaces}));
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
