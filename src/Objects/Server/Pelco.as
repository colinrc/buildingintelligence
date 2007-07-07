package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.describeType;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Pelco_frm;
	
	[Bindable("Pelco")]
	[RemoteClass(alias="elifeAdmin.objects.server.pelco")]
	public class Pelco extends Device {
		private var cameras:Cameras;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(cameras);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			cameras = input.readObject()as Cameras;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(cameras.getKeys());
			return tempKeys;
		}
		public override function toXML():XML{
			var newDevice:XML = new XML("<DEVICE />");
			if(device_type != ""){
				newDevice.@DEVICE_TYPE = device_type;
			}
			if(description != ""){
				newDevice.@DESCRIPTION = description;
			}
			if(active != "") {
				newDevice.@ACTIVE = active;
			}
			newDevice.appendChild(connection.toXML());
			var newParameters:XML = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				var x1:XML = new XML("<ITEM />");
				x1.@NAME = parameter;
				x1.@VALUE = parameters[parameter];
				newParameters.appendChild(x1);
			}
			newDevice.appendChild(newParameters);
			var newPelco:XML = new XML("<"+device_type+" />");
			var tempCameras:XML = cameras.toXML();
			for (var child:int = 0; child<tempCameras.children().length;child++){
				newPelco.appendChild(tempCameras.children()[child]);
			}
			newDevice.appendChild(newPelco);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(cameras.toTree());
		
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Pelco";
		}	
		public function getClassForm():Class {
			var className:Class = Forms.Server.Pelco_frm;
			return className;		
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "PELCO";
			description ="";
			active = "Y";
			parameters.put("PROTOCOL","D");
						
			
			cameras = new Objects.Server.Cameras();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "PELCO";
			description ="";
			active = "Y";
			parameters = new HashMap();
			cameras = new Objects.Server.Cameras();
			if (newData.name() == "DEVICE") {
				device_type = newData.@NAME;
				device_type = newData.@DEVICE_TYPE;		
				description = newData.@DISPLAY_NAME;	
				if (description == undefined ||description == "" ) {
					description = newData.@DESCRIPTION;
				}		
				active = newData.@ACTIVE;
				for (var child:int = 0; child<newData.children().length();child++){	
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "PELCO" :
						cameras.setXML(newData.children()[child]);
						break;
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						}
						break;
					}
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}