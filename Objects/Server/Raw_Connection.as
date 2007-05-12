package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Raw_Connection")]
	[RemoteClass(alias="elifeAdmin.objects.server.raw_Connection")]
	public class Raw_Connection extends Device {
		private var customs:Customs;
		private var raw_interfaces:Raw_Interfaces;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(customs);
			output.writeObject(raw_interfaces);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			customs = input.readObject() as Customs;
			raw_interfaces = input.readObject()as Raw_Interfaces;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(customs.getKeys());
			tempKeys = tempKeys.concat(raw_interfaces.getKeys());
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
					
					for (var param in parameters) {
						if ((parameters[param].@NAME == undefined) || (parameters[param].@NAME == "")) {
							flag = "error";
							appendValidationMsg("Param Name is empty");
						}
						if ((parameters[param].@VALUE == undefined) || (parameters[param].@VALUE == "")) {
							flag = "error";
							appendValidationMsg("Param Value is empty");
						}
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
						appendValidationMsg("Raw Connection is not active");
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
			newDevice.appendChild(newParameters);
			var tempCatalogues = catalogues.toXML();
			for (var child:int = 0; child<tempCatalogues.children().length;child++){
				newDevice.appendChild(tempCatalogues.children()[child]);
			}
			var newRawConnection:XML = new XML(device_type);
			var tempCustoms:XML = customs.toXML();
			for (var child:int = 0; child<tempCustoms.children().length;child++){
				newRawConnection.appendChild(tempCustoms.children()[child]);
			}
			var tempRaw_Interfaces:XML = raw_interfaces.toXML();
			for (var child:int = 0; child<tempRaw_Interfaces.children().length;child++){
				newRawConnection.appendChild(tempRaw_Interfaces.children()[child]);
			}
			newDevice.appendChild(newRawConnection);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,"Raw Connection",this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Raw_Connection";
		}
		
		public function newObject():void {
			device_type = "RAW_CONNECTION";
			description ="";
			active = "Y";		
			parameters = new Array();		
			raw_interfaces = new Objects.Server.Raw_Interfaces();
			customs = new Objects.Server.Customs();
			catalogues = new Objects.Server.Catalogues();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new Array();		
			raw_interfaces = new Objects.Server.Raw_Interfaces();
			customs = new Objects.Server.Customs();
			catalogues = new Objects.Server.Catalogues();
			var tempCatalogues:XML = new XML("<Catalogues />");
			if (newData.name() == "<DEVICE />") {
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
				for (var child:int = 0; child<newData.children().length;child++){
					switch (newData.children()[child].name()) {
					case "CONNECTION" :
						connection = newData.children()[child];
						break;
					case "PARAMETERS" :
						for (var parameter:int = 0; parameter<newData.children()[child].children().length;parameter++){
							parameters.push(newData.children()[child].children()[parameter]);
						}
						break;
					case "CATALOGUE" :
						tempCatalogues.appendChild(newData.children()[child]);
						break;
					case "RAW_CONNECTION" :
						var tempNode:XML = newData.children()[child];
						var tempCustomInputs:XML = new XML(device_type);
						var tempRawInterfaces:XML = new XML(device_type);
						for (var rawDevice:int = 0; rawDevice<tempNode.children().length;rawDevice++){
							switch (tempNode.children()[rawDevice].name()) {
							case "CUSTOM_INPUT" :
								tempCustomInputs.appendChild(tempNode.children()[rawDevice]);
								break;
							case "RAW_INTERFACE" :
								tempRawInterfaces.appendChild(tempNode.children()[rawDevice]);
								break;
							}
						}
						customs.setXML(tempCustomInputs);
						raw_interfaces.setXML(tempRawInterfaces);
						break;
					}
				}
				catalogues.setXML(tempCatalogues);
				raw_interfaces.catalogues = catalogues;			
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}