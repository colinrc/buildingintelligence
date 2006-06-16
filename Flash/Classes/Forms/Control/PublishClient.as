﻿import mx.controls.*;
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
	private var export_btn:Button;
	private var fullScreen_chk:CheckBox;
	private var hideMouse_chk:CheckBox;
	private var debugMode_chk:CheckBox;
	public function PublishClient() {
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
				case "Client Config":
					mdm.FileSystem.saveFile(_global.project.path+"/client/client.xml", _global.writeXMLFile(dataObject.clientDesign.toXML(), 0));
					break;
				case "Bootstrap Config":
					mdm.FileSystem.saveFile(_global.project.path+"/client/elife.xml", _global.writeXMLFile(generateBootstrap(), 0));
					break;
				case "Icons":
					var tempIcons = dataObject.clientDesign.getIcons();
					tempIcons = tempIcons.sort();
					tempIcons.push("warning");
					tempIcons.push("keyboard_key");
					tempIcons.push("atom");
					tempIcons.push("up-arrow");
					tempIcons.push("down-arrow");
					tempIcons.push("delete");
					tempIcons.push("home");
					tempIcons.push("left-arrow");
					tempIcons.push("right-arrow");
					tempIcons.push("stop");
					tempIcons.push("refresh");
					tempIcons.push("find");
					tempIcons.push("gears");
					tempIcons.push("notepad");
					tempIcons.push("speaker");
					tempIcons.push("spanner");
					tempIcons.push("red-pin");
					tempIcons.push("media-stop");
					tempIcons.push("media-fwd");
					tempIcons.push("media-play");
					tempIcons.push("delete2");
					tempIcons.push("led-green");
					tempIcons.push("led-red");
					tempIcons.push("power-red");
					tempIcons.push("power-green");
					tempIcons.push("locked");
					tempIcons.push("unlocked");
					tempIcons.push("calendar");
					tempIcons.push("check");
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
						var iconString = icons[icon]+".png";
						mdm.FileSystem.copyFile(mdm.Application.path+"/lib/icons/"+icons[icon]+".png", _global.project.path+"/client/lib/icons/"+icons[icon]+".png");
						new_icons += iconString+"\n";
					}
					mdm.FileSystem.saveFile(_global.project.path+"/client/lib/icons/_icons.txt", new_icons);
					break;
				case "Maps":
					var tempZones = dataObject.clientDesign.Property.zones;
					for(var zone in tempZones){
						if((tempZones[zone].map != undefined)&&(tempZones[zone].map != "")){
							mdm.FileSystem.copyFile(mdm.Application.path+"/lib/maps/"+tempZones[zone].map, _global.project.path+"/client/lib/maps/"+tempZones[zone].map);
						}
					}
					break;
				case "Backgrounds":
					var tempZones = dataObject.clientDesign.Property.zones;
					for(var zone in tempZones){
						if((tempZones[zone].background != undefined)&&(tempZones[zone].background != "")){
							mdm.FileSystem.copyFile(mdm.Application.path+"/lib/backgrounds/"+tempZones[zone].background, _global.project.path+"/client/lib/backgrounds/"+tempZones[zone].background);
						}
					}
					break;
				case "Sounds":
					var tempSounds = dataObject.clientDesign.sounds.sounds;
					for(var sound in tempSounds){
						mdm.FileSystem.copyFile(mdm.Application.path+"/lib/"+tempSounds[sound].attributes.file, _global.project.path+"/client/lib/"+tempSounds[sound].attributes.file);
					}					
					break;
				case "Objects":
					/*
					sftpConnection.setLocalPath(appPath +"/lib/objects");
					sftpConnection.setRemotePath("/client/lib/objects");

					sftpConnection.putItem("ircodes.xml");
					*/
					break;
			}
		}
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
					sftpConnection.setLocalPath(appPath +"/lib/icons");				
					sftpConnection.setRemotePath("/client/lib/icons");
					var tempIcons = dataObject.clientDesign.getIcons();
					tempIcons = tempIcons.sort();
					tempIcons.push("warning");
					tempIcons.push("keyboard_key");
					tempIcons.push("atom");
					tempIcons.push("up-arrow");
					tempIcons.push("down-arrow");
					tempIcons.push("delete");
					tempIcons.push("home");
					tempIcons.push("left-arrow");
					tempIcons.push("right-arrow");
					tempIcons.push("stop");
					tempIcons.push("refresh");
					tempIcons.push("find");
					tempIcons.push("gears");
					tempIcons.push("notepad");
					tempIcons.push("speaker");
					tempIcons.push("spanner");
					tempIcons.push("red-pin");
					tempIcons.push("media-stop");
					tempIcons.push("media-fwd");
					tempIcons.push("media-play");
					tempIcons.push("delete2");
					tempIcons.push("led-green");
					tempIcons.push("led-red");
					tempIcons.push("power-red");
					tempIcons.push("power-green");
					tempIcons.push("locked");
					tempIcons.push("unlocked");
					tempIcons.push("calendar");
					tempIcons.push("check");
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
						var iconString = icons[icon]+".png";
						sftpConnection.putItem(iconString);
						new_icons += iconString+"\n";
					}
					sftpConnection.putData(new_icons,"_icons.txt");
					break;
				case "Maps":
					sftpConnection.setLocalPath(appPath +"/lib/maps");
					sftpConnection.setRemotePath("/client/lib/maps");
					var tempZones = dataObject.clientDesign.Property.zones;
					for(var zone in tempZones){
						if((tempZones[zone].map != undefined)&&(tempZones[zone].map != "")){
							sftpConnection.putItem(tempZones[zone].map);
						}
					}
					break;
				case "Backgrounds":
					sftpConnection.setLocalPath(appPath +"/lib/backgrounds");
					sftpConnection.setRemotePath("/client/lib/backgrounds");
					var tempZones = dataObject.clientDesign.Property.zones;
					for(var zone in tempZones){
						if((tempZones[zone].background != undefined)&&(tempZones[zone].background != "")){
							sftpConnection.putItem(tempZones[zone].background);
						}
					}
					break;
				case "Sounds":
					sftpConnection.setLocalPath(appPath +"/lib");
					sftpConnection.setRemotePath("/client/lib");
					var tempSounds = dataObject.clientDesign.sounds.sounds;
					for(var sound in tempSounds){
						sftpConnection.putItem(tempSounds[sound].attributes.file);
					}					
					break;
				case "Objects":
					sftpConnection.setLocalPath(appPath +"/lib/objects");
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
		
		var newPortNode = new XMLNode(1,"setting");
		newPortNode.attributes.name = "serverPort";
		newPortNode.attributes.value = "10000";
		newBootstrapXML.appendChild(newPortNode);
		
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
