import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.Server {
	private var monitor_socket:XMLSocket;
	private var server_socket:XMLSocket;
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
	private var serverStatus_lb:mx.controls.Label;
	private var monitorStatus_lb:mx.controls.Label;
	private var buttonListener = new Object();
	function Server() {
	}
	public function init():Void {
		monitor_socket = new XMLSocket();
		server_socket = new XMLSocket();
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		monitorPort_ti.restrict = "0-9";
		monitorPort_ti.maxChars = 5;
		serverPort_ti.restrict = "0-9";
		serverPort_ti.maxChars = 5;
		disconnect_btn.enabled = false;
		buttonListener.last_btn = null;
		buttonListener.click = function(eventObj) {
			this.last_btn.selected = false;
			eventObj.target.selected = true;
			this.last_btn = eventObj.target;
			switch (eventObj.target) {
			case connect_btn :
				attemptConnection();
				break;
			case disconnect_btn :
				disconnect();
				break;
			case set_btn :
				setWorkingDir();
				break;
			case save_btn :
				save();
				break;
			}
		};
		connect_btn.addEventListener("click", Delegate.create(this, attemptConnection));
		disconnect_btn.addEventListener("click", Delegate.create(this, disconnect));
		save_btn.addEventListener("click", Delegate.create(this, save));
		set_btn.addEventListener("click", Delegate.create(this, setWorkingDir));
		setupSockets();
	}
	function attemptConnection():Void {
		setServerStatus("Server: Attempting Connection");
		setMonitorStatus("Monitor: Attempting Connection");
		server_socket.connect(ipAddress_ti.text, parseInt(serverPort_ti.text));
		monitor_socket.connect(ipAddress_ti.text, parseInt(monitorPort_ti.text));
		//tabbar.enabled = true;
		connect_btn.enabled = false;
		disconnect_btn.enabled = true;
		//control_ver_work_lb.text = "eLife V1.1.5, Working Directory: "+settings_working_in.text;
		//getDebugLevels();
	}
	function disconnect():Void {
		setServerStatus("Server: Disconnected");
		setMonitorStatus("Monitor: Disconnected");
		server_socket.close();
		monitor_socket.close();
		connect_btn.enabled = true;
		disconnect_btn.enabled = false;
	}
	function save():Void {
	}
	function setWorkingDir():Void {
	}
	function setupSockets():Void {
		server_socket.onClose = Delegate.create(this, serverOnClose);
		server_socket.onXML = Delegate.create(this, serverOnXML);
		server_socket.onConnect = Delegate.create(this, serverOnConnect);
		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
	}
	function serverOnConnect(success:Boolean) {
		if (success) {
			setServerStatus("Server: Connected");
		} else {
			server_socket.close();
			setServerStatus("Server: Connection Failed, retrying");
			server_socket.connect(ipAddress_ti.text, parseInt(serverPort_ti.text));
		}
	}
	function serverOnXML(inXML:XML) {
		//trace(inXML);	
	}
	function serverOnClose() {
		server_socket.connect(ipAddress_ti.text, parseInt(serverPort_ti.text));
		setServerStatus("Server: Disconnected, retrying");
	}
	function monitorOnConnect(success:Boolean) {
		if (success) {
			setMonitorStatus("Monitor: Connected");
		} else {
			monitor_socket.close();
			setMonitorStatus("Monitor: Connection Failed, retrying");
			monitor_socket.connect(ipAddress_ti.text, parseInt(monitorPort_ti.text));
		}
	}
	function monitorOnXML(inXML:XML) {
		//trace(inXML);	
	}
	function monitorOnClose() {
		monitor_socket.connect(ipAddress_ti.text, parseInt(monitorPort_ti.text));
		setMonitorStatus("Monitor: Disconnected, retrying");
	}
	function setServerStatus(newText:String):Void {
		serverStatus_lb.text = newText;
	}
	function setMonitorStatus(newText:String):Void {
		monitorStatus_lb.text = newText;
	}
	function setVisible(showing:Boolean):Void {
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
		serverStatus_lb._visible = showing;
		monitorStatus_lb._visible = showing;
	}
}
