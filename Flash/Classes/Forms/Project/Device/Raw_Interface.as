import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Raw_Interface {
	private var name_ti:TextInput;
	private var dname_ti:TextInput;
	private var power_ti:TextInput;
	private var node:XMLNode;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		save_btn.addEventListener("click", Delegate.create(this, save));
		name_ti.text = node.attributes["NAME"];
		dname_ti.text = node.attributes["DISPLAY_NAME"];
		power_ti.text = node.attributes["POWER_RATING"];
	}
	private function save():Void {
		_global.left_tree.selectedNode.attributes["NAME"] = name_ti.text;
		_global.left_tree.selectedNode.attributes["DISPLAY_NAME"] = dname_ti.text;
		_global.left_tree.selectedNode.attributes["POWER_RATING"] = power_ti.text;
	}
}
