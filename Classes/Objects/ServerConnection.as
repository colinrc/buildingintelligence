import mx.utils.Delegate;
class Objects.ServerConnection {
	private var server_socket:XMLSocket;
	private var serverStatus:Boolean;
	private var view:Object;
	private var levels:Array;
	private var ipAddress:String;
	private var output:String;
	public function ServerConnection() {
		server_socket = new XMLSocket();
		view = undefined;		
		output = "";
		serverStatus = false;
		levels = new Array();
		server_socket.onClose = Delegate.create(this, serverOnClose);
		server_socket.onXML = Delegate.create(this, serverOnXML);
		server_socket.onConnect = Delegate.create(this, serverOnConnect);
	}
	public function getLevels():Array{
		return levels;
	}
	public function disconnect() {
		if(serverStatus){
			setDefault();
			server_socket.close();
			serverStatus = false;		
			appendOutput("Disconnected Successfully");
		} else{
			appendOutput("Error: No Connection Present");			
		}
	}
	private function connect(inIpAddress:String, port) {
		ipAddress = inIpAddress;
		server_socket.connect(ipAddress, port);
	}
	public function sendToServer(inXML:XML) {
		server_socket.send(inXML);
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
		return serverStatus;
	}
	private function getOutput():String{
		return output;
	}
	private function serverOnConnect(success:Boolean) {
		if (success) {
			serverStatus = true;
			appendOutput("Server: Connected at "+ipAddress);
			getDebugLevels();
		} else {
			serverStatus = false;
			appendOutput("Server: Connection Failed at "+ipAddress);
		}
	}
	private function serverOnClose() {
		serverStatus = false;
		appendOutput("Server: Disconnected at "+ipAddress);
	}
	public function appendOutput(inString:String):Void {
		output = inString + "\n"+output;
		if (view != undefined) {
			view.notifyChange();
		}
	}
	private function serverOnXML(inXML:XML) {
		var inNode = inXML.firstChild;
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
					generateDebugPackages(inNode);
					break;					
				}
			}
			inNode = inNode.nextSibling;
		}
	}
	private function convertTime(inTime):String {
		var time:Date = new Date(inTime);
		return time.getDay()+"-"+time.getMonth()+"-"+time.getFullYear()+" "+time.getHours()+":"+time.getMinutes()+":"+time.getSeconds();
	}	
	public function appendDebugText(inNode:XMLNode):Void {
		var logMessage = "";
		logMessage += "<time>Time: "+convertTime(parseInt(inNode.attributes["TIME"]))+"</time>";
		logMessage += inNode.attributes["SRC"]+", "+inNode.attributes["LEVEL"]+", "+inNode.attributes["MSG"]+"\n";
		appendOutput(logMessage);
	}
	public function setDefault() {
		for (var index:Number = 0; index<levels.length; index++) {
			changeDebugLevels("INFO", levels[index].packagename);
		}
		getDebugLevels();
	}
	private function changeDebugLevels(logLevel:String, package:String):Void {
		sendToServer(new XML('<DEBUG PACKAGE="'+package+'" LEVEL="'+logLevel+'" />\n'));
		getDebugLevels();
	}
	public function generateDebugPackages(inLevels:XMLNode):Void {
		var inNode:XMLNode = inLevels.firstChild;
		levels = new Array();
		while (inNode != undefined) {
			levels.push({shortname:inNode.attributes["SHORTNAME"], packagename:inNode.attributes["PACKAGENAME"], level:inNode.attributes["LEVEL"]});
			inNode = inNode.nextSibling;
		}
		if (view != undefined) {
			view.needRefresh();
		}		
	}
	private function getDebugLevels():Void {
		sendToServer(new XML('<DEBUG_PACKAGES />\n'));
	}	
}
