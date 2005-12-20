import mx.utils.Delegate;
class Objects.ServerObj {
	private var monitor_socket:XMLSocket;
	private var server_socket:XMLSocket;
	private var serverName:String;
	private var ipAddress:String;
	private var monitorPort:Number;
	private var serverPort:Number;
	private var viewAttached:Boolean;
	private var serverStatus:String;
	private var monitorStatus:String;
	private var view:Forms.Control.AdminView;
	
	public function ServerObj(inServerName:String, inIPAddress:String, inMonitorPort:Number, inServerPort:Number) {
		serverName = inServerName;
		ipAddress = inIPAddress;
		monitorPort = inMonitorPort;
		serverPort = inServerPort;
		monitor_socket = new XMLSocket();
		server_socket = new XMLSocket();
		viewAttached = false;
		setupSockets();
	}
	public function  makeConnections(){
		connectToServer();
		connectToMonitor();
	}
	private function connectToServer() {
		server_socket.connect(ipAddress, serverPort);
	}
	private function connectToMonitor() {
		monitor_socket.connect(ipAddress, monitorPort);
	}
	public function getName():String {
		return serverName;
	}
	public function sendToServer(inXML:XML) {
		server_socket.send(inXML);
	}
	public function sendToMonitor(inXML:XML) {
		monitor_socket.send(inXML);
	}
	public function attachView(inView:Forms.Control.AdminView){
		view =inView;
		viewAttached = true;
		view.setSockets(server_socket, monitor_socket);
	}
	public function dettachView():Void {
		view =null;
		viewAttached = false;
	}
	public function getServerStatus():String{
		return serverStatus;
	}
	public function getMonitorStatus():String{
		return monitorStatus;
	}
	private function serverOnConnect(success:Boolean) {
		if (success) {
			serverStatus = "Server: Connected";
		} else {
			serverStatus ="Server: Connection Failed, retrying..."
			connectToServer();
		}
	}
	private function serverOnClose() {
		serverStatus = "Server: Disconnected, retrying...";
		connectToServer();
	}
	private function monitorOnConnect(success:Boolean) {
		if (success) {
			monitorStatus = "Monitor: Connected";
		} else {
			monitorStatus ="Monitor: Connection Failed, retrying..."
			connectToMonitor();
		}
	}
	private function monitorOnClose() {
		monitorStatus = "Monitor: Disconnected, retrying...";
		connectToMonitor();
	}
	private function setupSockets():Void {
		server_socket.onClose = Delegate.create(this, serverOnClose);
		server_socket.onXML = Delegate.create(this, serverOnXML);
		server_socket.onConnect = Delegate.create(this, serverOnConnect);
		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
	}
	private function serverOnXML(inXML:XML) {
		view.processXML(inXML.firstChild);
	}
	private function monitorOnXML(inXML:XML) {
		view.processXML(inXML.firstChild);
	}
}
