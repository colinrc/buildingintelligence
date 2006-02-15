import mx.utils.Delegate;
class Objects.ServerConnection {
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
	
	public function ServerConnection() {
		//_root.debugger.text +="Server Object Exists \n";
		monitor_socket = new XMLSocket();
		server_socket = new XMLSocket();
		viewAttached = false;		
		setupSockets();	
	}
	public function disconnect(){
		monitor_socket.close();
		server_socket.close();
	}
	public function  makeConnections(inServerName:String, inIPAddress:String, inServerPort:Number, inMonitorPort:Number){
		serverName = inServerName;
		ipAddress = inIPAddress;
		monitorPort = inMonitorPort;
		serverPort = inServerPort;
		//_root.debugger.text +="Getting Server Details: \n";		
		//_root.debugger.text +="IP: "+ ipAddress+"\n";		
		//_root.debugger.text +="Monitor Port: "+monitorPort+"\n";		
		//_root.debugger.text +="Getting Server Details: "+serverPort+"\n";				
		connectToServer();
		connectToMonitor();
	}
	private function connectToServer() {
		//_root.debugger.text +="Attempting connection to server... \n";		
		server_socket.connect(ipAddress, serverPort);
	}
	private function connectToMonitor() {
		//_root.debugger.text +="Attempting connection to monitor... \n";
		monitor_socket.connect(ipAddress, monitorPort);
	}
	public function getName():String {
		return serverName;
	}
	public function sendToServer(inXML:XML) {
		//_root.debugger.text +="Attempting send to server... \n";		
		server_socket.send(inXML);
	}
	public function sendToMonitor(inXML:XML) {
		//_root.debugger.text +="Attempting send to monitor... \n";
		monitor_socket.send(inXML);
	}
	public function attachView(inView:Forms.Control.AdminView){
		//_root.debugger.text +="Got a view "+inView+"\n";
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
			//_root.debugger.text +=serverStatus+"\n";
		} else {
			serverStatus ="Server: Connection Failed"
			//_root.debugger.text +=serverStatus+"\n";			
		}
	}
	private function serverOnClose() {
		serverStatus = "Server: Disconnected";
		//_root.debugger.text +=serverStatus+"\n";		
	}
	private function monitorOnConnect(success:Boolean) {
		if (success) {
			monitorStatus = "Monitor: Connected";
			//_root.debugger.text +=monitorStatus+"\n";			
		} else {
			monitorStatus ="Monitor: Connection Failed"
			//_root.debugger.text +=monitorStatus+"\n";						
		}
	}
	private function monitorOnClose() {
		monitorStatus = "Monitor: Disconnected";
		//_root.debugger.text +=monitorStatus+"\n";					
	}
	private function setupSockets():Void {
		server_socket.onClose = Delegate.create(this, serverOnClose);
		server_socket.onXML = Delegate.create(this, serverOnXML);
		server_socket.onData = Delegate.create(this, serverOnData);
		server_socket.onConnect = Delegate.create(this, serverOnConnect);
		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
		monitor_socket.onData = Delegate.create(this, monitorOnData);
		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
	}
	private function serverOnXML(inXML:XML) {
		//_root.debugger.text +=inXML.toString()+"\n";
		view.processXML(inXML.firstChild);
	}
	private function monitorOnXML(inXML:XML) {
		//_root.debugger.text +=inXML.toString()+"\n";
		view.processXML(inXML.firstChild);
	}
	private function serverOnData(str:String) {
		//_root.debugger.text +=str+"\n";		
		server_socket.onXML(new XML(str));
	}
	private function monitorOnData(str:String) {
		//_root.debugger.text +=str+"\n";		
		monitor_socket.onXML(new XML(str));
	}
}
