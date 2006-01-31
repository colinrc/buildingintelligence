import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Server extends Forms.BaseForm {
	private var devices:Array;
	private var description:String;
	private var description_ta:TextArea;
	private var devices_dg:DataGrid;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var type_cb:ComboBox;
	private var description_ti:TextInput;
	private var save_btn:Button;
	public function init() {
		description_ta.text = description;
		for (var device in devices) {
			devices_dg.addItem({device_type:devices[device].device_type, description:devices[device].description});
		}
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		devices_dg.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		devices_dg.removeItemAt(devices_dg.selectedIndex);
		devices_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		devices_dg.addItem({description:description_ti.text, device_type:type_cb.selectedItem.label});
		devices_dg.selectedIndex = undefined;
		description_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newDevices = new Array();
		for (var index = 0; index<devices_dg.length; index++) {
			var device = new Object();
			device.device_type = devices_dg.getItemAt(index).device_type;
			device.description = devices_dg.getItemAt(index).description;
			newDevices.push(device);
		}
		_global.left_tree.selectedNode.object.setData(new Object({description:description_ta.text, devices:newDevices}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for (var child in _global.left_tree.selectedNode.childNodes) {
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1, "Placeholder"));
		for (var child in newNode.childNodes) {
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
