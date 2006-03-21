import mx.controls.*;
import mx.utils.Delegate;

class Forms.Control.ServerControls extends Forms.BaseForm {
	private var start_btn:mx.controls.Button;
	private var stop_btn:mx.controls.Button;
	private var restart_btn:mx.controls.Button;
	private var clear_btn:mx.controls.Button;
	private var client_restart_btn:mx.controls.Button;
	private var ver_work_lb:mx.controls.Label;
	private var results_ta:mx.controls.TextArea;
	private var ipAddress_ti:TextInput;
	private var serverPort_ti:TextInput;
	private var monitorPort_ti:TextInput;	
	private var connect_btn:Button;
	private var disconnect_btn:Button;	
	private var serverConnection:Object;
	public function ServerControls() {
	}
	public function onLoad():Void {
		start_btn.addEventListener("click", Delegate.create(this, startServer));
		stop_btn.addEventListener("click", Delegate.create(this, stopServer));
		restart_btn.addEventListener("click", Delegate.create(this, restartServer));
		clear_btn.addEventListener("click", Delegate.create(this, clearResults));
		client_restart_btn.addEventListener("click", Delegate.create(this, restartClient));
	}
	private function startServer():Void {
		serverConnection.sendToMonitor(new XML('<ADMIN COMMAND="START" />\n'));
	}
	private function stopServer():Void {
		serverConnection.sendToMonitor(new XML('<ADMIN COMMAND="STOP" />\n'));
	}
	private function restartServer():Void {
		serverConnection.sendToMonitor(new XML('<ADMIN COMMAND="RESTART" />\n'));		
	}
	private function restartClient():Void {
		serverConnection.sendToMonitor(new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n'));		
	}
	public function clearResults():Void {
		results_ta.text = "";
	}
	public function appendControlResults(inNode:XMLNode):Void {
		for (var child in inNode.childNodes) {
			results_ta.text += inNode.childNodes[child];
		}
	}
	public function processXML(inNode:XMLNode):Void {
		while (inNode != null) {
			/*if valid node, ignoreWhite isnt working properly*/
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "EXEC" :
					for (var child in inNode.childNodes) {
						if((inNode.childNodes[child].nodeName == "EXEC_ERROR")||(inNode.childNodes[child].nodeName == "EXEC_OUTPUT")){
							appendControlResults(inNode.childNodes[child]);
						}
					}
					break;
				case "ADMIN" :
					appendControlResults(inNode);
					break;
				}
			}
			inNode = inNode.nextSibling;
		}
	}
}
/**

		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		monitorPort_ti.restrict = "0-9";
		monitorPort_ti.maxChars = 5;
		serverPort_ti.restrict = "0-9";
		serverPort_ti.maxChars = 5;		
		if (_global.project.ipAddress.length) {
			ipAddress_ti.text = _global.project.ipAddress;
		}
		else{
			_global.project.ipAddress = ipAddress_ti.text;
		}
		if (_global.project.serverPort.length) {
			serverPort_ti.text = _global.project.serverPort;
		}
		else{
			_global.project.serverPort = serverPort_ti.text;
		}
		if (_global.project.monitorPort.length) {
			monitorPort_ti.text = _global.project.monitorPort;
		}
		else{
			_global.project.monitorPort = monitorPort_ti.text;
		}
		connect_btn.addEventListener("click", Delegate.create(this, connect));
		disconnect_btn.addEventListener("click", Delegate.create(this, disconnect));
		
		
		
		
		
		
		import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.IR extends Forms.Control.AdminView {
	public var server_socket:XMLSocket;
	public var monitor_socket:XMLSocket;
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
	public function init():Void {
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
		server_socket.send(xmlMsg);
	}
	public function setSockets(inServer_socket:XMLSocket, inMonitor_socket:XMLSocket):Void {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	public function deviceChange(eventObj):Void {
		var xmlMsg = new XML('<LIST_IR_ACTIONS DEVICE="'+device_cb.selectedItem.label+'" />\n');
		server_socket.send(xmlMsg);
		learn_btn.enabled = false;
	}
	public function actionChange(eventObj):Void {
		learn_btn.enabled = true;
	}
	private function learn():Void {
		var irName:String = device_cb.selectedItem.label+"."+action_cb.selectedItem.label;
		var xmlMsg = new XML('<IR_LEARN NAME="'+irName+'" />\n');
		server_socket.send(xmlMsg);
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
		server_socket.send(xmlMsg);
	}
	private function reload():Void {
		action_cb.removeAll();
		var xmlMsg = new XML('<RELOAD_IRDB />\n');
		server_socket.send(xmlMsg);
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

*/