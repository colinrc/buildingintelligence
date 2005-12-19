import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.ServerView {
	private var tabBar_tb:mx.controls.TabBar;
	private var serverStatus_lb:mx.controls.Label;
	private var monitorStatus_lb:mx.controls.Label;
	public var controlPanel:Forms.Control.Controls;
	public var serverLogPanel:Forms.Control.ServerLog;
	public var logLevelsPanel:Forms.Control.LogLevels;
	public var irPanel:Forms.Control.IR;
	public var filesPanel:Forms.Control.Files;
	private var server:Objects.ServerObj;
	function ServerView() {
	}
	public function init():Void {
		tabBar_tb.addEventListener("change", Delegate.create(this, setView));
	}
	public function setServer(inServer:Objects.ServerObj){
		server = inServer;
		trace(server.getServerStatus()+"1");
		controlPanel.setSockets(server);
		logLevelsPanel.setSockets(server);
		irPanel.setSockets(server);
		filesPanel.setSockets(server);		
		setServerStatus(server.getServerStatus());
		setMonitorStatus(server.getMonitorStatus());
	}
	
	public function setServerStatus(newText:String):Void {
		trace(newText+"2");
		trace(serverStatus_lb);
		serverStatus_lb.text = newText;
		trace(serverStatus_lb.text+"3");
	}
	public function setMonitorStatus(newText:String):Void {
		monitorStatus_lb.text = newText;
	}
	function setView(eventObj:Object):Void {
		switch (eventObj.target.selectedItem.label) {
		case "Controls" :
			controlPanel.setVisible(true);
			serverLogPanel.setVisible(false);
			logLevelsPanel.setVisible(false);
			irPanel.setVisible(false);
			filesPanel.setVisible(false);
			break;
		case "Log" :
			controlPanel.setVisible(false);
			serverLogPanel.setVisible(true);
			logLevelsPanel.setVisible(false);
			irPanel.setVisible(false);
			filesPanel.setVisible(false);
			break;
		case "Log Levels" :
			controlPanel.setVisible(false);
			serverLogPanel.setVisible(false);
			logLevelsPanel.setVisible(true);
			irPanel.setVisible(false);
			filesPanel.setVisible(false);
			break;
		case "IR" :
			controlPanel.setVisible(false);
			serverLogPanel.setVisible(false);
			logLevelsPanel.setVisible(false);
			irPanel.setVisible(true);
			filesPanel.setVisible(false);
			break;
		case "Files" :
			controlPanel.setVisible(false);
			serverLogPanel.setVisible(false);
			logLevelsPanel.setVisible(false);
			irPanel.setVisible(false);
			filesPanel.setVisible(true);
		}
	}
}
