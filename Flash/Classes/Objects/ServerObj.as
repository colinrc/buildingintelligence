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
	private var view:Forms.Control.ServerView;
	
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
	public function attachView(inView:Forms.Control.ServerView){
		view =inView;
		viewAttached = true;
		view.setServer(this);
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
			if(viewAttached){
				view.setServerStatus(serverStatus);
			}
		} else {
			serverStatus ="Server: Connection Failed, retrying..."
			if(viewAttached){
				view.setServerStatus(serverStatus);
			}
			connectToServer();
		}
	}
	private function serverOnClose() {
		serverStatus = "Server: Disconnected, retrying...";
		if(viewAttached){
			view.setServerStatus(serverStatus);
		}
		connectToServer();
	}
	private function monitorOnConnect(success:Boolean) {
		if (success) {
			monitorStatus = "Monitor: Connected";
			if(viewAttached){
				view.setMonitorStatus(monitorStatus);
			}
		} else {
			monitorStatus ="Monitor: Connection Failed, retrying..."
			if(viewAttached){
				view.setMonitorStatus(monitorStatus);
			}
			connectToMonitor();
		}
	}
	private function monitorOnClose() {
		monitorStatus = "Monitor: Disconnected, retrying...";
		if(viewAttached){
			view.setMonitorStatus(monitorStatus);
		}
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
		processServerNode(inXML.firstChild);
	}
	private function processServerNode(inNode) {
		if (viewAttached) {
			while (inNode != null) {
				/*if valid node, ignoreWhite isnt working properly*/
				if (inNode.nodeName != null) {
					switch (inNode.nodeName) {
					case "ERROR" :
						//view.serverLogPanel.appendDebugText(inNode);
						trace(inNode);
						break;
					case "LOG" :
						view.serverLogPanel.appendDebugText(inNode);
						break;
					case "DEBUG_PACKAGES" :
						view.logLevelsPanel.generateDebugLevels(inNode);
						break;
					case "IR_DEVICE_LIST" :
						view.irPanel.deviceList(inNode);
						break;
					case "IR_ACTION_LIST" :
						view.irPanel.actionList(inNode);
						break;
					case "IR_CONFIG" :
						view.irPanel.irResult(inNode);
						break;
					case "IR_LEARNT" :
						view.irPanel.irLearnt(inNode);
						break;
					case "connected" :
						//lanuched (time), config, logDir
						break;
					case "Admin_Clients" :
						//count
						break;
					case "heartbeat" :
						break;
					default :
						trace(inNode);
					}
				}
				inNode = inNode.nextSibling;
			}
		}
	}
	private function monitorOnXML(inXML:XML) {
		processMonitorNode(inXML.firstChild);
	}
	private function processMonitorNode(inNode) {
		if (viewAttached) {
			while (inNode != null) {
				/*if valid node, ignoreWhite isnt working properly*/
				if (inNode.nodeName != null) {
					switch (inNode.nodeName) {
					case "ERROR" :
						//view.serverLogPanel.appendDebugText(inNode);
						trace(inNode);
						break;
					case "FILE_TRANSFER" :
						//trace(inNode);
						//do download here
						break;
					case "FILE" :
						//filesPanel.fileDownloaded(inNode);
						break;
					case "EXEC" :
						if (inNode.hasChildNodes) {
							for (var child in inNode.childNodes) {
								view.controlPanel.appendControlResults(inNode.childNodes[child]);
							}
						}
						break;
					case "FILES" :
						view.filesPanel.filesList(inNode);
						break;
					case "DELETE" :
						view.filesPanel.fileDeleted(inNode);
						break;
					case "UPLOAD" :
						view.filesPanel.fileUploaded(inNode);
						break;
					case "STARTUP_FILE" :
						/*startupFile = inNode.attributes["NAME"];*/
						break;
					case "ADMIN" :
						view.controlPanel.appendControlResults(inNode);
						break;
					case "HEARTBEAT" :
						break;
					case "SELECT" :
						view.filesPanel.fileSelected(inNode);
						break;
					default :
						trace(inNode);
						break;
					}
				}
				inNode = inNode.nextSibling;
			}
		}
	}
}
