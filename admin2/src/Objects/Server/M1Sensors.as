package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.collections.ArrayCollection;
	import Forms.Server.M1Sensors_frm;
	
	[Bindable("M1Sensors")]
	[RemoteClass(alias="elifeAdmin.objects.server.m1Sensors")]
	public class M1Sensors extends BaseElement {
		private var container:String="";
		[Bindable]
		public var sensors:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(sensors);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			sensors = input.readObject()as ArrayCollection;
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
					appendValidationMsg("Active is invalid");
				}
				else {
					if (sensors[sensor].active =="Y"){
						if ((sensors[sensor].key == undefined) || (sensors[sensor].key == "")) {
							flag = "error";
							appendValidationMsg("Input/Output no. is empty");
						}
						if ((sensors[sensor].name == undefined) || (sensors[sensor].name == "")) {
							flag = "error";
							appendValidationMsg("Description is empty");
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
						if ((sensors[sensor].group == undefined) || (sensors[sensor].group == "")) {
							flag = "error";
							appendValidationMsg("Group is empty");
						}
						if ((sensors[sensor].units == undefined) || (sensors[sensor].units == "")) {
							flag = "error";
							appendValidationMsg("Units is empty");
						}
					}
					else {
						if (sensors[sensor].active =="N"){
							flag = "empty";
							appendValidationMsg("M1 Sensors is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.m1sensors";
		}
		public override function toXML():XML{
			if (container.length == 0) {
				return XML();
			}
			
			var sensorsNode:XML = new XML("<"+container+" />");
			for (var sensor in sensors) {
				var newSensor:XML = new XML("<SENSOR />");
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
				if (sensors[sensor].group != "") {
					newSensor.@GROUP = sensors[sensor].group;
				}
				if (sensors[sensor].units != "") {
					newSensor.@UNITS = sensors[sensor].units;
				}
				sensorsNode.appendChild(newSensor);
			}
			return sensorsNode;
		}
		public override function getName():String {
			return "M1 Sensors";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "M1Sensors";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.M1Sensors_frm;
			return className;		
		}
		
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			sensors = newData.sensors;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({sensors:sensors, dataObject:this});
			return ob;
		}
		public override function setXML(newData:XML):void {
			sensors = new ArrayCollection();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newSensor = new Object();
				newSensor.name = "";
				newSensor.display_name = "";
				newSensor.key = "";
				newSensor.active = "Y";
				newSensor.group = "";
				newSensor.units = "";
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
				if (newData.children()[child].@GROUP != undefined) {
					newSensor.group = newData.children()[child].@GROUP;
				}
				if (newData.children()[child].@UNITS != undefined) {
					newSensor.units = newData.children()[child].@UNITS;
				}
				sensors.addItem(newSensor);
			}
		}
	}
}