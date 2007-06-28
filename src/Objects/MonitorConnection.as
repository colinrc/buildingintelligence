﻿package Objects {
	//import mx.utils.Delegate;
	import flash.xml.XMLNode;
	import flash.net.XMLSocket;
	public class MonitorConnection {
		private var monitor_socket:XMLSocket;
		private var monitorStatus:Boolean;
		private var view:Object;
		private var output:String;
		private var ipAddress:String;
		public function MonitorConnection():void {
			monitor_socket = new XMLSocket();
			view = undefined;
			output = "";
			monitorStatus = false;
	//		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
	//		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
	//		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
		}
		public function disconnect():void {
			if(monitorStatus){
				monitor_socket.close();
				monitorStatus = false;		
				appendOutput("Disconnected Successfully");
			} else{
				appendOutput("Error: No Connection Present");			
			}
		}	
		private function connect(inIpAddress:String, port:Number):void {
			ipAddress = inIpAddress;
			monitor_socket.connect(ipAddress, port);
		}
		public function sendToMonitor(inXML:XML):void {
			monitor_socket.send(inXML);
		}
		public function attachView(inView:Object):void {
			view = inView;
			if (view != null) {
				view.notifyChange();
			}	
		}
		public function detachView():void {
			view = undefined;
		}
		public function getStatus():Boolean {
			return monitorStatus;
		}
		private function getOutput():String{
			return output;
		}
		private function monitorOnConnect(success:Boolean):void {
			if (success) {
				monitorStatus = true;
				appendOutput("Monitor: Connected at "+ipAddress);
			} else {
				monitorStatus = false;
				appendOutput("Monitor: Connection Failed at "+ipAddress);
			}
		}
		private function monitorOnClose():void {
			monitorStatus = false;
			appendOutput("Monitor: Disconnected at "+ipAddress);
		}
		public function appendOutput(inString:String):void {
			output = inString + "\n"+output;
			if (view != null) {
				view.notifyChange();
			}
		}	
		private function startServer():void {
			if(monitorStatus){
				sendToMonitor(new XML('<ADMIN COMMAND="START" />\n'));
			} else {
				appendOutput("Error: No Connection Present");
			}
		}
		private function stopServer():void {
			if(monitorStatus){
				sendToMonitor(new XML('<ADMIN COMMAND="STOP" />\n'));
			} else {
				appendOutput("Error: No Connection Present");
			}
		}
		private function restartServer():void {
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="RESTART" />\n'));		
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		private function restartClient():void {
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n'));
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		private function commit():void{
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="ewfmgr c: -commit" />\n'));
				appendOutput("New settings commited. Please shutdown and restart");
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		
		
		public function setTime():void{
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="runme" />\n'));
				appendOutput("Time updated. Commit and shutdown required1");
			} else {
				appendOutput("Error: No Connection Present");
			}
		}
		private function shutdown():void{
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
}