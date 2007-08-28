package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.CustomConnect_frm;
	[Bindable("CustomConnect")]
	[RemoteClass(alias="elifeAdmin.server.customConnect")] 
	public class CustomConnect extends Device {
		public var customKeys:CustomConnectKeys;
		public var inStrings:CustomConnectInStrings;
		public var outStrings:CustomConnectOutStrings;
		
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
		public function getClassForm():Class {
			var className:Class = Forms.Server.CustomConnect_frm;
			return className;		
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(customKeys.getKeys());
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
			var newParameters:XML = new XML("<PARAMETERS />");
			
			var x1:XML = new XML("<ITEM />");
			if (parameters.containsKey("POLL_TEMP_INTERVAL") == true) { 
				x1.@NAME = "POLL_TEMP_INTERVAL";
				x1.@VALUE = parameters.getValue("POLL_TEMP_INTERVAL");
				newParameters.appendChild(x1);
			}
			var x2:XML = new XML("<ITEM />");
			if (parameters.containsKey("LABELS") == true) { 
				x2.@NAME = "LABELS";
				x2.@VALUE = parameters.getValue("LABELS");
				newParameters.appendChild(x2);
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
		
		public override function newObject():void {
			super.newObject();
			device_type = "CUSTOM_CONNECT";
			description ="";
			active = "Y";		
				
			customKeys = new Objects.Server.CustomConnectKeys();
			inStrings = new Objects.Server.CustomConnectInStrings();
			outStrings = new Objects.Server.CustomConnectOutStrings();		
			
		}
		
		public override function setXML(newData:XML):void {
			device_type = "CUSTOM_CONNECT";
			description ="";
			active = "";		
			parameters = new HashMap();		
			customKeys = new Objects.Server.CustomConnectKeys();
			inStrings = new Objects.Server.CustomConnectInStrings();
			outStrings = new Objects.Server.CustomConnectOutStrings();		
			catalogues = new Objects.Server.Catalogues();
			var tempCatalogues = new XML("<Catalogues />");
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
					var fieldName:String = newData.children()[child].name();
					switch (fieldName) {
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0; parameter < newData.children()[child].children().length();parameter++) {
							if((newData.children()[child].children()[parameter].@NAME != "DOOR_IDS")&&(newData.children()[child].children()[parameter].@NAME != "COMFORT_USERS")){
								parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						  	}
						}
						break;
					case "CATALOGUE" :
						tempCatalogues.appendChild(newData.children()[child]);
						break;
					case "CUSTOM_CONNECT" :
						var tempNode = newData.children()[child];
						var tempCustomKeys = new XML("<CUSTOM_CONNECT />");
						var tempInStrings = new XML("<CUSTOM_CONNECT />");
						var tempOutStrings = new XML("<CUSTOM_CONNECT />");
						
						for (var rawDevice:int=0 ; rawDevice < tempNode.children().length() ; rawDevice++) {
							var keyName:String = tempNode.children()[rawDevice].name();
							switch (keyName) {
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