import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Raw_Connection extends Forms.BaseForm {
	private var device:Object;
	private var customs_mc:MovieClip;
	private var interfaces_mc:MovieClip;
	private var items_mc:MovieClip;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		save_btn.addEventListener("click", Delegate.create(this, save));
		items_mc.raw_items = device.raw_items;
		customs_mc.customs = device.customs;
		interfaces_mc.interfaces = device.raw_interfaces;
	}
	private function save():Void {
		device.customs = customs_mc.getData();
		device.raw_items = items_mc.getData();
		device.raw_interfaces = interfaces_mc.getData();
		_global.left_tree.selectedNode.device = device;
	}
}
