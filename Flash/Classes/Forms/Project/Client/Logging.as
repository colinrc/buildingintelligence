import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.Logging extends Forms.BaseForm {
	private var groups:Array;
	private var group_li:List;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var group in groups) {
			group_li.addItem({label:groups[group].name});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		group_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		group_li.removeItemAt(group_li.selectedIndex);
		group_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		group_li.addItem({label:name_ti.text});
		group_li.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newGroups = new Array();
		for(var index = 0; index < group_li.length; index++){
			var Group = new Object();
			Group.name = group_li.getItemAt(index).label;
			newGroups.push(Group);
		}
		_global.left_tree.selectedNode.object.setData(new Object({groups:newGroups}));
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
