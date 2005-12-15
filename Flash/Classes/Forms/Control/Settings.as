import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.Settings {
	private var ipAddress_lb:mx.controls.Label;
	private var ipAddress_ti:mx.controls.TextInput;
	private var connect_btn:mx.controls.Button;
	private var monitorPort_lb:mx.controls.Label;
	private var monitorPort_ti:mx.controls.TextInput;
	private var serverPort_lb:mx.controls.Label;
	private var serverPort_ti:mx.controls.TextInput;
	private var workingDir_lb:mx.controls.Label;
	private var workingDir_ti:mx.controls.TextInput;
	private var disconnect_btn:mx.controls.Button;
	private var save_btn:mx.controls.Button;
	private var set_btn:mx.controls.Button;
	private var monitor_socket:XMLSocket;
	private var server_socket:XMLSocket;
	function Controls() {
	}
	public function setSockets(inMonitor_socket:XMLSocket, inServer_socket:XMLSocket) {
		monitor_socket = inMonitor_socket;
		server_socket = inServer_socket;
	}
	public function init():Void {
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		monitorPort_ti.restrict = "0-9";
		monitorPort_ti.maxChars = 5;
		serverPort_ti.restrict = "0-9";
		serverPort_ti.maxChars = 5;
		//disconnect_btn.enabled = false;
		connect_btn.addEventListener("click", Delegate.create(this, attemptConnection));
		disconnect_btn.addEventListener("click", Delegate.create(this, disconnect));
		save_btn.addEventListener("click", Delegate.create(this, save));
		set_btn.addEventListener("click", Delegate.create(this, setWorkingDir));
	}
	public function setVisible(showing:Boolean):Void {
		ipAddress_lb._visible = showing;
		ipAddress_ti._visible = showing;
		connect_btn._visible = showing;
		monitorPort_lb._visible = showing;
		monitorPort_ti._visible = showing;
		serverPort_lb._visible = showing;
		serverPort_ti._visible = showing;
		workingDir_lb._visible = showing;
		workingDir_ti._visible = showing;
		disconnect_btn._visible = showing;
		save_btn._visible = showing;
		set_btn._visible = showing;
	}
	function attemptConnection():Void {
		//setServerStatus("Server: Attempting Connection");
		//setMonitorStatus("Monitor: Attempting Connection");
		server_socket.connect(ipAddress_ti.text, parseInt(serverPort_ti.text));
		monitor_socket.connect(ipAddress_ti.text, parseInt(monitorPort_ti.text));
		//connect_btn.enabled = false;
		//disconnect_btn.enabled = true;
		//tabbar.enabled = true;		
		//control_ver_work_lb.text = "eLife V1.1.5, Working Directory: "+settings_working_in.text;
		//getDebugLevels();
	}
	function disconnect():Void {
		//setServerStatus("Server: Disconnected");
		//setMonitorStatus("Monitor: Disconnected");
		server_socket.close();
		monitor_socket.close();
		//connect_btn.enabled = true;
		//disconnect_btn.enabled = false;
	}
	function save():Void {
	}
	function setWorkingDir():Void {
	}
}
