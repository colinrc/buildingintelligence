package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("cBusTemperatureSensors")]
	[RemoteClass(alias="elifeAdmin.objects.server.cBusTemperatureSensors")]
	public class CBusTemperatureSensors extends BaseElement {
		private var container:String="";
		private var sensors:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(sensors);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			sensors = input.readObject()as Array;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var sensor in sensors) {
				tempKeys.push(sensors[sensor].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var sensor in sensors) {
				if ((sensors[sensor].active != "Y") && (sensors[sensor].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if (sensors[sensor].active =="Y"){
					if ((sensors[sensor].display_name == undefined) || (sensors[sensor].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					} else {
						if (Application.application.isKeyUsed(sensors[sensor].display_name) == false) {
							flag = "error";
							appendValidationMsg(sensors[sensor].display_name+" key is not being used");
						}
					}
					if ((sensors[sensor].name == undefined) || (sensors[sensor].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((sensors[sensor].key == undefined) || (sensors[sensor].key == "")) {
						flag = "error";
						appendValidationMsg("Unit Addr. is emtpy");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("CBUS Temp Sensors is not Active");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.cbustemperaturesensors";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var sensorsNode:XML = new XML("<"+container+" />");
			for (var sensor in sensors) {
				var newSensor = new XML("<TEMPERATURE />");
				if (sensors[sensor].name != "") {
					newSensor.@NAME = sensors[sensor].name;
				}
				if (sensors[sensor].display_name != "") {
					newSensor.@DISPLAY_NAME = sensors[sensor].display_name;
				}
				if (sensors[sensor].key != "") {
					newSensor.@KEY = sensors[sensor].key;
				}
				if (sensors[sensor].active != "") {
					newSensor.@ACTIVE = sensors[sensor].active;
				}
				sensorsNode.appendChild(newSensor);
			}
			return sensorsNode;
		}
		public override function getName():String {
			if(container == "COMFORT"){
				return "CBus Temperature Sensors";
			} else{
				return "Temperatures Sensors";
			}						
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "CBusTemperatures";
		}	
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			sensors = newData.sensors;
		}
		public  function get Data():ObjectProxy {
			return {sensors:sensors, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			sensors = new Array();
			container = newData.name();
			for (var child in newData.children()) {
				var newSensor = new Object();
				newSensor.name = "";
				newSensor.display_name = "";
				newSensor.key = "";
				newSensor.active = "Y";
				if (newData.children()[child].@NAME != undefined) {
					newSensor.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newSensor.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newSensor.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newSensor.active = newData.children()[child].@ACTIVE;
				}
				sensors.push(newSensor);
			}
		}
	}
}