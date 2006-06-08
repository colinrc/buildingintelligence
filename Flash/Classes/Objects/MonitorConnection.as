import mx.utils.Delegate;
class Objects.MonitorConnection {
	private var monitor_socket:XMLSocket;
	private var monitorStatus:Boolean;
	private var view:Object;
	private var output:String;
	private var ipAddress:String;
	public function MonitorConnection() {
		monitor_socket = new XMLSocket();
		view = undefined;
		output = "";
		monitorStatus = false;
		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
	}
	public function disconnect() {
		if(monitorStatus){
			monitor_socket.close();
			monitorStatus = false;		
			appendOutput("Disconnected Successfully");
		} else{
			appendOutput("Error: No Connection Present");			
		}
	}	
	private function connect(inIpAddress:String, port:Number) {
		ipAddress = inIpAddress;
		monitor_socket.connect(ipAddress, port);
	}
	public function sendToMonitor(inXML:XML) {
		monitor_socket.send(inXML);
	}
	public function attachView(inView:Object) {
		view = inView;
		if (view != undefined) {
			view.notifyChange();
		}	
	}
	public function detachView():Void {
		view = undefined;
	}
	public function getStatus():Boolean {
		return monitorStatus;
	}
	private function getOutput():String{
		return output;
	}
	private function monitorOnConnect(success:Boolean) {
		if (success) {
			monitorStatus = true;
			appendOutput("Monitor: Connected at "+ipAddress);
		} else {
			monitorStatus = false;
			appendOutput("Monitor: Connection Failed at "+ipAddress);
		}
	}
	private function monitorOnClose() {
		monitorStatus = false;
		appendOutput("Monitor: Disconnected at "+ipAddress);
	}
	public function appendOutput(inString:String):Void {
		output = inString + "\n"+output;
		if (view != undefined) {
			view.notifyChange();
		}
	}	
	private function startServer():Void {
		if(monitorStatus){
			sendToMonitor(new XML('<ADMIN COMMAND="START" />\n'));
		} else {
			appendOutput("Error: No Connection Present");
		}
	}
	private function stopServer():Void {
		if(monitorStatus){
			sendToMonitor(new XML('<ADMIN COMMAND="STOP" />\n'));
		} else {
			appendOutput("Error: No Connection Present");
		}
	}
	private function restartServer():Void {
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="RESTART" />\n'));		
		} else {
			appendOutput("Error: No Connection Present");
		}		
	}
	private function restartClient():Void {
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n'));
		} else {
			appendOutput("Error: No Connection Present");
		}		
	}
	private function commit():Void{
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="ewfmgr c: -commit" />\n'));
			mdm.Dialogs.prompt(mdm.System.localTime);
			appendOutput("New settings commited. Please shutdown and restart");
			sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="time 12" />\n'));
			mdm.Dialogs.prompt(mdm.System.localTime);
			appendOutput("Time updated. Commit and shutdown required");
		} else {
			appendOutput("Error: No Connection Present");
		}		
	}
	
	
	public function setTime():Void{
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="time 12" />\n'));
			mdm.Dialogs.prompt(mdm.System.localTime);
			appendOutput("Time updated. Commit and shutdown required");
		} else {
			appendOutput("Error: No Connection Present");
		}
	}
	private function shutdown():Void{
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="shutdown -r -t 00" />\n'));
			appendOutput("Shutting down... please wait for restart");
		} else {
			appendOutput("Error: No Connection Present");
		}		
	}
	private function arbitraryCommand(inCommand:String){
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="'+inCommand+'" />\n'));
		} else {
			appendOutput("Error: No Connection Present");
		}		
	}
	private function select(fileName:String){
		if(monitorStatus){		
			sendToMonitor(new XML('<ADMIN COMMAND="SELECT" EXTRA="'+fileName+'" />\n'));
		} else {
			appendOutput("Error: No Connection Present");
		}		
	}
	private function monitorOnXML(inXML:XML) {
		var inNode = inXML.firstChild;
		while (inNode != null) {
			//if valid node, ignoreWhite isnt working properly
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "EXEC" :
					for (var child in inNode.childNodes) {
						if((inNode.childNodes[child].nodeName == "EXEC_ERROR")||(inNode.childNodes[child].nodeName == "EXEC_OUTPUT")){
							var tempNode = inNode.childNodes[child];
						 	for(var child in tempNode.childNodes) {
								appendOutput(tempNode.childNodes[child].toString());
							}					
						}
					}
					break;
				case "ADMIN" :
				 	for(var child in inNode.childNodes) {
						appendOutput(inNode.childNodes[child].toString());
					}
					break;
				}
			}
			inNode = inNode.nextSibling;
		}		
	}
}
