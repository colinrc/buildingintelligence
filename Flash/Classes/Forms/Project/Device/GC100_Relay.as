import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.GC100_Relay extends Forms.BaseForm {
	private var name:String;
	private var parameters:XMLNode;
	private var parameters_mc:MovieClip;
	private var name_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		name_ti.text = name;
		save_btn.addEventListener("click", Delegate.create(this, save));
		parameters_mc.node = parameters;
	}
	private function save():Void {
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({name:name_ti.text,parameters:parameters_mc.getData()}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
