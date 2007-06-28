package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
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
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
					
			if ((active != "Y") && (active != "N")) {
				flag = "error";
				appendValidationMsg("Active is invalid");
			}
			else {
				if (active =="Y"){
					if ((description == undefined) || (description == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((device_type == undefined) || (device_type == "")) {
						flag = "error";
						appendValidationMsg("Device Type is invalid");
					}
									
					if (connection.children()[0].name() == "IP") {
						if ((connection.children()[0].@IP_ADDRESS == "") || (connection.children()[0].@IP_ADDRESS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Address is empty");
						}
						else if (Application.application.isValidIP(connection.children()[0].@IP_ADDRESS)==false) {
							flag = "error";
							appendValidationMsg("Connection IP Address is invalid");
						}
						if ((connection.children()[0].@PORT == "") || (connection.children()[0].@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is empty");
						}
					}
					else{
						//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
						if ((connection.children()[0].@PORT == "") || (connection.children()[0].@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is empty");
						}
						if ((connection.children()[0].@FLOW == "") || (connection.children()[0].@FLOW ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Flow is invalid");
						}
						if ((connection.children()[0].@DATA_BITS == "") || (connection.children()[0].@DATA_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Data Bits is invalid");
						}
						if ((connection.children()[0].@STOP_BITS == "") || (connection.children()[0].@STOP_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Stop Bits is invalid");
						}
						if ((connection.children()[0].@SUPPORTS_CD == "") || (connection.children()[0].@SUPPORTS_CD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Supports CD is invalid");
						}
						if ((connection.children()[0].@PARITY == "") || (connection.children()[0].@PARITY ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Parity is invalid");
						}
						if ((connection.children()[0].@BAUD == "") || (connection.children()[0].@BAUD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Baud is invalid");
						}
					}
				}
				else {
					if (active =="N"){
						flag = "empty";
						appendValidationMsg("Kramer is not active");
					}
				}
			}
			return flag;
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
			newDevice.appendChild(connection);
			var newParameters = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				newParameters.appendChild(parameters[parameter]);
			}
			var newParameter:XML = new XML("<ITEM />");
			newParameter.@NAME = "AV_INPUTS";		
			newParameter.@VALUE = "Kramer AV Inputs";
			newParameters.appendChild(newParameter);
			newParameter = new XML("<ITEM />");
			newParameter.@NAME = "AUDIO_INPUTS";		
			newParameter.@VALUE = "Kramer Audio Inputs";
			//2 for some reason   newParameters.appendChild(newParameter);		
			newParameters.appendChild(newParameter);		
			newDevice.appendChild(newParameters);
			newDevice.appendChild(inputs.toXML());
			newDevice.appendChild(avinputs.toXML());
			var newKramer:XML = new XML(device_type);
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
					switch (newData.children()[child].name()) {
					case "CONNECTION" :
						connection = newData.children()[child];
						break;
					case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							if((newData.children()[child].children()[parameter].@NAME != "AUDIO_INPUTS")&&(newData.children()[child].children()[parameter].@NAME != "AV_INPUTS")){						
								parameters.push(newData.children()[child].children()[parameter]);
							}
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