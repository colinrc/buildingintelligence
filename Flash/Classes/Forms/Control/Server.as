import mx.controls.*

class Forms.Control.Server {
	private var ipAddress_ti:mx.controls.TextInput;
	private var port_ti:mx.controls.TextInput;
	private var start_btn:mx.controls.Button;
	private var stop_btn:mx.controls.Button;
	
	function Server() {
	}
	
	public function init():Void {
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		port_ti.restrict = "0-9";
		port_ti.maxChars = 5;
	}
}