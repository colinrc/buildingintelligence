import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Raw_Interface extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var name:String;
	private var dname_ti:TextInput;
	private var display_name:String;
	private var power_ti:TextInput;
	private var power:String;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		save_btn.addEventListener("click", Delegate.create(this, save));
		name_ti.text = name;
		dname_ti.text = display_name;
		power_ti.text = power;
	}
	private function save():Void {
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({name:name_ti.text,display_name:dname_ti.text,power:power_ti.text}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
