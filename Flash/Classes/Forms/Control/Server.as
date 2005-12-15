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
	function Server() {
	}
	public function init():Void {
		monitor_socket = new XMLSocket();
		server_socket = new XMLSocket();
		settingsPanel.setSockets(monitor_socket, server_socket);
		controlPanel.setSockets(monitor_socket, server_socket);
		logLevelsPanel.setSockets(monitor_socket, server_socket);
		irPanel.setSockets(monitor_socket, server_socket);
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
			break;
			case "Controls":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(true);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(false);
			break;
			case "Log":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(true);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(false);
				break;
			case "Log Levels":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(true);
				irPanel.setVisible(false);
				break;
			case "IR":
				settingsPanel.setVisible(false);
				controlPanel.setVisible(false);
				serverLogPanel.setVisible(false);
				logLevelsPanel.setVisible(false);
				irPanel.setVisible(true);
				break;
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
				serverLogPanel.appendDebugText(inNode);
				break;
			case "FILE_TRANSFER" :
				//trace(inNode);
				//do download here
				break;
			case "FILE" :
				//trace(inNode);
				//do download here
				break;
			case "EXEC" :
				if (inNode.hasChildNodes) {
					for (var child:String in inNode.childNodes) {
						controlPanel.appendControlResults(inNode.childNodes[child]);
					}
				}
				break;
			case "FILES" :
				/*switch (inNode.attributes["DIR"]) {
				case "server/config" :
					for (child in inNode.childNodes) {
						configs_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableConfigList();
					break;
				case "server/script" :
					for (child in inNode.childNodes) {
						scripts_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableScriptList();
					break;
				case "server/datafiles" :
					for (child in inNode.childNodes) {
						data_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableDataList();
					break;
				case "client" :
					for (child in inNode.childNodes) {
						client_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableClientList();
					break;
				case "client-core" :
					for (child in inNode.childNodes) {
						client_core_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableClientCoreList();
					break;
				case "server/JRobin/RRDDefinition" :
					for (child in inNode.childNodes) {
						rrd_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableRRDList();
					break;
				case "server/JRobin/GraphDefinition" :
					for (child in inNode.childNodes) {
						graph_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableGraphList();
					break;
				case "server/log" :
					for (child in inNode.childNodes) {
						server_logs_lst.addItem({label:inNode.childNodes[child].attributes["NAME"], desc:inNode.childNodes[child].attributes["DESC"], mod:convertTime(parseInt(inNode.childNodes[child].attributes["MOD"]))});
					}
					enableServerLogsList();
					break;
				default :
					trace(inNode);
					break;
				}
				*/
				break;
			case "DELETE" :
				/*if (inNode.attributes["RESULT"] == "SUCCESS") {
					switch (inNode.attributes["DIR"]) {
					case "server/config" :
						var fileName:String = inNode.firstChild;
						configs_status_lb.text = fileName;
						refreshConfigsList();
						break;
					case "server/script" :
						var fileName:String = inNode.firstChild;
						scripts_status_lb.text = fileName;
						refreshScriptsList();
						break;
					case "server/datafiles" :
						var fileName:String = inNode.firstChild;
						data_status_lb.text = fileName;
						refreshDataList();
						break;
					case "client" :
						var fileName:String = inNode.firstChild;
						client_status_lb.text = fileName;
						refreshClientList();
						break;
					case "client-core" :
						var fileName:String = inNode.firstChild;
						client_core_status_lb.text = fileName;
						refreshClientCoreList();
						break;
					case "server/JRobin/RRDDefinition" :
						var fileName:String = inNode.firstChild;
						rrd_status_lb.text = fileName;
						refreshRRDList();
						break;
					case "server/JRobin/GraphDefinition" :
						var fileName:String = inNode.firstChild;
						graph_status_lb.text = fileName;
						refreshGraphList();
						break;
					case "server/log" :
						var fileName:String = inNode.firstChild;
						server_logs_status_lb.text = fileName;
						refreshServerLogsList();
						break;
					default :
						trace(inNode);
						break;
					}
				}
				*/
				break;
			case "UPLOAD" :
				/*if (inNode.attributes["RESULT"] == "SUCCESS") {
					switch (inNode.attributes["DIR"]) {
					case "server/config" :
						configs_status_lb.text = "Upload Successful";
						refreshConfigsList();
						break;
					case "server/script" :
						scripts_status_lb.text = "Upload Successful";
						refreshScriptsList();
						break;
					case "server/datafiles" :
						data_status_lb.text = "Upload Successful";
						refreshDataList();
						break;
					case "client" :
						client_status_lb.text = "Upload Successful";
						refreshClientList();
						break;
					case "client-core" :
						client_core_status_lb.text = "Upload Successful";
						refreshClientCoreList();
						break;
					case "server/JRobin/RRDDefinition" :
						rrd_status_lb.text = "Upload Successful";
						refreshRRDList();
						break;
					case "server/JRobin/GraphDefinition" :
						graph_status_lb.text = "Upload Successful";
						refreshGraphList();
						break;
					default :
						trace(inNode);
						break;
					}
					}
					*/
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
					/*configs_status_lb.text = inNode.firstChild;*/
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
				serverLogPanel.appendDebugText(inNode);
				break;
			case "LOG" :
				serverLogPanel.appendDebugText("<node>"+inNode.nodeName+": </node>");
				for (var attr:String in inNode.attributes) {
					if ((attr == "TIME") || (attr == "MOD") || (attr == "launched")) {
						serverLogPanel.appendDebugText("<time>"+attr+":\t"+convertTime(parseInt(inNode.attributes[attr]))+"</time>");
					} else {
						serverLogPanel.appendDebugText("<attribute>"+attr+":\t"+inNode.attributes[attr]+"</attribute>");
					}
				}
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
function convertTime (inTime):String {
	return new Date(inTime).toString();
}
}
