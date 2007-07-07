package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Tutondo_frm;
	
	[Bindable("Tutondo")]
	[RemoteClass(alias="elifeAdmin.objects.server.tutondo")]
		public class Tutondo extends Device {
		private var audiovideos:AudioVideos;
		private var inputs:Catalogue;
		private var functions:Catalogue;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(audiovideos);
			output.writeObject(inputs);
			output.writeObject(functions);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			audiovideos = input.readObject()as AudioVideos;
			inputs = input.readObject()as Catalogue;
			functions = input.readObject()as Catalogue;
		}
		
		public function getKeys():Array{
			var tempKeys:Array = new Array();
			tempKeys = tempKeys.concat(audiovideos.getKeys());
			return tempKeys;
		}
		
		public override function toXML():XML {
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
			var newParameter = new XML("<ITEM />");
			newParameter.@NAME = "INPUTS";
			newParameter.@VALUE = "Tutondo Inputs";
			newParameters.appendChild(newParameter);
			var newParameter = new XML("<ITEM />");
			newParameter.@NAME = "FUNCTIONS";
			newParameter.@VALUE = "Tutondo Functions";
			newParameters.appendChild(newParameter);		
			newDevice.appendChild(newParameters);
			
			newDevice.appendChild(inputs.toXML());
			newDevice.appendChild(functions.toXML());
			var newTutondo:XML = new XML("<"+device_type+" />");
			var tempAudioVideos:XML = audiovideos.toXML();
			for (var child:int = 0; child<tempAudioVideos.children().length();child++){	
				newTutondo.appendChild(tempAudioVideos.children()[child]);
			}
			newDevice.appendChild(newTutondo);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(inputs.toTree());
			newNode.appendChild(functions.toTree());			
			newNode.appendChild(audiovideos.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Tutondo";
		}	
		public function getClassForm():Class {
			var className:Class = Forms.Server.Tutondo_frm;
			return className;		
		}
		
		public override function newObject():void {
			device_type = "TUTONDO";
			description ="";
			active = "Y";		
					
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "Tutondo Inputs";
			inputs.setXML(newInputs);
			functions = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "Tutondo Functions";
			functions.setXML(newFunctions);		
			audiovideos = new Objects.Server.AudioVideos();
		}
			
		public override function setXML(newData:XML):void {
			device_type = "TUTONDO";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "Tutondo Inputs";
			inputs.setXML(newInputs);
			functions = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "Tutondo Functions";
			functions.setXML(newFunctions);		
			audiovideos = new Objects.Server.AudioVideos();
			if (newData.name() == "DEVICE") {
				if(newData.@NAME!=undefined){
					device_type = newData.@NAME;
				}
				if(newData.@DEVICE_TYPE!=undefined){
					device_type = newData.@DEVICE_TYPE;
				}			
				if(newData.@DISPLAY_NAME!=undefined){			
					description = newData.@DISPLAY_NAME;
				}
				if(newData.@DESCRIPTION!=undefined){			
					description = newData.@DESCRIPTION;
				}			
				if(newData.@ACTIVE!=undefined){			
					active = newData.@ACTIVE;
				}
				for (var child:int = 0; child<newData.children().length();child++){
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						}
						break;
					case "CATALOGUE" :
						if(newData.children()[child].@NAME == "Sign Video Inputs"){
							inputs.setXML(newData.children()[child]);
						}
						break;
					case "SIGN_VIDEO":
						audiovideos.setXML(newData.children()[child]);
						break;
					}
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}