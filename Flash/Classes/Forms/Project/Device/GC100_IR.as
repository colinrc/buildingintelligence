import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.GC100_IR {
	private var node:XMLNode;
	private var device:XMLNode;
	private var parameters:XMLNode;
	private var toggles:Array;
	private var irs:Array;
	private var parameters_mc:MovieClip;
	private var toggle_mc:MovieClip;
	private var ir_mc:MovieClip;
	private var name_lb:mx.controls.Label;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		irs = new Array();
		toggles = new Array();
		name_lb.text = node.attributes["NAME"];
		save_btn.addEventListener("click", Delegate.create(this, save));
		processDevice();
	}
	private function processDevice():Void {
		for (var child in device.childNodes) {
			switch (device.childNodes[child].nodeName) {
			case "PARAMETERS" :
				parameters = device.childNodes[child];
				break;
			case "TOGGLE_INPUT" :
				toggles.push(device.childNodes[child]);
				break;
			case "IR" :
				irs.push(device.childNodes[child]);
				break;
			}
		}
		parameters_mc.node = parameters;
		ir_mc.irs = irs;
		toggle_mc.toggles = toggles;
		toggle_mc.title_lb.text = "TOGGLE_INPUT";
	}
	private function save():Void {
		var newGC100_IR = new XMLNode(1, "GC100_IR");
		newGC100_IR.appendChild(parameters_mc.getData());
		irs = ir_mc.getData();
		toggles = toggle_mc.getData();
		for (var ir in irs) {
			newGC100_IR.appendChild(irs[ir]);
		}
		for (var toggle in toggles) {
			newGC100_IR.appendChild(toggles[toggle]);
		}
		_global.left_tree.selectedNode.device = newGC100_IR;
	}
}
