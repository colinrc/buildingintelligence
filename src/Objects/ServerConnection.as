package Objects {
	//import mx.utils.Delegate
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.XMLSocket;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	public class ServerConnection {
		public var server_socket:XMLSocket;
		public var serverStatus:Boolean;
		public var view:ArrayCollection;
		[Bindable]
		public var levels:ArrayCollection;
		public var ipAddress:String;
		public var port:int;
		public var output:String;
		public function ServerConnection():void {
			server_socket = new XMLSocket();
			view = new ArrayCollection();	
			output = "";
			serverStatus = false;
			levels = new ArrayCollection();
			server_socket.addEventListener(Event.CLOSE, serverOnClose);
			server_socket.addEventListener(DataEvent.DATA, serverOnXML);
			server_socket.addEventListener(Event.CONNECT, serverOnConnect);
			server_socket.addEventListener(IOErrorEvent.IO_ERROR, serverIOError);
			server_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ServerSecurityError);
		}
		public function getLevels():ArrayCollection{
			return levels;
		}
		public function disconnect():void {
			if(serverStatus){
				setDefault();
				server_socket.close();
				serverStatus = false;		
				appendOutput("Disconnected Successfully");
			} else{
				appendOutput("Error: No Connection Present");			
			}
		}
		public function connect(inIpAddress:String, inPort:int):void {
			try {
				//IOErrorEvent
				ipAddress = inIpAddress;
				port = inPort;
				server_socket.connect(ipAddress, port);
			}
			catch (io:IOErrorEvent) {
				serverStatus = false;
				appendOutput("Server: Connection Failed at "+ipAddress);
			} catch (any:ErrorEvent) {
				trace ("error");
			}
			
		}
		public function sendToServer(inXML:Object):void {
			server_socket.send(inXML);
			
		}
		public function attachView(inView:Object):void {
			view.addItem(inView);
			if (inView != undefined) {
				for (var i:int=0;i<view.length;i++) {
					view[i].notifyChange();
				}
			}	
		}
		public function detachView():void {
			view.removeAll();
		}
		public function getStatus():Boolean {
			return serverStatus;
		}
		public function getOutput():String{
			return output;
		}
		public function clearOutput():void {
			output="";
		}
		public function serverOnConnect(event:Event):void {
			serverStatus = true;
			appendOutput("Server: Connected at "+ipAddress);
			getDebugLevels();
		}
		public function serverOnClose():void {
			serverStatus = false;
			appendOutput("Server: Disconnected at "+ipAddress);
		}
		public function serverIOError(event:IOErrorEvent):void {
			
			appendOutput("Server: IO Error at "+ipAddress+": "+event.text);
		}
		public function ServerSecurityError(event:SecurityErrorEvent):void {
			
			appendOutput("Server: Security Error at "+ipAddress+": "+event.text);
		}
		
		public function appendOutput(inString:String):void {
			output = inString + "\n"+output;
			for (var i:int=0;i<view.length;i++) {
				view[i].notifyChange();
			}
		}
		public function serverOnXML(inData:DataEvent) {
			var lines:Array = inData.data.split("\n");

			//remove trailing spaces thing.
			//thing ="<![CDATA["+thing+"]]>";
			var numLines:uint = lines.length;
			for (var i:int = 0; i < numLines; i++)
			{
				var inXML:XML = new XML(lines[i]);
				var node:String = inXML.name();
				
				switch (node) {
				case "ERROR" :
					appendDebugText(inXML);
					break;
				case "LOG" :
					appendDebugText(inXML);
					break;
				case "DEBUG_PACKAGES" :
					generateDebugPackages(inXML);
					break;						
				}
			}
		}
		public function convertTime(inTime):String {
			var time:Date = new Date(inTime);
			return time.getDate()+"-"+(time.getMonth()+1)+"-"+time.getFullYear()+" "+time.getHours()+":"+time.getMinutes()+":"+time.getSeconds();
		}	
		public function appendDebugText(inNode:XML):void {
			var logMessage = "";
			logMessage += "<time>Time: "+convertTime(parseInt(inNode..@TIME))+"</time>";
			logMessage += inNode..@SRC+", "+inNode..@LEVEL+", "+inNode.@MSG+"\n";
			appendOutput(logMessage);
		}
		public function setDefault() {
			for (var index:Number = 0; index<levels.length; index++) {
				changeDebugLevels("INFO", levels[index].packagename);
			}
			getDebugLevels();
		}
		public function changeDebugLevels(logLevel:String, pack:String):void {
			sendToServer('<DEBUG PACKAGE="'+pack+'" LEVEL="'+logLevel+'" />\n');
			getDebugLevels();
		}
		public function generateDebugPackages(inLevels:XML):void {
			var inNode:XML = inLevels[0];
			levels = new ArrayCollection();
			for (var child in inLevels.children()) {
				var inSubXML:XML = inLevels.children()[child];
				var inSubName:String = inSubXML.name();
				
				levels.addItem({shortname:inSubXML..@SHORTNAME, packagename:inSubXML..@PACKAGENAME, level:inSubXML..@LEVEL});
			}
			
			if (view != undefined) {
				for (var i:int=0;i<view.length;i++) {
					view[i].needRefresh();
				}
			}	
		}
		public function getDebugLevels():void {
			sendToServer("<DEBUG_PACKAGES />\n");
		}	
	}
}