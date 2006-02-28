import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Head extends Forms.BaseForm {
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	private var connection_mc:MovieClip;
	private var parameters_mc:MovieClip;
	private var device_type_lb:mx.controls.Label;
	private var description_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	private var active_chk:mx.controls.CheckBox;
	public function Head() {
	}
	public function onLoad():Void {
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		device_type_lb.text = device_type;
		description_ti.text = description;
		save_btn.addEventListener("click", Delegate.create(this, save));
		connection_mc.node = connection;
		parameters_mc.node = parameters;
	}
	private function save():Void {
		var newData = new Object();
		newData.device_type = device_type_lb.text;
		newData.description = description_ti.text;
		if (active_chk.selected) {
			newData.active = "Y";
		} else {
			newData.active = "N";
		}
		newData.parameters = parameters_mc.getData();
		newData.connection = connection_mc.getData();
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(newData);
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
