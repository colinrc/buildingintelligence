package Objects.Server {
	import Objects.Server.Device;
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.DMX_frm;
	[Bindable("DMX")]
	[RemoteClass(alias="elifeAdmin.server.dmx")] 
	public class DMX extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	public var active:String;
		private var lights:DMXLights;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(lights);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			lights = input.readObject()as DMXLights;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(lights.getKeys());
			return tempKeys;
		}
		
		public override function isValid():String {
			var flag:String = super.isValid();
			flag = getHighestFlagValue(flag, lights.isValid());
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
			
			var newDMX:XML = new XML("<DMX />");
			var tempLights:XML = lights.toXML();
			for (var child:int=0 ; child < tempLights.children().length() ; child++) {
				newDMX.appendChild(tempLights.children()[child]);
			}
			newDevice.appendChild(newDMX);
			return newDevice;			
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(lights.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "DMX";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.DMX_frm;
			return className;		
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "DMX";
			description ="";
			active = "Y";		
				
			lights = new Objects.Server.DMXLights();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "DMX";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			lights = new Objects.Server.DMXLights();
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
					var field:XML = newData.children()[child];
					switch (fieldName) {
					case "DMX" :
						var tempLights = new XML("<lights />");
						var tempNode = newData.children()[child];
						for (var dynaliteDevice:int=0 ; dynaliteDevice < tempNode.children().length() ; dynaliteDevice++) {
							switch (tempNode.children()[dynaliteDevice].name()) {
							case "LIGHT" :
								tempLights.appendChild(tempNode.children()[dynaliteDevice]);
								break;
							}
						}
						lights.setXML(tempLights);
						break;
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
					}
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}