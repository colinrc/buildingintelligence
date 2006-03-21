import mx.utils.Delegate;
class Objects.ServerConnection {
	private var monitor_socket:XMLSocket;
	private var server_socket:XMLSocket;
	private var viewAttached:Boolean;
	private var serverStatus:String;
	private var monitorStatus:String;
	private var view:Object;
	private var levels:Array;
	private var __serverName:String;
	public function get serverName():String {
		return __serverName;
	}
	public function set serverName(newName:String) {
		__serverName = newName;
	}
	private var __ipAddress:String;
	[Inspectable(defaultValue="172.16.3.101")]
	 public function get ipAddress():String {
		return __ipAddress;
	}
	public function set ipAddress(newAddress:String) {
		__ipAddress = newAddress;
	}
	private var __serverPort:Number;
	[Inspectable(defaultValue=10001)]
	 public function get serverPort():Number {
		return __serverPort;
	}
	public function set serverPort(newPort:Number) {
		__serverPort = newPort;
	}
	private var __monitorPort:Number;
	[Inspectable(defaultValue=10002)]
	 public function get monitorPort():Number {
		return __monitorPort;
	}
	public function set monitorPort(newPort:Number) {
		__monitorPort = newPort;
	}
	public function ServerConnection() {
		monitor_socket = new XMLSocket();
		server_socket = new XMLSocket();
		viewAttached = false;
		setupSockets();
	}
	public function getLevels():Array{
		return levels;
	}
	public function disconnectServer() {
		setDefault();
		server_socket.close();
	}
	public function disconnectMonitor() {
		monitor_socket.close();
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
	public function attachView(inView:Object) {
		view = inView;
		viewAttached = true;
	}
	public function dettachView():Void {
		view = null;
		viewAttached = false;
	}
	public function getServerStatus():String {
		return serverStatus;
	}
	public function getMonitorStatus():String {
		return monitorStatus;
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
		/*******************************************************/
		/*view.processXML(inXML.firstChild);
				while (inNode != null) {
			//if valid node, ignoreWhite isnt working properly
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "ERROR" :
					appendDebugText(inNode);
					break;
				case "LOG" :
					appendDebugText(inNode);
					break;
				case "DEBUG_PACKAGES" :
					generateDebugLevels(inNode);
					break;					
				}
			}
			inNode = inNode.nextSibling;
		}*/
	}
	private function monitorOnXML(inXML:XML) {
		/*******************************************************/		
		/*view.processXML(inXML.firstChild);
				while (inNode != null) {
			//if valid node, ignoreWhite isnt working properly
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "ERROR" :
					appendDebugText(inNode);
					break;
				case "LOG" :
					appendDebugText(inNode);
					break;
				case "DEBUG_PACKAGES" :
					generateDebugLevels(inNode);
					break;					
				}
			}
			inNode = inNode.nextSibling;
		}*/
	}
	private function serverOnConnect(success:Boolean) {
		if (success) {
			serverStatus = "Server: Connected";
			mdm.Dialogs.prompt(serverStatus+" at "+ipAddress+", port "+serverPort+".");
			levels = new Array();
			getDebugLevels();
		} else {
			serverStatus = "Server: Connection Failed";
			mdm.Dialogs.prompt(serverStatus+" at "+ipAddress+", port "+serverPort+".");		
			levels = new Array();			
		}
	}
	private function serverOnClose() {
		serverStatus = "Server: Disconnected";
		mdm.Dialogs.prompt(serverStatus+" at "+ipAddress+", port "+serverPort+".");		
		levels = new Array();		
	}
	private function monitorOnConnect(success:Boolean) {
		if (success) {
			monitorStatus = "Monitor: Connected";
			mdm.Dialogs.prompt(monitorStatus+" at "+ipAddress+", port "+monitorPort+".");
		} else {
			monitorStatus = "Monitor: Connection Failed";
			mdm.Dialogs.prompt(monitorStatus+" at "+ipAddress+", port "+monitorPort+".");
		}
	}
	private function monitorOnClose() {
		monitorStatus = "Monitor: Disconnected";
			mdm.Dialogs.prompt(monitorStatus+" at "+ipAddress+", port "+monitorPort+".");
	}
	public function setDefault() {
		for (var index:Number = 0; index<levels.length; index++) {
			changeDebugLevels("INFO", levels[index].packagename);
		}
	}
	private function changeDebugLevels(logLevel:String, package:String):Void {
		sendToServer(new XML('<DEBUG PACKAGE="'+package+'" LEVEL="'+logLevel+'" />\n'));
		for(var level in levels){
			if(package == levels[level].packagename){
				levels[level].level = logLevel;
				break;
			}
		}
	}
	public function generateDebugPackages(inLevels:XMLNode):Void {
		var inNode:XMLNode = inLevels.firstChild;
		while (inNode != null) {
			levels.addItem({shortname:inNode.attributes["SHORTNAME"], packagename:inNode.attributes["PACKAGENAME"], level:inNode.attributes["LEVEL"]});
			inNode = inNode.nextSibling;
		}
	}
	private function getDebugLevels():Void {
		sendToServer(new XML('<DEBUG_PACKAGES />\n'));
	}	
}
