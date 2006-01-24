import mx.controls.*;
import mx.utils.Delegate;

class Forms.Control.Controls extends Forms.Control.AdminView {
	private var start_btn:mx.controls.Button;
	private var stop_btn:mx.controls.Button;
	private var restart_btn:mx.controls.Button;
	private var clear_btn:mx.controls.Button;
	private var client_restart_btn:mx.controls.Button;
	private var ver_work_lb:mx.controls.Label;
	private var results_ta:mx.controls.TextArea;
	public var server_socket:XMLSocket;
	public var monitor_socket:XMLSocket;
	public function Controls() {
	}
	public function init():Void {
		start_btn.addEventListener("click", Delegate.create(this, startServer));
		stop_btn.addEventListener("click", Delegate.create(this, stopServer));
		restart_btn.addEventListener("click", Delegate.create(this, restartServer));
		clear_btn.addEventListener("click", Delegate.create(this, clearResults));
		client_restart_btn.addEventListener("click", Delegate.create(this, restartClient));
	}
	public function setSockets(inServer_socket:XMLSocket, inMonitor_socket:XMLSocket):Void {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	private function startServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="START" />\n');
		monitor_socket.send(xmlMsg);
	}
	private function stopServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="STOP" />\n');
		monitor_socket.send(xmlMsg);
	}
	private function restartServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="RESTART" />\n');
		monitor_socket.send(xmlMsg);
	}
	private function restartClient():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n');
		monitor_socket.send(xmlMsg);
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
