import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_Modules {
	private var modules:Array;
	private var modules_dg:DataGrid;
	private var type_cb:ComboBox;
	private var save_btn:Button;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	public function init() {
		for (var module in modules) {
			modules_dg.addItem({name:modules[module].name, type:modules[module].type});
		}
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		modules_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		modules_dg.removeItemAt(modules_dg.selectedIndex);
		modules_dg.selectedIndex = undefined;
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
	}
	private function addItem() {
		modules_dg.addItem({name:name_ti.text, type:type_cb.selectedItem.label});
		modules_dg.selectedIndex = undefined;
		name_ti.text = "";
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		name_ti.text = modules_dg.selectedItem.name;
		if (modules_dg.selectedItem.type == "GC100_Relay") {
			type_cb.selectedIndex = 1;
		} else {
			type_cb.selectedIndex = 0;
		}
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newModules = new Array();
		for(var index = 0; index < modules_dg.length; index++){
			var module = new Object();
			module.type = modules_dg.getItemAt(index).type;
			module.name = modules_dg.getItemAt(index).name;
			newModules.push(module);
		}
		_global.left_tree.selectedNode.object.setData(new Object({modules:newModules}));
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
