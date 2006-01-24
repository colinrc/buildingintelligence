import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.ControlTypes extends Forms.BaseForm {
	private var controls:Array;
	private var controls_li:List;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		for (var control in controls) {
			controls_li.addItem({label:controls[control].type});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		controls_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		controls_li.removeItemAt(controls_li.selectedIndex);
		controls_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		controls_li.addItem({label:name_ti.text});
		controls_li.selectedIndex = undefined;
		name_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newControls = new Array();
		for(var index = 0; index < controls_li.length; index++){
			var Control = new Object();
			Control.type = controls_li.getItemAt(index).label;
			newControls.push(Control);
		}
		_global.left_tree.selectedNode.object.setData(new Object({controls:newControls}));
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
