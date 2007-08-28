package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Oregon_frm;
	
	[Bindable("Oregon")]
	[RemoteClass(alias="elifeAdmin.objects.server.oregon")]
	public class Oregon extends Device {
		[Bindable]
		public var sensors:OregonSensors;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(sensors);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			sensors = input.readObject()as OregonSensors;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(sensors.getKeys());
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
			var newParameters = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				var x1:XML = new XML("<ITEM />");
				x1.@NAME = parameter;
				x1.@VALUE = parameters[parameter];
				newParameters.appendChild(x1);
			}
			newDevice.appendChild(newParameters);
			var newOregon:XML = new XML("<"+device_type+" />");
			var tempSensors:XML = sensors.toXML();
			for (var child:int = 0; child<tempSensors.children().length();child++){
				newOregon.appendChild(tempSensors.children()[child]);
			}
			newDevice.appendChild(newOregon);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(sensors.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Oregon";
		}	
		public function getClassForm():Class {
			var className:Class = Forms.Server.Oregon_frm;
			return className;		
		}
		public override function newObject():void{
			super.newObject();
			device_type = "OREGON";
			description ="";
			parameters.put("MODEL", "WMR968");
			active = "Y";		
				
			sensors = new Objects.Server.OregonSensors();
		}
			
		public override function setXML(newData:XML):void{
			device_type = "OREGON";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			sensors = new Objects.Server.OregonSensors();
			if(newData.name() == "DEVICE"){
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
						case "OREGON":
						sensors.setXML(newData.children()[child]);
						break;
						case "CONNECTION":
						connection.setXML(newData.children()[child]);
						break;
						case "PARAMETERS":
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						}
						break;
					}
				}
			}
			else{
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}