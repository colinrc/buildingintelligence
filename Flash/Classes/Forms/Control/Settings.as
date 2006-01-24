import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.Settings extends Forms.BaseForm {
	private var serverName_lb:mx.controls.Label;
	private var serverName_ti:mx.controls.TextInput;
	private var ipAddress_lb:mx.controls.Label;
	private var ipAddress_ti:mx.controls.TextInput;
	private var monitorPort_lb:mx.controls.Label;
	private var monitorPort_ti:mx.controls.TextInput;
	private var serverPort_lb:mx.controls.Label;
	private var serverPort_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	public function Settings() {
	}
	public function init():Void {
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		monitorPort_ti.restrict = "0-9";
		monitorPort_ti.maxChars = 5;
		serverPort_ti.restrict = "0-9";
		serverPort_ti.maxChars = 5;
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function save():Void {
		//setServerStatus("Server: Attempting Connection");
		//setMonitorStatus("Monitor: Attempting Connection");
		//server_socket.connect(ipAddress_ti.text, parseInt(serverPort_ti.text));
		//monitor_socket.connect(ipAddress_ti.text, parseInt(monitorPort_ti.text));
		//connect_btn.enabled = false;
		//disconnect_btn.enabled = true;
		//tabbar.enabled = true;		
		//control_ver_work_lb.text = "eLife V1.1.5, Working Directory: "+settings_working_in.text;
		//getDebugLevels();
	}
}
