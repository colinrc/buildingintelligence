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
	private var server:Objects.ServerObj;
	public function Controls() {
	}
	public function init():Void {
		start_btn.addEventListener("click", Delegate.create(this, startServer));
		stop_btn.addEventListener("click", Delegate.create(this, stopServer));
		restart_btn.addEventListener("click", Delegate.create(this, restartServer));
		clear_btn.addEventListener("click", Delegate.create(this, clearResults));
		client_restart_btn.addEventListener("click", Delegate.create(this, restartClient));
	}
	public function setSockets(inServer:Objects.ServerObj) {
		server = inServer;
		trace(server.getName());
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
	private function startServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="START" />\n');
		server.sendToMonitor(xmlMsg);
	}
	private function stopServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="STOP" />\n');
		server.sendToMonitor(xmlMsg);
	}
	private function restartServer():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="RESTART" />\n');
		server.sendToMonitor(xmlMsg);
	}
	private function restartClient():Void {
		var xmlMsg = new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n');
		server.sendToMonitor(xmlMsg);
	}
	public function clearResults():Void {
		results_ta.text = "";
	}
	public function appendControlResults(inXML:XMLNode) {
		results_ta.text += inXML.toString();
	}
}
