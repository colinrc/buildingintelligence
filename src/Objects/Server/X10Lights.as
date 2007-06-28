package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("X10Lights")]
	[RemoteClass(alias="elifeAdmin.objects.server.x10Lights")]
	public class X10Lights extends BaseElement {
		private var container:String="";
		private var lights:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(lights);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			lights = input.readObject()as Array;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var light in lights) {
				tempKeys.push(lights[light].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var light in lights) {
				if ((lights[light].active != "Y") && (lights[light].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				
				if (lights[light].active =="Y"){
					if (Application.application.advanced ==true) {
						if ((lights[light].power == undefined) || (lights[light].power == "")) {
							flag = "empty";
							appendValidationMsg("Power is empty");
						}
					}
					if ((lights[light].name == undefined) || (lights[light].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((lights[light].display_name == undefined) || (lights[light].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}else {
						if (Application.application.isKeyUsed(lights[light].display_name) == false) {
							flag = "error";
							appendValidationMsg(lights[light].display_name+" key is not being used");
						}
					}
					
					if ((lights[light].key == undefined) || (lights[light].key == "")) {
						flag = "error";
						appendValidationMsg("Unit No. is empty");
					}
					if ((lights[light].x10 == undefined) || (lights[light].x10 == "")) {
						flag = "error";
						appendValidationMsg("X10 House code is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("X10 Lights is not Active");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.x10lights";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var lightsNode:XML = new XML(container);
			for (var light in lights) {
				var lightNode:XML = new XML("<LIGHT_X10 />");
				if (lights[light].name != "") {
					lightNode.@NAME = lights[light].name;
				}
				if (lights[light].key != "") {
					lightNode.@KEY = lights[light].key;
				}
				if (lights[light].display_name != "") {
					lightNode.@DISPLAY_NAME = lights[light].display_name;
				}
				if (lights[light].active != "") {
					lightNode.@ACTIVE = lights[light].active;
				}
				if (lights[light].power != "") {
					lightNode.@POWER_RATING = lights[light].power;
				}
				if (lights[light].x10 != "") {
					lightNode.@X10HOUSE_CODE = lights[light].x10;
				}
				lightsNode.appendChild(lightNode);
			}
			return lightsNode;
		}
		public override function getName():String {
			return "X10 Lights";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "X10Lights";
		}			
		public  function get Data():ObjectProxy {
			return {lights:lights, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			lights = newData.lights;
		}
		public override function setXML(newData:XML):void {
			lights = new Array();
			container = newData.name();
			for (var child:int = 0; child<newData.children().length();child++){
				var newLight = new Object();
				newLight.name = "";
				newLight.key = "";
				newLight.display_name = "";
				newLight.power = "";
				newLight.active = "Y";
				newLight.x10 = "";
				if (newData.children()[child].@NAME != undefined) {
					newLight.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newLight.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newLight.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@POWER_RATING != undefined) {
					newLight.power = newData.children()[child].@POWER_RATING;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newLight.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@X10HOUSE_CODE != undefined) {
					newLight.x10 = newData.children()[child].@X10HOUSE_CODE;
				}
				lights.push(newLight);
			}
		}
	}
}