﻿import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.PublishServer extends Forms.BaseForm {
	private var dataObject:Object;
	private var sftpConnection:Object;
	private var output_ta:TextArea;
	private var appPath:String;
	private var right_li:List;
	private var left_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	private var publish_btn:Button;
	private var export_btn:Button;
	private var gui_chk:CheckBox;
	private var file_chk:CheckBox;
	private var console_chk:CheckBox;
	private var level_cmb:ComboBox;
	public function PublishServer() {
		appPath = mdm.Application.path.substring(0, mdm.Application.path.length - 1);
	}
	public function onUnload():Void{
		sftpConnection.dettachView();
	}	
	public function onLoad():Void {
		sftpConnection.attachView(this);		
		output_ta.editable = false;
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));		
		publish_btn.addEventListener("click", Delegate.create(this, publish));
		export_btn.addEventListener("click", Delegate.create(this, export));
	}
	public function SFTPdisconnected():Void{
	}
	public function export(){
		for(var publishItem in right_li.dataProvider){
			switch(right_li.dataProvider[publishItem].label){
				case "Server Config":
					mdm.FileSystem.saveFile(_global.project.path+"/server/config/server.xml", _global.writeXMLFile(_global.serverDesign.toXML(), 0));
					output_ta.text = output_ta.text+"Server Configuration exported\n";
					break;
				case "Bootstrap Config":
					mdm.FileSystem.saveFile(_global.project.path+"/server/datafiles/bootstrap.xml", _global.writeXMLFile(generateBootstrap(), 0));
					output_ta.text = output_ta.text+"Server Bootstrap exported\n";
					break;
				case "IR Codes":
					mdm.FileSystem.copyFile(mdm.Application.path+"datafiles/ircodes.xml", _global.project.path+"/server/datafiles/ircodes.xml");
					output_ta.text = output_ta.text+"Server IR Codes exported\n";
					break;					
				case "Scripts":
					mdm.FileSystem.saveFile(_global.project.path+"/server/datafiles/script_status.xml", _global.writeXMLFile(_global.serverDesign.getScripts(), 0));
					output_ta.text = output_ta.text+"Server Scripts exported\n";
					break;
				case "Macros":
					var tempMacros = new XMLNode(1,"MACROS");
					tempMacros.attributes.COMPLETE = "Y";
					var tempIntegratorMacros = new XMLNode(1,"MACROS");
					tempIntegratorMacros.attributes.COMPLETE = "Y";					
					var macros = _global.serverDesign.getMacros();
					for(var macro = 0; macro<macros.length; macro++){
						if(macros[macro].integrator){
							tempIntegratorMacros.appendChild(macros[macro].publish());
						} else{
							tempMacros.appendChild(macros[macro].publish());
						}
					}
					mdm.FileSystem.saveFile(_global.project.path+"/server/datafiles/macros.xml",_global.writeXMLFile(tempMacros, 0));
					mdm.FileSystem.saveFile(_global.project.path+"/server/datafiles/integrator_macros.xml", _global.writeXMLFile(tempIntegratorMacros, 0));
					output_ta.text = output_ta.text+"Server Macros exported\n";
					break;
				case "Calendar":
					mdm.FileSystem.copyFile(mdm.Application.path+"datafiles/calendar.xml", _global.project.path+"/server/datafiles/calendar.xml");
					output_ta.text = output_ta.text+"Server Calendar exported\n";
					break;					
			}
		}
	}
	public function publish(){
		for(var publishItem in right_li.dataProvider){
			switch(right_li.dataProvider[publishItem].label){
				case "Server Config":
					sftpConnection.setRemotePath("/server/config");
					sftpConnection.putData(_global.writeXMLFile(_global.serverDesign.toXML(), 0),"server.xml");
					break;
				case "Bootstrap Config":
					sftpConnection.setRemotePath("/server/datafiles");
					sftpConnection.putData(generateBootstrap(),"bootstrap.xml");
					break;
				case "IR Codes":
					sftpConnection.setLocalPath(appPath +"/datafiles");				
					sftpConnection.setRemotePath("/server/datafiles");
					sftpConnection.putItem("ircodes.xml");
					break;					
				case "Scripts":
					var scriptsNode = _global.serverDesign.getScripts();
					for(var child in scriptsNode.childNodes){
						sftpConnection.setLocalPath(_global.project.path+"/server/script");
						sftpConnection.setRemotePath("/server/script");
						sftpConnection.putItem(scriptsNode.childNodes[child].attributes["NAME"]+".py");
					}
					sftpConnection.setLocalPath(appPath +"/datafiles");
					sftpConnection.setRemotePath("/server/datafiles");					
					sftpConnection.putData(_global.writeXMLFile(scriptsNode, 0),"script_status.xml");
					break;
				case "Macros":
					sftpConnection.setLocalPath(appPath +"/datafiles");
					sftpConnection.setRemotePath("/server/datafiles");				
					var tempMacros = new XMLNode(1,"MACROS");
					tempMacros.attributes.COMPLETE = "Y";
					var tempIntegratorMacros = new XMLNode(1,"MACROS");
					tempIntegratorMacros.attributes.COMPLETE = "Y";					
					var macros = _global.serverDesign.getMacros();
					for(var macro = 0; macro<macros.length; macro++){
						if(macros[macro].integrator){
							tempIntegratorMacros.appendChild(macros[macro].publish());
						} else{
							tempMacros.appendChild(macros[macro].publish());
						}
					}
					sftpConnection.putData(_global.writeXMLFile(tempMacros, 0),"macros.xml");
					sftpConnection.putData(_global.writeXMLFile(tempIntegratorMacros, 0),"integrator_macros.xml");
					break;
				case "Calendar":
					sftpConnection.setLocalPath(appPath +"/datafiles");				
					sftpConnection.setRemotePath("/server/datafiles");
					sftpConnection.putItem("calendar.xml");
					break;					
			}
		}
	}
	public function generateBootstrap():String{
		var newBootstrapXML = new XMLNode(1,"BOOTSTRAP");
		var newServerNode = new XMLNode(1,"SERVER");
		newServerNode.attributes.IP = "";
		newServerNode.attributes.PORT = "10000";
		newBootstrapXML.appendChild(newServerNode);
		var newAdminNode = new XMLNode(1,"ADMIN");
		newAdminNode.attributes.IP = "";
		newAdminNode.attributes.PORT = "10001";
		newBootstrapXML.appendChild(newAdminNode);
		var newConfigNode = new XMLNode(1,"CONFIG_FILE");
		newConfigNode.attributes.NAME = "server.xml";
		newBootstrapXML.appendChild(newConfigNode);
		var newDebugNode = new XMLNode(1,"DEBUG");
		if(file_chk.selected){
			newDebugNode.attributes.FILE = "Y";
		} else{
			newDebugNode.attributes.FILE = "N";
		}
		if(console_chk.selected){
			newDebugNode.attributes.CONSOLE = "Y";
		} else{
			newDebugNode.attributes.CONSOLE = "N";
		}
		newDebugNode.attributes.LEVEL = level_cmb.text;
		newBootstrapXML.appendChild(newDebugNode);
		var newRRDGraphNode = new XMLNode(1,"RRDGRAPH");
		newRRDGraphNode.attributes.DIR = "./JRobin/Graph/";
		newBootstrapXML.appendChild(newRRDGraphNode);
		var newRRDDirectoryNode = new XMLNode(1,"RRDBDIRECTORY");
		newRRDDirectoryNode.attributes.DIR = "./JRobin/";
		newBootstrapXML.appendChild(newRRDDirectoryNode);
		var newRRDXMLNode = new XMLNode(1,"RRDXMLDIRECTORY");
		newRRDXMLNode.attributes.DIR = "./JRobin/RRDDefinition/";
		newBootstrapXML.appendChild(newRRDXMLNode);
		return _global.writeXMLFile(newBootstrapXML,0);
	}
	public function notifyChange():Void{
		refreshOutput();
	}
	public function refreshOutput():Void {
		output_ta.text = sftpConnection.getOutput();
	}
	private function addSel() {
		if (left_li.selectedItem != undefined) {
			right_li.addItem(left_li.removeItemAt(left_li.selectedIndex));
			right_li.sortItemsBy("label", "ASC");
		}
	}
	private function addAll() {
		var leftLength = left_li.length;
		for (var leftIndex = 0; leftIndex < leftLength; leftIndex++) {
			right_li.addItem(left_li.removeItemAt(0));
		}
		right_li.sortItemsBy("label", "ASC");
	}
	private function remSel() {
		if (right_li.selectedItem != undefined) {
			left_li.addItem(right_li.removeItemAt(right_li.selectedIndex));
			left_li.sortItemsBy("label", "ASC");
		}
	}
	private function remAll() {
		var rightLength = right_li.length;
		for (var rightIndex = 0; rightIndex < rightLength; rightIndex++) {
			left_li.addItem(right_li.removeItemAt(0));
		}
		left_li.sortItemsBy("label", "ASC");
	}
}
