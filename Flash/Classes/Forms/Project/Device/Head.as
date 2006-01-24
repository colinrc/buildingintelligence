import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Head extends Forms.BaseForm {
	private var name:String;
	private var display_name:String;
	private var active:String;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	private var connection_mc:MovieClip;
	private var parameters_mc:MovieClip;
	private var parameters_ld:mx.controls.Loader;
	private var name_lb:mx.controls.Label;
	private var dName_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	private var active_chk:mx.controls.CheckBox;
	public function Head() {
	}
	public function init():Void {
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		name_lb.text = name;
		dName_ti.text = display_name;
		save_btn.addEventListener("click", Delegate.create(this, save));
		connection_mc.node = connection;
		var dataObj = {node:parameters};
		parameters_mc = parameters_ld.attachMovie("forms.project.device.parameters", "parameters_mc", 0, dataObj);
		parameters_mc.dataObj = dataObj;
	}
	private function save():Void {		
		var newData = new Object();
		newData.name = name_lb.text;
		newData.display_name = dName_ti.text;
		if (active_chk.selected) {
			newData.active = "Y";
		}
		else{
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
