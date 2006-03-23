import mx.utils.Delegate;
class Objects.ClientConnection {
	private var monitor_socket:XMLSocket;
	private var viewAttached:Boolean;
	private var monitorStatus:String;
	private var view:Object;
	private var levels:Array;
	private var __clientName:String;
	public function get clientName():String {
		return __clientName;
	}
	public function set clientName(newName:String) {
		__clientName = newName;
	}
	private var __ipAddress:String;
	[Inspectable(defaultValue="172.16.3.101")]
	 public function get ipAddress():String {
		return __ipAddress;
	}
	public function set ipAddress(newAddress:String) {
		__ipAddress = newAddress;
	}
	private var __monitorPort:Number;
	[Inspectable(defaultValue=10002)]
	 public function get monitorPort():Number {
		return __monitorPort;
	}
	public function set monitorPort(newPort:Number) {
		__monitorPort = newPort;
	}
	public function ClientConnection() {
		monitor_socket = new XMLSocket();
		viewAttached = false;
		setupSockets();
	}
	public function disconnectMonitor() {
		monitor_socket.close();
	}	
	private function connectToMonitor() {
		monitor_socket.connect(ipAddress, monitorPort);
	}
	public function getName():String {
		return clientName;
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
	public function getMonitorStatus():String {
		return monitorStatus;
	}
	private function setupSockets():Void {
		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
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
}
