import mx.controls.*;
import mx.utils.Delegate;

class Forms.Control.Server {
	private var monitor_socket:XMLSocket;
	private var server_socket:XMLSocket;
	private var tabBar_tb:mx.controls.TabBar;
	private var serverStatus_lb:mx.controls.Label;
	private var monitorStatus_lb:mx.controls.Label;
	private var controlPanel:Forms.Control.Controls;
	private var settingsPanel:Forms.Control.Settings;
	private var serverLogPanel:Forms.Control.ServerLog;
	private var logLevelsPanel:Forms.Control.LogLevels;
	private var irPanel:Forms.Control.IR;
	private var filesPanel:Forms.Control.Files;
	function Server() {
	}
	public function init():Void {
		monitor_socket = new XMLSocket();
		server_socket = new XMLSocket();
		settingsPanel.setSockets(monitor_socket, server_socket);
		controlPanel.setSockets(monitor_socket, server_socket);
		logLevelsPanel.setSockets(monitor_socket, server_socket);
		irPanel.setSockets(monitor_socket, server_socket);
		filesPanel.setSockets(monitor_socket, server_socket);
		tabBar_tb.addEventListener("change", Delegate.create(this, setView));
		setupSockets();
	}
	function setupSockets():Void {
		server_socket.onClose = Delegate.create(this, serverOnClose);
		server_socket.onXML = Delegate.create(this, serverOnXML);
		server_socket.onConnect = Delegate.create(this, serverOnConnect);
		monitor_socket.onClose = Delegate.create(this, monitorOnClose);
		monitor_socket.onXML = Delegate.create(this, monitorOnXML);
		monitor_socket.onConnect = Delegate.create(this, monitorOnConnect);
	}
	function serverOnConnect(success:Boolean) {
		if (success) {
			setServerStatus("Server: Connected");
		} else {
			server_socket.close();
			setServerStatus("Server: Connection Failed");
		}
	}
	function serverOnClose() {
		setServerStatus("Server: Disconnected");
	}
	function monitorOnConnect(success:Boolean) {
		if (success) {
			setMonitorStatus("Monitor: Connected");
		} else {
			monitor_socket.close();
			setMonitorStatus("Monitor: Connection Failed");
		}
	}
	function monitorOnClose() {
		setMonitorStatus("Monitor: Disconnected");
	}
	function setServerStatus(newText:String):Void {
		serverStatus_lb.text = newText;
	}
	function setMonitorStatus(newText:String):Void {
		monitorStatus_lb.text = newText;
	}
	function setView(eventObj:Object):Void {
		switch(eventObj.target.selectedItem.label){
			case "Server":
				settingsPanel.setVisible(true);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(false);
				filesPanel.setVisible(false);
			break;
			case "Controls":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(true);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(false);
				filesPanel.setVisible(false);
			break;
			case "Log":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(true);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(false);
				filesPanel.setVisible(false);
				break;
			case "Log Levels":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(true);
				irPanel.setVisible(false);
				filesPanel.setVisible(false);
				break;
			case "IR":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(true);
				filesPanel.setVisible(false);
				break;
			case "Files":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(false);
				filesPanel.setVisible(true);
			}
	}
	function monitorOnXML(inXML:XML) {
		processMonitorNode(inXML.firstChild);
	}
	function processMonitorNode(inNode) {
	while (inNode != null) {
		/*if valid node, ignoreWhite isnt working properly*/
		if (inNode.nodeName != null) {
			switch (inNode.nodeName) {
			case "ERROR" :
				//serverLogPanel.appendDebugText(inNode);
				trace(inNode);
				break;
			case "FILE_TRANSFER" :
				//trace(inNode);
				//do download here
				break;
			case "FILE" :
				filesPanel.fileDownloaded(inNode);
				break;
			case "EXEC" :
				if (inNode.hasChildNodes) {
					for (var child:String in inNode.childNodes) {
						controlPanel.appendControlResults(inNode.childNodes[child]);
					}
				}
				break;
			case "FILES" :
					filesPanel.filesList(inNode);
				break;
			case "DELETE" :
					filesPanel.fileDeleted(inNode);
				break;
			case "UPLOAD" :
					filesPanel.fileUploaded(inNode);
					break;
				case "STARTUP_FILE" :
					/*startupFile = inNode.attributes["NAME"];*/
					break;
				case "ADMIN" :
					controlPanel.appendControlResults(inNode);
					break;
				case "HEARTBEAT" :
					break;
				case "SELECT" :
					filesPanel.fileSelected(inNode);
					break;
				default :
					trace(inNode);
					break;
				}
			}
			inNode = inNode.nextSibling;
		}
	}
	function serverOnXML(inXML:XML) {
		processServerNode(inXML.firstChild);	
	}
	function processServerNode(inNode) {
		while (inNode != null) {
			/*if valid node, ignoreWhite isnt working properly*/
			if (inNode.nodeName != null) {
				switch (inNode.nodeName) {
				case "ERROR" :
					//serverLogPanel.appendDebugText(inNode);
					trace(inNode);
					break;
				case "LOG" :
					serverLogPanel.appendDebugText(inNode);
					/*serverLogPanel.appendDebugText("<node>"+inNode.nodeName+": </node>");
					for (var attr:String in inNode.attributes) {
						if ((attr == "TIME") || (attr == "MOD") || (attr == "launched")) {
							serverLogPanel.appendDebugText("<time>"+attr+":\t"+convertTime(parseInt(inNode.attributes[attr]))+"</time>");
						} else {
							serverLogPanel.appendDebugText("<attribute>"+attr+":\t"+inNode.attributes[attr]+"</attribute>");
						}
					}*/
					break;
				case "DEBUG_PACKAGES" :
					logLevelsPanel.generateDebugLevels(inNode);
					break;
				case "IR_DEVICE_LIST" :
					irPanel.deviceList(inNode);
					break;
				case "IR_ACTION_LIST" :
					irPanel.actionList(inNode);
					break;
				case "IR_CONFIG":
					irPanel.irResult(inNode);
					break;
				case "IR_LEARNT" :
					irPanel.irLearnt(inNode);
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
