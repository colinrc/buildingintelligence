import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Property extends Forms.BaseForm {
	private var zones:Array;
	private var zones_li:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var zone in zones) {
			zones_li.addItem({label:zones[zone].name});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		zones_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		zones_li.removeItemAt(zones_li.selectedIndex);
		zones_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		zones_li.addItem({label:name_ti.text});
		zones_li.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newZones = new Array();
		for(var index = 0; index < zones_li.length; index++){
			var Zone = new Object();
			Zone.name = zones_li.getItemAt(index).label;
			newZones.push(Zone);
		}
		_global.left_tree.selectedNode.object.setData(new Object({zones:newZones}));
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
