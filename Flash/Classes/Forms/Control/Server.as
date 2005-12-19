﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.ServerView {
	private var tabBar_tb:mx.controls.TabBar;
	private var serverStatus_lb:mx.controls.Label;
	private var monitorStatus_lb:mx.controls.Label;
	private var controlPanel:Forms.Control.Controls;
	private var serverLogPanel:Forms.Control.ServerLog;
	private var logLevelsPanel:Forms.Control.LogLevels;
	private var irPanel:Forms.Control.IR;
	private var filesPanel:Forms.Control.Files;
	private var server:Objects.ServerObj;
	function Server() {
	}
	public function init():Void {
		//settingsPanel.setSockets(monitor_socket, server_socket);
		//controlPanel.setSockets(monitor_socket, server_socket);
		//logLevelsPanel.setSockets(monitor_socket, server_socket);
		//irPanel.setSockets(monitor_socket, server_socket);
		//filesPanel.setSockets(monitor_socket, server_socket);
		tabBar_tb.addEventListener("change", Delegate.create(this, setView));
	}
	function setServerStatus(newText:String):Void {
		serverStatus_lb.text = newText;
	}
	function setMonitorStatus(newText:String):Void {
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
