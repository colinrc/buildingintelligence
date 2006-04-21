import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.PublishClient extends Forms.BaseForm {
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
	private var fullScreen_chk:CheckBox;
	private var hideMouse_chk:CheckBox;
	private var debugMode_chk:CheckBox;
	public function PublishClient() {
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
				case "Client Config":
					sftpConnection.setRemotePath("/client");
					sftpConnection.putData(_global.writeXMLFile(dataObject.clientDesign.toXML(), 0),"client.xml");
					break;
				case "Bootstrap Config":
					sftpConnection.setRemotePath("/client");
					sftpConnection.putData(generateBootstrap(),"elife.xml");
					break;
				case "Icons":
					sftpConnection.setLocalPath("/lib/icons");				
					sftpConnection.setRemotePath("/client/lib/icons");
					var tempIcons = dataObject.clientDesign.getIcons();
					tempIcons = tempIcons.sort();
					var icons = new Array();
					var lastIcon:String;
					for(var tempIcon in tempIcons){
						if(tempIcons[tempIcon] != lastIcon){
							icons.push(tempIcons[tempIcon]);
							lastIcon = tempIcons[tempIcon];
						}
					}
					var new_icons = "";
					for(var icon in icons){
						sftpConnection.putItem(icons[icon]+".png");
					}
					break;
				case "Maps":
					sftpConnection.setLocalPath("/lib/maps");
					sftpConnection.setRemotePath("/client/lib/maps");
					var tempZones = dataObject.clientDesign.Property.zones;
					for(var zone in tempZones){
						if((tempZones[zone].map != undefined)&&(tempZones[zone].map != "")){
							sftpConnection.putItem(tempZones[zone].map);
						}
					}
					break;
				case "Backgrounds":
					sftpConnection.setLocalPath("/lib/backgrounds");
					sftpConnection.setRemotePath("/client/lib/backgrounds");
					var tempZones = dataObject.clientDesign.Property.zones;
					for(var zone in tempZones){
						if((tempZones[zone].background != undefined)&&(tempZones[zone].background != "")){
							sftpConnection.putItem(tempZones[zone].background);
						}
					}
					break;
				case "Sounds":
					sftpConnection.setLocalPath("/lib");
					sftpConnection.setRemotePath("/client/lib");
					var tempSounds = dataObject.clientDesign.sounds.sounds;
					for(var sound in tempSounds){
						sftpConnection.putItem(tempSounds[sound].attributes.file);
					}					
					break;
				case "Objects":
					sftpConnection.setLocalPath("/lib/objects");
					sftpConnection.setRemotePath("/client/lib/objects");
					/*
					sftpConnection.putItem("ircodes.xml");
					*/
					break;
			}
		}
	}
	public function generateBootstrap():String{
		var newBootstrapXML = new XMLNode(1,"client");
		var newServerNode = new XMLNode(1,"setting");
		newServerNode.attributes.name = "serverAddress";
		newServerNode.attributes.value = dataObject.serverParent.ipAddress;
		newBootstrapXML.appendChild(newServerNode);
		
		var newApplicationNode = new XMLNode(1,"setting");
		newApplicationNode.attributes.name = "applicationXML";
		newApplicationNode.attributes.value = "client.xml";
		newBootstrapXML.appendChild(newApplicationNode);
		
		var newFullScreenNode = new XMLNode(1,"setting");
		newFullScreenNode.attributes.name = "fullScreen";
		if(fullScreen_chk.selected){
			newFullScreenNode.attributes.value = "true";
		} else{
			newFullScreenNode.attributes.value = "false";
		}
		newBootstrapXML.appendChild(newFullScreenNode);

		var newHideCursorNode = new XMLNode(1,"setting");
		newHideCursorNode.attributes.name = "hideMouseCursor";
		if(hideMouse_chk.selected){
			newHideCursorNode.attributes.value = "true";
		} else{
			newHideCursorNode.attributes.value = "false";
		}
		newBootstrapXML.appendChild(newHideCursorNode);
		
		var newDebugNode = new XMLNode(1,"setting");
		newDebugNode.attributes.name = "debugMode";
		if(debugMode_chk.selected){
			newDebugNode.attributes.value = "true";
		} else{
			newDebugNode.attributes.value = "false";
		}
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
