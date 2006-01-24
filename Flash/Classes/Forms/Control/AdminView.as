class Forms.Control.AdminView extends Forms.BaseForm {
	private var server_socket:XMLSocket;
	private var monitor_socket:XMLSocket;
	public function init():Void{
	}
	public function setSockets(inServer_socket:XMLSocket, inMonitor_socket:XMLSocket):Void {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	public function processXML(inNode:XMLNode):Void{
	}
}