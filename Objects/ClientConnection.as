package Objects {
	import mx.utils.Delegate;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("MonitorConnection")]
	[RemoteClass(alias="elifeAdmin.objects.server.monitorConnection")]
	public class MonitorConnection {
		private var monitor_socket:XMLSocket;
		private var viewAttached:Boolean;
		private var monitorStatus:String;
		private var view:Object;
		private var __clientName:String;
		private var output:String;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(monitor_socket);
			output.writeBoolean(viewAttached);
			output.writeUTF(monitorStatus);
			output.writeObject(view);
			output.writeUTF(__clientName);
			output.writeUTF(output);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			monitor_socket = input.readObject() as XMLSocket;
			viewAttached = input.readBoolean() as Boolean;
			monitorStatus = input.readUTF() as String;
			view = input.readObject() as Object;
			__clientName = input.readUTF() as String;
			output = input.readUTF() as String;
		}
		
		public function get clientName():String {
			return __clientName;
		}
		public function set clientName(newName:String) {
			__clientName = newName;
		}
		public function ClientConnection() {
			monitor_socket = new XMLSocket();
			viewAttached = undefined;
			output = "";
			monitor_socket.onClose = Delegate.create(this, monitorOnClose);
			monitor_socket.onXML = Delegate.create(this, monitorOnXML);
			monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
		}
		public function disconnectMonitor() {
			monitor_socket.close();
			
		}	
		private function connectToMonitor(ipAddress:String, monitorPort:Number) {
			output = "";		
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
		}
		public function dettachView():Void {
			view = undefined;
		}
		public function getMonitorStatus():String {
			return monitorStatus;
		}
		private function startServer():Void {
			sendToMonitor(new XML('<ADMIN COMMAND="START" />\n'));
		}
		private function stopServer():Void {
			sendToMonitor(new XML('<ADMIN COMMAND="STOP" />\n'));
		}
		private function restartServer():Void {
			sendToMonitor(new XML('<ADMIN COMMAND="RESTART" />\n'));		
		}
		private function restartClient():Void {
			serverConnection.sendToMonitor(new XML('<ADMIN COMMAND="CLIENT_RESTART" />\n'));		
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
		private function getOutput():String{
			return output;
		}
		private function monitorOnConnect(success:Boolean):void {
			if (success) {
				monitorStatus = "Monitor: Connected";
				appendOutput(monitorStatus+" at "+ipAddress+", port "+monitorPort+".");
			} else {
				monitorStatus = "Monitor: Connection Failed";
				appendOutput(monitorStatus+" at "+ipAddress+", port "+monitorPort+".");
			}
		}
		private function monitorOnClose():void {
			monitorStatus = "Monitor: Disconnected";
			appendOutput(monitorStatus+" at "+ipAddress+", port "+monitorPort+".");
		}
		public function appendOutput(inString:String):void {
			output += inString + "\n";
			if (view != undefined) {
				view.notifyChange();
			}
		}
		public function doRestart(){
			
		}
	}
}