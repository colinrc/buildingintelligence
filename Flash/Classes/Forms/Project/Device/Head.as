import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Head {
	private var node:XMLNode;
	private var connections:XMLNode;
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
		if (node.attributes["ACTIVE"] == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		name_lb.text = node.attributes["NAME"];
		dName_ti.text = node.attributes["DISPLAY_NAME"];
		save_btn.addEventListener("click", Delegate.create(this, save));
		processDevice();
	}
	private function processDevice():Void {
		connection_mc.node = connections;
		switch (node.attributes.NAME) {
		case "CBUS" :
		case "DYNALITE" :
		case "GC100":
			break;
		case "IR_LEARNER" :
		case "HAL" :
		case "TUTONDO" :
		case "KRAMER" :
		case "PELCO" :
		case "OREGON" :
		default :
			var dataObj = {node:parameters};
			parameters_mc = parameters_ld.attachMovie("forms.project.device.parameters", "parameters_mc", 0, dataObj);
			parameters_mc.dataObj = dataObj;
			break;
		}
	}
	private function save():Void {
		if (active_chk.selected) {
			_global.left_tree.selectedNode.attributes["ACTIVE"] = "Y";
		} else {
			_global.left_tree.selectedNode.attributes["ACTIVE"] = "N";
		}
		switch (node.attributes.NAME) {
		case "TUTONDO" :
		case "HAL" :
		case "KRAMER" :
		case "PELCO" :
		case "OREGON" :
			_global.left_tree.selectedNode.parameters = parameters_mc.getData();
			break;
		case "CBUS" :
		case "DYNALITE" :
		case "GC100":
		default:
			break;
		}
		_global.left_tree.selectedNode.connections = connection_mc.getData();
	}
}
