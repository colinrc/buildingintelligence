import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_Relay {
	private var node:XMLNode;
	private var device:XMLNode;
	private var parameters:XMLNode;
	private var toggles:Array;
	private var parameters_mc:MovieClip;
	private var toggle_mc:MovieClip;
	private var name_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		toggles = new Array();
		name_ti.text = node.attributes["NAME"];
		save_btn.addEventListener("click", Delegate.create(this, save));
		processDevice();
	}
	private function processDevice():Void {
		for (var child in device.childNodes) {
			switch (device.childNodes[child].nodeName) {
			case "PARAMETERS" :
				parameters = device.childNodes[child];
				break;
			case "TOGGLE_OUTPUT" :
				toggles.push(device.childNodes[child]);
				break;
			}
		}
		parameters_mc.node = parameters;
		toggle_mc.toggles = toggles;
		toggle_mc.title_lb.text = "TOGGLE_OUTPUT";
	}
	private function save():Void {
		var newGC100_Relay = new XMLNode(1, "GC100_Relay");
		newGC100_Relay.appendChild(parameters_mc.getData());
		toggles = toggle_mc.getData();
		for (var toggle in toggles) {
			newGC100_Relay.appendChild(toggles[toggle]);
		}
		_global.left_tree.selectedNode.attributes["NAME"] = name_ti.text;
		_global.left_tree.selectedNode.device = newGC100_Relay;
	}
}
