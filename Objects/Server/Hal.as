package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("Hal")]
	[RemoteClass(alias="elifeAdmin.server.hal")] 
	public class Hal extends Device {
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
						appendValidationMsg("HAL is not active");
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
			var newParameter = new XML("<ITEM />");
			newParameter.@NAME = "INPUTS";
			newParameter.@VALUE = "HAL Inputs";
			newParameters.appendChild(newParameter);
			newParameter = new XML("<ITEM />");
			newParameter.@NAME = "FUNCTIONS";
			newParameter.@VALUE = "HAL Functions";
			newParameters.appendChild(newParameter);		
			newDevice.appendChild(newParameters);
			newDevice.appendChild(inputs.toXML());
			newDevice.appendChild(functions.toXML());		
			var tempCatalogues:XML = catalogues.toXML();
			for (var child:int=0 ; child < tempCatalogues.children().length() ; child++) {
				newDevice.appendChild(tempCatalogues.children()[child]);
			}
			var newHal:XML = new XML(device_type);
			var tempAudioVideos:XML = audiovideos.toXML();
			for (var child:int=0 ; child < tempAudioVideos.children().length() ; child++) {
				newHal.appendChild(tempAudioVideos.children()[child]);
			}
			newDevice.appendChild(newHal);
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
			return "Hal";
		}
		
		public function newObject():void {
			device_type = "HAL";
			description ="";
			active = "Y";
			parameters = new Array();		
			inputs = new Objects.Server.Catalogue();
			catalogues = new Objects.Server.Catalogues();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "HAL Inputs";
			inputs.setXML(newInputs);
			functions = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "HAL Functions";
			functions.setXML(newFunctions);				
			audiovideos = new Objects.Server.AudioVideos();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";
			parameters = new Array();		
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "HAL Inputs";
			inputs.setXML(newInputs);
			functions = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "HAL Functions";
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
				for (var child:int=0 ; child < newData.children().length() ; child++) {
			
					switch (newData.children()[child].name()) {
					case "CONNECTION" :
						connection = newData.children()[child];
						break;
					case "PARAMETERS" :
					for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
						if((newData.children()[child].children()[parameter].@NAME != "INPUTS")&&(newData.children()[child].children()[parameter].@NAME != "FUNCTIONS")){						
								parameters.push(newData.children()[child].children()[parameter]);
							}
						}
						break;
					case "CATALOGUE" :
						if(newData.children()[child].@NAME == "HAL Inputs"){
							inputs.setXML(newData.children()[child]);
						} else if(newData.children()[child].@NAME == "HAL Functions"){
							functions.setXML(newData.children()[child]);						
						}
						break;
					case "HAL":
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