import mx.controls.*;
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
	private var gui_chk:CheckBox;
	private var file_chk:CheckBox;
	private var console_chk:CheckBox;
	private var level_cmb:ComboBox;
	public function PublishServer() {
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
	}
	public function SFTPdisconnected():Void{
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
					sftpConnection.setLocalPath("/datafiles");				
					sftpConnection.setRemotePath("/server/datafiles");
					sftpConnection.putItem("ircodes.xml");
					break;					
				case "Scripts":
					var myScripts = mdm.FileSystem.getFileList(mdm.Application.path+"script", "*.py");
					var newScriptStatus = new XMLNode(1,"SCRIPT_STATUS");
					for(var myScript =0; myScript <myScripts.length; myScript++){
						sftpConnection.setLocalPath("/script");
						sftpConnection.setRemotePath("/script");
						var newScript = new XMLNode(1,"SCRIPT");
						newScript.attributes.NAME = myScripts[myScript];
						newScript.attributes.ENABLED = "enabled";
						newScript.attributes.STATUS = "";
						newScriptStatus.appendChild(newScript);
						sftpConnection.putItem(myScripts[myScript]);
					}
					sftpConnection.setLocalPath("/datafiles");
					sftpConnection.setRemotePath("/server/datafiles");					
					sftpConnection.putData(_global.writeXMLFile(newScriptStatus, 0),"script_status.xml");
					break;
				case "Macros":
					sftpConnection.setLocalPath("/datafiles");
					sftpConnection.setRemotePath("/server/datafiles");
					sftpConnection.putItem("macros.xml");
					break;
				case "Calendar":
					sftpConnection.setLocalPath("/datafiles");				
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
		newServerNode.attributes.PORT = "10001";
		newBootstrapXML.appendChild(newServerNode);
		var newAdminNode = new XMLNode(1,"ADMIN");
		newAdminNode.attributes.IP = "";
		newAdminNode.attributes.PORT = "10002";
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
		newDebugNode.attributes.LOGDIR = "server/log";
		newBootstrapXML.appendChild(newDebugNode);		
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
