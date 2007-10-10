package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Jandy_frm;
	
	[Bindable("jandy")]
	[RemoteClass(alias="elifeAdmin.objects.server.jandy")]
	public class Jandy extends Device {
	//	private var device_type:String;
	//	private var description:String;
	//	private var active:String;
		[Bindable]
		public var outputs:Toggles;
		[Bindable]
		public var sensors:Toggles;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(outputs);
			output.writeObject(sensors);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			outputs = input.readObject()as Toggles;
			sensors = input.readObject()as Toggles;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(outputs.getKeys());
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
			var newItem = new XML("<ITEM />");
			newItem.@NAME="UNITS";
			newItem.@VALUE="C";
			newParameters.appendChild(newItem);
			
			newDevice.appendChild(newParameters);
			var newJandy:XML = new XML("<"+device_type+" />");
			var tempOutputs = outputs.toXML();
			
			for (var child:int=0 ; child < tempOutputs.children().length() ; child++) {
				newJandy.appendChild(tempOutputs.children()[child]);
			}
			var tempSensors = sensors.toXML();
			for (var child:int=0 ; child < tempSensors.children().length() ; child++) {
				newJandy.appendChild(tempSensors.children[child]);
			}
			newDevice.appendChild(newJandy);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			outputs.setType("OUTPUT");
			newNode.appendChild(outputs.toTree());
			sensors.setType("SENSOR");
			newNode.appendChild(sensors.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Jandi";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.Jandy_frm;
			return className;		
		}
		public override function newObject():void {
			super.newObject();
			device_type = "JANDI";
			description ="";
			active = "Y";		
				
			sensors = new Objects.Server.Toggles();
			sensors.setType("SENSOR");
			outputs = new Objects.Server.Toggles();
			sensors.setType("OUTPUT");
		}
			
		public override function setXML(newData:XML):void {
			device_type = "JANDI";
			description ="";
			active = "Y";		
			parameters = new HashMap();		
			sensors = new Objects.Server.Toggles();
			sensors.setType("SENSOR");
			outputs = new Objects.Server.Toggles();
			sensors.setType("OUTPUT");
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
					case "JANDI" :
						var tempOutputs:XML = new XML("<"+device_type+" />");
						var tempSensors:XML = new XML("<sensors />");
						var tempNode = newData.children()[child];
						for (var JandyDevice:int=0 ; JandyDevice < tempNode.children().length() ; JandyDevice++) {
						switch (tempNode.children()[JandyDevice].name()) {
							case "OUTPUT":
								tempOutputs.appendChild(tempNode.children()[JandyDevice]);
								break;
							case "SENSOR":
								tempSensors.appendChild(tempNode.children()[JandyDevice]);
								break;
							}
						}
						outputs.setXML(tempOutputs);
						sensors.setXML(tempSensors);
						break;
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
						for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
							parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
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