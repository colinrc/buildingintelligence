import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.IR extends Forms.BaseForm {
	private var dataObject:Object;	
	/*public var server_socket:XMLSocket;
	public var monitor_socket:XMLSocket;*/
	private var action_cb:mx.controls.ComboBox;
	private var action_lb:mx.controls.Label;
	private var cancel_btn:mx.controls.Button;
	private var device_cb:mx.controls.ComboBox;
	private var device_lb:mx.controls.Label;
	private var learn_btn:mx.controls.Button;
	private var avname_ti:mx.controls.TextInput;
	private var reload_btn:mx.controls.Button;
	private var repeat_ti:mx.controls.TextInput;
	private var repeat_lb:mx.controls.Label;
	private var status_lb:mx.controls.Label;
	private var test_btn:mx.controls.Button;
	private var value_lb:mx.controls.Label;
	private var value_100_rb:mx.controls.RadioButton;
	private var value_20_rb:mx.controls.RadioButton;
	private var value_35_rb:mx.controls.RadioButton;
	private var value_50_rb:mx.controls.RadioButton;
	public function IR() {
	}
	public function onLoad():Void {
		value_100_rb.addEventListener("click", Delegate.create(this, changeValue));
		value_20_rb.addEventListener("click", Delegate.create(this, changeValue));
		value_35_rb.addEventListener("click", Delegate.create(this, changeValue));
		value_50_rb.addEventListener("click", Delegate.create(this, changeValue));
		device_cb.addEventListener("change", Delegate.create(this, deviceChange));
		action_cb.addEventListener("change", Delegate.create(this, actionChange));
		learn_btn.addEventListener("click", Delegate.create(this, learn));
		cancel_btn.addEventListener("click", Delegate.create(this, cancel));
		test_btn.addEventListener("click", Delegate.create(this, test));
		reload_btn.addEventListener("click", Delegate.create(this, reload));
	}
	private function changeValue(eventObj):Void {
		var xmlMsg = new XML('<IR_CONFIG EXTRA="'+eventObj.target.selection.data+'" />\n');
		//server_socket.send(xmlMsg);
	}
	public function setSockets(inServer_socket:XMLSocket, inMonitor_socket:XMLSocket):Void {
		//server_socket = inServer_socket;
		//monitor_socket = inMonitor_socket;
	}
	public function deviceChange(eventObj):Void {
		var xmlMsg = new XML('<LIST_IR_ACTIONS DEVICE="'+device_cb.selectedItem.label+'" />\n');
		//server_socket.send(xmlMsg);
		learn_btn.enabled = false;
	}
	public function actionChange(eventObj):Void {
		learn_btn.enabled = true;
	}
	private function learn():Void {
		var irName:String = device_cb.selectedItem.label+"."+action_cb.selectedItem.label;
		var xmlMsg = new XML('<IR_LEARN NAME="'+irName+'" />\n');
		//server_socket.send(xmlMsg);
		status_lb.text = "Learning "+irName;
		learn_btn.enabled = false;
	}
	private function cancel():Void {
		//if((ir_device_cb.selectedIndex>-1)&&(ir_action_cb.selectedItem.selectedIndex>-1)) {
		//ir_learn_btn.enabled = true;
		//}
		//ir_status_lb.text ="Canceled learning ";
	}
	private function test():Void {
		var xmlMsg = new XML('<TEST_IR DEVICE="'+device_cb.selectedItem.label+'" ACTION="'+action_cb.selectedItem.label+'" TARGET="'+avname_ti.text+'" REPEAT="'+repeat_ti.text+'" />\n');
		//server_socket.send(xmlMsg);
	}
	private function reload():Void {
		action_cb.removeAll();
		var xmlMsg = new XML('<RELOAD_IRDB />\n');
		//server_socket.send(xmlMsg);
		learn_btn.enabled = false;
	}
	public function irLearnt(inNode:XMLNode):Void {
		status_lb.text = inNode.attributes["RESULT"];
		learn_btn.enabled = true;
	}
	public function irResult(inNode:XMLNode):Void {
		status_lb.text = inNode.attributes["RESULT"];
		learn_btn.enabled = true;
	}
	public function deviceList(inNode:XMLNode):Void {
		action_cb.removeAll();
		device_cb.removeAll();
		if (inNode.hasChildNodes) {
			for (var child in inNode.childNodes) {
				device_cb.addItem(inNode.childNodes[child].attributes["NAME"]);
			}
		}
		status_lb.text = "IR Devices loaded";
	}
	public function actionList(inNode:XMLNode):Void {
		action_cb.removeAll();
		if (inNode.hasChildNodes) {
			for (var child in inNode.childNodes) {
				action_cb.addItem(inNode.childNodes[child].attributes["NAME"]);
			}
		}
		status_lb.text = device_cb.selectedItem.label+" actions loaded";
	}
	public function processXML(inNode:XMLNode) {
		while (inNode != null) {
			/*if valid node, ignoreWhite isnt working properly*/
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "IR_DEVICE_LIST" :
					deviceList(inNode);
					break;
				case "IR_ACTION_LIST" :
					actionList(inNode);
					break;
				case "IR_CONFIG" :
					irResult(inNode);
					break;
				case "IR_LEARNT" :
					irLearnt(inNode);
					break;
				}
			}
			inNode = inNode.nextSibling;
		}
	}
}
