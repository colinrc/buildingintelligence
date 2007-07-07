package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Raw_Connection_frm;
	
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
			flag = super.isValid();		
			if (parameters.isEmpty() == true) {
				flag = "error";
				appendValidationMsg("Parameters are empty");
			}
			for (var param in parameters) {
				if ((parameters[param] == undefined) || (parameters[param] == "")) {
					flag = "error";
					appendValidationMsg("Param ("+param+") Value is empty");
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
			newDevice.appendChild(connection.toXML());
			var newParameters = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				var x1:XML = new XML("<ITEM />");
				x1.@NAME = parameter;
				x1.@VALUE = parameters[parameter];
				newParameters.appendChild(x1);
			}
			newDevice.appendChild(newParameters);
			
			var tempCatalogues = catalogues.toXML();
			for (var child:int = 0; child<tempCatalogues.children().length;child++){
				newDevice.appendChild(tempCatalogues.children()[child]);
			}
			var newRawConnection:XML = new XML("<"+device_type+" />");
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
		public function getClassForm():Class {
			var className:Class = Forms.Server.Raw_Connection_frm;
			return className;		
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "RAW_CONNECTION";
			description ="";
			active = "Y";		
					
			raw_interfaces = new Objects.Server.Raw_Interfaces();
			customs = new Objects.Server.Customs();
			catalogues = new Objects.Server.Catalogues();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "RAW_CONNECTION";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			raw_interfaces = new Objects.Server.Raw_Interfaces();
			customs = new Objects.Server.Customs();
			catalogues = new Objects.Server.Catalogues();
			var tempCatalogues:XML = new XML("<Catalogues />");
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
				for (var child:int = 0; child<newData.children().length;child++){
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						}
						break;
					case "CATALOGUE" :
						tempCatalogues.appendChild(newData.children()[child]);
						break;
					case "RAW_CONNECTION" :
						var tempNode:XML = newData.children()[child];
						var tempCustomInputs:XML = new XML("<"+device_type+" />");
						var tempRawInterfaces:XML = new XML("<"+device_type+" />");
						for (var rawDevice:int = 0; rawDevice<tempNode.children().length;rawDevice++){
							var myRaw:String = tempNode.children()[rawDevice].name();
							switch (myRaw) {
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