package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Kramer_frm;
	
	[Bindable("kramer")]
	[RemoteClass(alias="elifeAdmin.objects.server.kramer")]
	public class Kramer extends Device {
		private var audiovideos:AudioVideos;
		private var inputs:Catalogue;
		private var avinputs:Catalogue;	
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(audiovideos);
			output.writeObject(inputs);
			output.writeObject(avinputs);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			audiovideos = input.readObject()as AudioVideos;
			inputs = input.readObject()as Catalogue;
			avinputs = input.readObject()as Catalogue;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(audiovideos.getKeys());
			return tempKeys;
		}

		public override function toXML():XML {
			var newDevice = new XML("<DEVICE />");
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
			var newParameters = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				var x1:XML = new XML("<ITEM />");
				x1.@NAME = parameter;
				x1.@VALUE = parameters[parameter];
				newParameters.appendChild(x1);
			}
			var newParameter:XML = new XML("<ITEM />");
			newParameter.@NAME = "AV_INPUTS";		
			newParameter.@VALUE = "Kramer AV Inputs";
			newParameters.appendChild(newParameter);
			newParameter = new XML("<ITEM />");
			newParameter.@NAME = "AUDIO_INPUTS";		
			newParameter.@VALUE = "Kramer Audio Inputs";
			newParameters.appendChild(newParameter);		
			
			newDevice.appendChild(newParameters);
			newDevice.appendChild(inputs.toXML());
			newDevice.appendChild(avinputs.toXML());
			var newKramer:XML = new XML("<"+device_type+" />");
			var tempAudioVideos = audiovideos.toXML();
			for (var child:int=0 ; child < tempAudioVideos.children().length() ; child++) {
				newKramer.appendChild(tempAudioVideos.children()[child]);
			}
			newDevice.appendChild(newKramer);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(inputs.toTree());
			newNode.appendChild(avinputs.toTree());			
			newNode.appendChild(audiovideos.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Kramer";
		}	
		public function getClassForm():Class {
			var className:Class = Forms.Server.Kramer_frm;
			return className;		
		}
		public override function newObject():void {
			super.newObject();
			device_type = "KRAMER";
			description ="";
			active = "Y";		
					
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "Kramer Audio Inputs";
			inputs.setXML(newInputs);
			avinputs = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "Kramer AV Inputs";
			avinputs.setXML(newFunctions);		
			audiovideos = new Objects.Server.AudioVideos();
		}
			
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "Kramer Audio Inputs";
			inputs.setXML(newInputs);
			avinputs = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "Kramer AV Inputs";
			avinputs.setXML(newFunctions);		
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
				for (var child:int=0 ; child < newData.children().length() ; child++) {
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						//for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
						//	if((newData.children()[child].children()[parameter].@NAME != "AUDIO_INPUTS")&&(newData.children()[child].children()[parameter].@NAME != "AV_INPUTS")){						
						//		parameters.push(newData.children()[child].children()[parameter]);
						//	}
						//}
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						}
						break;
					case "CATALOGUE" :
						if(newData.children()[child].@NAME == "Kramer Audio Inputs"){
							inputs.setXML(newData.children()[child]);
						} else if(newData.children()[child].@NAME == "Kramer AV Inputs"){
							avinputs.setXML(newData.children()[child]);						
						}
						break;
					case "KRAMER":
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