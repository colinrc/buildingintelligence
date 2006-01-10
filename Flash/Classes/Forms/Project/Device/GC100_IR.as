import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_IR {
	private var node:XMLNode;
	private var parameters:XMLNode;
	private var parameters_mc:MovieClip;
	private var name_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		name_ti.text = node.attributes["NAME"];
		save_btn.addEventListener("click", Delegate.create(this, save));
		parameters_mc.node = parameters;
	}
	private function save():Void {
		_global.left_tree.selectedNode.attributes["NAME"] = name_ti.text;
		_global.left_tree.selectedNode.parameters = parameters_mc.getData();
	}
}
