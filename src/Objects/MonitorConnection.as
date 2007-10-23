﻿package Objects {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	
	import mx.utils.StringUtil;
	public class MonitorConnection {
		public var monitor_socket:XMLSocket;
		public var monitorStatus:Boolean;
		public var view:Object;
		public var output:String;
		public var ipAddress:String;
		public function MonitorConnection():void {
			monitor_socket = new XMLSocket();
			view = undefined;
			output = "";
			monitorStatus = false;
			monitor_socket.addEventListener(Event.CLOSE, monitorOnClose);
			monitor_socket.addEventListener(DataEvent.DATA, monitorOnXML);
			monitor_socket.addEventListener(Event.CONNECT, monitorOnConnect);
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
		public function connect(inIpAddress:String, port:Number):void {
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
		public function getOutput():String{
			return output;
		}
		public function clearOutput():void {
			output="";
		}
		public function monitorOnConnect(success:Boolean):void {
			if (success) {
				monitorStatus = true;
				appendOutput("Monitor: Connected at "+ipAddress);
			} else {
				monitorStatus = false;
				appendOutput("Monitor: Connection Failed at "+ipAddress);
			}
		}
		public function monitorOnClose():void {
			monitorStatus = false;
			appendOutput("Monitor: Disconnected at "+ipAddress);
		}
		public function appendOutput(inString:String):void {
			output = inString + "\n"+output;
			if (view != null) {
				view.notifyChange();
			}
		}	
		public function startServer():void {
			if(monitorStatus){
				sendToMonitor(new XML('<ADMIN COMMAND="START" />\n'));
				appendOutput("Start: sent to Server");	
			} else {
				appendOutput("Error: No Connection Present");
			}
		}
		public function stopServer():void {
			if(monitorStatus){
				sendToMonitor(new XML('<ADMIN COMMAND="STOP" />\n'));
				appendOutput("Stop: sent to Server");	
			} else {
				appendOutput("Error: No Connection Present");
			}
		}
		public function restartServer():void {
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="RESTART" />\n'));
				appendOutput("Restart: sent to Server");		
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		public function restartClient():void {
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n'));
				appendOutput("Restart: sent to Client");	
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		public function commit():void{
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
				appendOutput("Time updated. Commit and shutdown required");
			} else {
				appendOutput("Error: No Connection Present");
			}
		}
		public function shutdown():void{
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="shutdown -r -t 00" />\n'));
				appendOutput("Shutting down... please wait for restart");
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		public function arbitraryCommand(inCommand:String){
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="ARBITRARY" EXTRA="'+inCommand+'" />\n'));
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		public function select(fileName:String){
			if(monitorStatus){		
				sendToMonitor(new XML('<ADMIN COMMAND="SELECT" EXTRA="'+fileName+'" />\n'));
			} else {
				appendOutput("Error: No Connection Present");
			}		
		}
		public function monitorOnXML(inData:DataEvent) {
			var thing:String = inData.data;
			//remove trailing spaces thing.
			var inXML:XML = new XML(thing);
			var node:String = inXML.name();
			for (var child in inXML.children()) {
				//if valid node, ignoreWhite isnt working properly
				var inSubXML:XML = inXML.children()[child];
				var inSubNode:String = inSubXML.name();
				
				switch (inSubNode) {
				case "EXEC" :
					for (var execChild in inSubXML) {
						var sname:String = inSubXML[child].name();
						if((sname == "EXEC_ERROR")||(sname == "EXEC_OUTPUT")){
							for(var child in inSubXML.children()) {
								appendOutput(inSubXML.children()[child].toString());
							}					
						}
					}
					break;
				case "ADMIN" :
				 	for(var execChild in inSubXML) {
						appendOutput(inSubXML.children()[child].toString());
					}
					break;
				}
				
			}		
		}
	}
}