﻿package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import mx.collections.ArrayCollection;
	import Forms.Server.Cameras_frm;
	
	[Bindable("cameras")]
	[RemoteClass(alias="elifeAdmin.objects.server.cameras")]
		public class Cameras extends BaseElement {
		private var container:String="";
		[Bindable]
		public var cameras:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(cameras);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			cameras = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var camera in cameras) {
				tempKeys.push(cameras[camera].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var camera in cameras) {
				if ((cameras[camera].active != "Y") && (cameras[camera].active != "N")) {
					flag = "error";
					appendValidationMsg("Active is invalid");
				}
				else {
					if (cameras[camera].active =="Y"){
						if ((cameras[camera].name == undefined) || (cameras[camera].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((cameras[camera].key == undefined) || (cameras[camera].key == "")) {
							flag = "error";
							appendValidationMsg("Camera Zone is empty");
						}
						if ((cameras[camera].display_name == undefined) || (cameras[camera].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(cameras[camera].display_name) == false) {
								flag = "error";
								appendValidationMsg(cameras[camera].display_name+" key is not used");
							}
						}
						if ((cameras[camera].zoom == undefined) || (cameras[camera].zoom == "")) {
							flag = "error";
							appendValidationMsg("Camera Zoom is empty");
						}
					}
					else {
						if (cameras[camera].active =="N"){
							flag = "empty";
							appendValidationMsg("Camera " + cameras[camera].display_name + " is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.camera";
		}
		public override function toXML():XML{
			if (container.length == 0) {
				return XML();
			}
			
			var camerasNode:XML = new XML("<"+container+" />");
			for (var camera in cameras) {
				var newCamera = new XML("<CAMERA />");
				if (cameras[camera].name != "") {
					newCamera.@NAME = cameras[camera].name;
				}
				if (cameras[camera].key != "") {
					newCamera.@KEY = cameras[camera].key;
				}
				if (cameras[camera].display_name != "") {
					newCamera.@DISPLAY_NAME = cameras[camera].display_name;
				}
				if (cameras[camera].active != "") {
					newCamera.@ACTIVE = cameras[camera].active;
				}
				if (cameras[camera].zoom != "") {
					newCamera.@ZOOM = cameras[camera].zoom;
				}			
				camerasNode.appendChild(newCamera);
			}
			return camerasNode;
		}
		public override function getName():String {
			return "Cameras";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode = newNode;	
			return newNode;
		}
		public function getKey():String {
			return "Cameras";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.Cameras_frm;
			return className;		
		}
		
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			cameras = newData.cameras;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({cameras:cameras, dataObject:this});
			return ob;
		}
		public override function setXML(newData:XML):void {
			cameras = new ArrayCollection();
			container = newData.name().toString();
			for (var child in newData.children()) {
				var newCamera = new Object();
				newCamera.active = "Y";
				newCamera.name = "";
				newCamera.key = "";
				newCamera.display_name = "";
				newCamera.zoom = "";
				if (newData.children()[child].@NAME != undefined) {
					newCamera.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newCamera.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newCamera.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@ZOOM != undefined) {
					newCamera.zoom = newData.children()[child].@ZOOM;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newCamera.active = newData.children()[child].@ACTIVE;
				}
				cameras.addItem(newCamera);
			}
		}
	}
}