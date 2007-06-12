package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("CustomConnect")]
	[RemoteClass(alias="elifeAdmin.server.customConnect")] 
	public class CustomConnect extends Device {
		private var customKeys:CustomConnectKeys;
		private var inStrings:CustomConnectInStrings;
		private var outStrings:CustomConnectOutStrings;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(customKeys);
			output.writeObject(inStrings);
			output.writeObject(outStrings);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			customKeys = input.readObject()as CustomConnectKeys;
			inStrings = input.readObject()as CustomConnectInStrings;
			outStrings = input.readObject()as CustomConnectOutStrings;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(customKeys.getKeys());
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
									
					if (connection.children()[0].nodeName == "IP") {
						if ((connection.children()[0].@IP_ADDRESS == "") || (connection.children()[0].@IP_ADDRESS ==undefined)) {
							flag = "error";
							appendValidationMsg("Connection Address is empty");
						}
						else if (_global.isValidIP(connection.children()[0].@IP_ADDRESS)==false) {
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
			var newParameters:XML = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				newParameters.appendChild(parameters[parameter]);
			}
			newDevice.appendChild(newParameters);
			var tempCatalogues = catalogues.toXML();
			for (var child in tempCatalogues.childNodes) {
				newDevice.appendChild(tempCatalogues.childNodes[child]);
			}
			var newCustomConnection = new XML(device_type);
			var tempCustomKeys = customKeys.toXML();
			for(var child in tempCustomKeys.childNodes){
				newCustomConnection.appendChild(tempCustomKeys.childNodes[child]);
			}
			var tempInStrings = inStrings.toXML();
			for(var child in tempInStrings.childNodes){
				newCustomConnection.appendChild(tempInStrings.childNodes[child]);
			}
			var tempOutStrings = outStrings.toXML();
			for(var child in tempOutStrings.childNodes){
				newCustomConnection.appendChild(tempOutStrings.childNodes[child]);
			}
			newDevice.appendChild(newCustomConnection);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,"Custom Connect",this);
			newNode.appendChild(catalogues.toTree());
			newNode.appendChild(customKeys.toTree());
			newNode.appendChild(inStrings.toTree());
			newNode.appendChild(outStrings.toTree());
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Custom_Connect";
		}
		
		public function newObject():void {
			device_type = "CUSTOM_CONNECT";
			description ="";
			active = "Y";		
			parameters = new Array();		
			customKeys = new Objects.Server.CustomConnectKeys();
			inStrings = new Objects.Server.CustomConnectInStrings();
			outStrings = new Objects.Server.CustomConnectOutStrings();		
			catalogues = new Objects.Server.Catalogues();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";		
			parameters = new Array();		
			customKeys = new Objects.Server.CustomConnectKeys();
			inStrings = new Objects.Server.CustomConnectInStrings();
			outStrings = new Objects.Server.CustomConnectOutStrings();		
			catalogues = new Objects.Server.Catalogues();
			var tempCatalogues = new XML("<Catalogues />");
			if (newData.nodeName == "DEVICE") {
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
							parameters.push(newData.children()[child].children()[parameter]);
						}
						break;
					case "CATALOGUE" :
						tempCatalogues.appendChild(newData.children()[child]);
						break;
					case "CUSTOM_CONNECT" :
						var tempNode = newData.children()[child];
						var tempCustomKeys = new XML("<CUSTOM_CONNECT />");
						var tempInStrings = new XML("<CUSTOM_CONNECT />");
						var tempOutStrings = new XML("<CUSTOM_CONNECT >");
						
						for (var rawDevice:int=0 ; rawDevice < tempNode.children().length() ; rawDevice++) {
							switch (tempNode.children()[rawDevice].name()) {
							case "KEY" :
								tempCustomKeys.appendChild(tempNode.children()[rawDevice]);
								break;
							case "INSTRING" :
								tempInStrings.appendChild(tempNode.children()[rawDevice]);
								break;
							case "OUTSTRING" :
								tempOutStrings.appendChild(tempNode.children()[rawDevice]);
								break;
							}
						}
						customKeys.setXML(tempCustomKeys);
						inStrings.setXML(tempInStrings);
						outStrings.setXML(tempOutStrings);
						break;
					}
				}
				catalogues.setXML(tempCatalogues);
	//			raw_interfaces.catalogues = catalogues;			
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}