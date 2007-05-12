package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("SignVideo")]
	[RemoteClass(alias="elifeAdmin.objects.server.signVideo")]
	public class SignVideo extends Device {
		private var audiovideos:AudioVideos;
		private var inputs:Catalogue;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(audiovideos);
			output.writeObject(inputs);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			audiovideos = input.readObject() as AudioVideos;
			inputs = input.readObject()as Catalogue;
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
						flag = "warning";
						appendValidationMsg("Description is invalid");
					}
					if ((device_type == undefined) || (device_type == "")) {
						flag = "error";
						appendValidationMsg("Device Type is invalid");
					}
									
					if (connection.children()[0].name() == "IP") {
						if ((connection.@IP_ADDRESS == "") || (connection.@IP_ADDRESS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Address is invalid");
						}
						if ((connection.@PORT == "") || (connection.@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is invalid");
						}
					}
					else{
						//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
						if ((connection.@PORT == "") || (connection.@PORT ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Port is invalid");
						}
						if ((connection.@FLOW == "") || (connection.@FLOW ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Flow is invalid");
						}
						if ((connection.@DATA_BITS == "") || (connection.@DATA_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Data Bits is invalid");
						}
						if ((connection.@STOP_BITS == "") || (connection.@STOP_BITS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Stop Bits is invalid");
						}
						if ((connection.@SUPPORTS_CD == "") || (connection.@SUPPORTS_CD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Supports CD is invalid");
						}
						if ((connection.@PARITY == "") || (connection.@PARITY ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Parity is invalid");
						}
						if ((connection.@BAUD == "") || (connection.@BAUD ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Baud is invalid");
						}
					}
				}
				else {
					if (active =="N"){
						flag = "empty";
						appendValidationMsg("Sign is not active");
					}
				}
				
			}
			return flag;
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
			newDevice.appendChild(connection);
			var newParameters:XML = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				newParameters.appendChild(parameters[parameter]);
			}
			var newParameter:XML = new XML("<ITEM />");
			newParameter.@NAME = "AV_INPUTS";
			newParameter.@VALUE = "Sign Video Inputs";
			newParameters.appendChild(newParameter);
			newDevice.appendChild(newParameters);
			newDevice.appendChild(inputs.toXML());
			var tempCatalogues = catalogues.toXML();
			for (var child:int = 0; child<tempCatalogues.children().length;child++){	
				newDevice.appendChild(tempCatalogues.children()[child]);
			}
			var newSignVideo:XML = new XML(device_type);
			var tempAudioVideos:XML = audiovideos.toXML();
			for (var child:int = 0; child<tempAudioVideos.children().length;child++){	
				newSignVideo.appendChild(tempAudioVideos.children()[child]);
			}
			newDevice.appendChild(newSignVideo);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(inputs.toTree());
			newNode.appendChild(audiovideos.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "SignVideo";
		}
		
		public function newObject():void {
			device_type = "SIGN_VIDEO";
			description ="";
			active = "Y";
			parameters = new Array();		
			inputs = new Objects.Server.Catalogue();
			catalogues = new Objects.Server.Catalogues();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "Sign Video Inputs";
			inputs.setXML(newInputs);
			audiovideos = new Objects.Server.AudioVideos();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";
			parameters = new Array();		
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "Sign Video Inputs";
			inputs.setXML(newInputs);
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
					switch (newData.children()[child].name()) {
					case "CONNECTION" :
						connection = newData.children()[child];
						break;
					case "PARAMETERS" :
						for (var parameter:int = 0; parameter<newData.children()[child].length();parameter++){
							if((newData.children()[child].children()[parameter].@NAME != "AV_INPUTS")){						
								parameters.push(newData.children()[child].children()[parameter]);
							}
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