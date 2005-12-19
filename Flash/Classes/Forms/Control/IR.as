import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.IR {
	private var server:Objects.ServerObj;
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
	public function init() {
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
	private function changeValue(eventObj) {
		var xmlMsg = new XML('<IR_CONFIG EXTRA="'+eventObj.target.selection.data+'" />\n');
		server.sendToServer(xmlMsg);
	}
	public function setSockets(inServer:Objects.ServerObj) {
		server = inServer;
	}
	public function setVisible(showing:Boolean) {
		action_cb._visible = showing;
		action_lb._visible = showing;
		cancel_btn._visible = showing;
		device_cb._visible = showing;
		device_lb._visible = showing;
		learn_btn._visible = showing;
		avname_ti._visible = showing;
		reload_btn._visible = showing;
		repeat_ti._visible = showing;
		repeat_lb._visible = showing;
		status_lb._visible = showing;
		test_btn._visible = showing;
		value_lb._visible = showing;
		value_100_rb._visible = showing;
		value_20_rb._visible = showing;
		value_35_rb._visible = showing;
		value_50_rb._visible = showing;
	}
	public function deviceChange(eventObj) {
		var xmlMsg = new XML('<LIST_IR_ACTIONS DEVICE="'+device_cb.selectedItem.label+'" />\n');
		server.sendToServer(xmlMsg);
		learn_btn.enabled = false;
	}
	public function actionChange(eventObj) {
		learn_btn.enabled = true;
	}
	private function learn() {
		var irName:String = device_cb.selectedItem.label+"."+action_cb.selectedItem.label;
		var xmlMsg = new XML('<IR_LEARN NAME="'+irName+'" />\n');
		server.sendToServer(xmlMsg);
		status_lb.text = "Learning "+irName;
		learn_btn.enabled = false;
	}
	private function cancel() {
		//if((ir_device_cb.selectedIndex>-1)&&(ir_action_cb.selectedItem.selectedIndex>-1)) {
		//ir_learn_btn.enabled = true;
		//}
		//ir_status_lb.text ="Canceled learning ";
	}
	private function test() {
		var xmlMsg = new XML('<TEST_IR DEVICE="'+device_cb.selectedItem.label+'" ACTION="'+action_cb.selectedItem.label+'" TARGET="'+avname_ti.text+'" REPEAT="'+repeat_ti.text+'" />\n');
		server.sendToServer(xmlMsg);
	}
	private function reload() {
		action_cb.removeAll();
		var xmlMsg = new XML('<RELOAD_IRDB />\n');
		server.sendToServer(xmlMsg);
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
			for (var child:String in inNode.childNodes) {
				device_cb.addItem(inNode.childNodes[child].attributes["NAME"]);
			}
		}
		status_lb.text = "IR Devices loaded";
	}
	public function actionList(inNode:XMLNode):Void {
		action_cb.removeAll();
		if (inNode.hasChildNodes) {
			for (var child:String in inNode.childNodes) {
				action_cb.addItem(inNode.childNodes[child].attributes["NAME"]);
			}
		}
		status_lb.text = device_cb.selectedItem.label+" actions loaded";
	}
}
