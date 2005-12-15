import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.Controls {
	private var start_btn:mx.controls.Button;
	private var stop_btn:mx.controls.Button;
	private var restart_btn:mx.controls.Button;
	private var clear_btn:mx.controls.Button;
	private var client_restart_btn:mx.controls.Button;
	private var ver_work_lb:mx.controls.Label;
	private var results_ta:mx.controls.TextArea;
	private var monitor_socket:XMLSocket;
	private var server_socket:XMLSocket;
	function Controls() {
	}
	public function init():Void {
		start_btn.addEventListener("click", Delegate.create(this, startServer));
		stop_btn.addEventListener("click", Delegate.create(this, stopServer));
		restart_btn.addEventListener("click", Delegate.create(this, restartServer));
		clear_btn.addEventListener("click", Delegate.create(this, clearResults));
		client_restart_btn.addEventListener("click", Delegate.create(this, restartClient));
	}
	public function setSockets(inMonitor_socket:XMLSocket, inServer_socket:XMLSocket) {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	public function setVisible(showing:Boolean):Void {
		start_btn._visible = showing;
		stop_btn._visible = showing;
		restart_btn._visible = showing;
		client_restart_btn._visible = showing;
		clear_btn._visible = showing;
		ver_work_lb._visible = showing;
		results_ta._visible = showing;
	}
	function startServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="START" />\n');
		monitor_socket.send(xmlMsg);
	}
	function stopServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="STOP" />\n');
		monitor_socket.send(xmlMsg);
	}
	function restartServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="RESTART" />\n');
		monitor_socket.send(xmlMsg);
	}
	function restartClient():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n');
		monitor_socket.send(xmlMsg);
	}
	function clearResults():Void {
		results_ta.text = "";
	}
	function appendControlResults(inString:String) {
		if (inString != "") {
			results_ta.text += inString;
		}
	}
}
