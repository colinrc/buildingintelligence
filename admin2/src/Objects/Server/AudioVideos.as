﻿package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import Forms.Server.AudioVideos_frm;
	import mx.collections.ArrayCollection;
	
	[Bindable("audioVideos")]
	[RemoteClass(alias="elifeAdmin.objects.server.audioVideos")]
	public class AudioVideos extends BaseElement {
		private var container:String="";
		[Bindable]
		public var audiovideos:ArrayCollection;
		[Bindable]
		public var zoneHeader:String = "";
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(audiovideos);
		}
		
		public override function readExternal(input:IDataInput):void {
			
			super.readExternal(input);
			container = input.readUTF()as String;
			audiovideos = input.readObject()as ArrayCollection;
		}
		
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var audiovideo in audiovideos) {
				tempKeys.push(audiovideos[audiovideo].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var audiovideo in audiovideos) {
				if ((audiovideos[audiovideo].active != "Y") && (audiovideos[audiovideo].active != "N")) {
					flag = "error";
					appendValidationMsg("Active is invalid");
				}
				else {
					if (audiovideos[audiovideo].active =="Y"){
						if ((audiovideos[audiovideo].name == undefined) || (audiovideos[audiovideo].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((audiovideos[audiovideo].display_name == undefined) || (audiovideos[audiovideo].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						} else {
							if (Application.application.isKeyUsed(audiovideos[audiovideo].display_name) == false) {
								flag = "error";
								appendValidationMsg(audiovideos[audiovideo].display_name+" key is not being used");
							}
						}
						if ((audiovideos[audiovideo].key == undefined) || (audiovideos[audiovideo].key == "")) {
							flag = "error";
							appendValidationMsg("Audio/AV Zone is empty");
						}
					}
					else {
						if (audiovideos[audiovideo].active =="N"){
							flag = "empty";
							appendValidationMsg("Audio/AV Zone is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.audiovideo";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.AudioVideos_frm;
			return className;		
		}

		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var audiovideosNode = new XML("<"+container+ " />");
			var itemType:String;
			switch (container) {
			case "HAL" :
			case "TUTONDO" :
				itemType = "AUDIO_OUTPUT";
				break;
			case "KRAMER" :
				itemType = "AV_OUTPUT";
				var newAudioVideoNode = new XML("<"+itemType+" />");
				newAudioVideoNode.@DISPLAY_NAME = "ALL";
				newAudioVideoNode.@KEY = "0";
				audiovideosNode.appendChild(newAudioVideoNode);
				break;
			case "NUVO":
				itemType = "AUDIO";
				var newAudioVideoNode = new XML("<"+itemType+" />");
				newAudioVideoNode.@DISPLAY_NAME = "ALL";
				newAudioVideoNode.@KEY = "0";
				audiovideosNode.appendChild(newAudioVideoNode);
				break;
			case "SIGN_VIDEO":
				itemType = "AV";
				var newAudioVideoNode = new XML("<"+itemType+" />");
				newAudioVideoNode.@DISPLAY_NAME = "ALL";
				newAudioVideoNode.@KEY = "0";
				audiovideosNode.appendChild(newAudioVideoNode);
				break;
			}
			for (var audiovideo in audiovideos) {		
				var newAudioVideoNode = new XML("<"+itemType + " />");
				if (audiovideos[audiovideo].name != "") {
					newAudioVideoNode.@NAME = audiovideos[audiovideo].name;
				}
				if (audiovideos[audiovideo].key != "") {
					newAudioVideoNode.@KEY = audiovideos[audiovideo].key;
				}
				if (audiovideos[audiovideo].display_name != "") {
					newAudioVideoNode.@DISPLAY_NAME = audiovideos[audiovideo].display_name;
				}
				if (audiovideos[audiovideo].active != "") {
					newAudioVideoNode.@ACTIVE = audiovideos[audiovideo].active;
				}
				audiovideosNode.appendChild(newAudioVideoNode);
			}
			return audiovideosNode;
		}
		public override function getName():String {
			var itemType:String;
			switch (container) {
			case "HAL" :
			case "TUTONDO" :
			case "NUVO":
				itemType = "Audio Zones";
				break;
			case "SIGN_VIDEO":
			case "KRAMER" :
				itemType = "AV Zones";
				break;
			}
			return itemType;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode = newNode;	
			return newNode;
		}
		public function getKey():String {
			var itemType:String;
			switch (container) {
			case "HAL" :
			case "TUTONDO" :
			case "NUVO":
				itemType = "AudioZones";
				break;
			case "SIGN_VIDEO":
			case "KRAMER" :
				itemType = "AVZones";
				break;
			}
			return itemType;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({audiovideos:audiovideos, container:container, zoneHeader:zoneHeader, dataObject:this});
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			audiovideos = newData.audiovideos;
		}
		public override function setXML(newData:XML):void {
			audiovideos = new ArrayCollection();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
			
				var newAudiovideo = new Object();
				newAudiovideo.key = "";
				newAudiovideo.display_name = "";
				newAudiovideo.name = "";
				newAudiovideo.active = "Y";
				if (newData.children()[child].@NAME != undefined) {
					newAudiovideo.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newAudiovideo.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newAudiovideo.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newAudiovideo.active = newData.children()[child].@ACTIVE;
				}
				audiovideos.addItem(newAudiovideo);
			}
			switch (container) {
			case "HAL" :
			case "TUTONDO" :
			case "NUVO":
				zoneHeader = "Audio Zone (HEX)";
				break;
			case "SIGN_VIDEO":
			case "KRAMER" :
				zoneHeader = "AV Zone (HEX)";
				break;
			}
		}
	}
}