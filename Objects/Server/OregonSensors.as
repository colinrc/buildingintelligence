package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("OregonSensors")]
	[RemoteClass(alias="elifeAdmin.objects.server.oregonSensors")]
	public class OregonSensors extends BaseElement {
		private var container:String;
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
			var tempKeys:Array = new Array();
			for (var sensor in sensors) {
				tempKeys.push(sensors[sensor].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			for (var sensor in sensors) {
				if ((sensors[sensor].active != "Y") && (sensors[sensor].active != "N")) {
					flag = "error";
					appendValidationMsg("Active is invalid");
				}
				else {
					if (sensors[sensor].active =="Y"){
						if ((sensors[sensor].name == undefined) || (sensors[sensor].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((sensors[sensor].key == undefined) || (sensors[sensor].key == "")) {
							flag = "error";
							appendValidationMsg("Input/Output no. is empty");
						}
						if ((sensors[sensor].display_name == undefined) || (sensors[sensor].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(sensors[sensor].display_name) == false) {
								flag = "error";
								appendValidationMsg(sensors[sensor].display_name+" key is not used");
							}
						}
						if ((sensors[sensor].channel == undefined) || (sensors[sensor].channel == "")) {
							flag = "error";
							appendValidationMsg("Channel is empty");
						}
					}
					else {
						if (sensors[sensor].active =="N"){
							flag = "empty";
							appendValidationMsg("Oregon Sensors is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.oregonsensors";
		}
		public override function toXML():XML {
			var sensorsNode:XML = new XML(container);
			for (var sensor in sensors) {
				var newSensor:XML = new XML("SENSOR");
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
				if (sensors[sensor].channel != "") {
					newSensor.@CHANNEL = sensors[sensor].channel;
				}
				sensorsNode.appendChild(newSensor);
			}
			return sensorsNode;
		}
		public override function getName():String {
			return "Sensors";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "OregonSensors";
		}
		public override function setData(newData:Object):void {
			sensors = newData.sensors;
		}
		public override function getData():ObjectProxy {
			return {sensors:sensors, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			sensors = new Array();
			container = newData.name();
			for (var child:int = 0; child<newData.children().length;child++){	
				var newSensor = new Object();
				newSensor.name = "";
				newSensor.display_name = "";
				newSensor.key = "";
				newSensor.active = "Y";
				newSensor.channel = "";
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
				if (newData.children()[child].@CHANNEL != undefined) {
					newSensor.channel = newData.children()[child].@CHANNEL;
				}
				sensors.push(newSensor);
			}
		}
	}
}