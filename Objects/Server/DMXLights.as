package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("DMXLights")]
	[RemoteClass(alias="elifeAdmin.server.dmxLights")] 
	public class DMXLights extends BaseElement {
		private var container:String;
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
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var light in lights){
				tempKeys.push(lights[light].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var light in lights) {
				if ((lights[light].active != "Y") && (lights[light].aactive != "N")) {
					flag = "error";
					appendValidationMsg("Active Flag is invalid");
				} 
				else {
					if (lights[light].active =="Y"){
						if ((lights[light].name == undefined) || (lights[light].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((lights[light].key == undefined) || (lights[light].key == "")) {
							flag = "error";
							appendValidationMsg("DMX Code is empty");
						}
						if ((lights[light].display_name == undefined) || (lights[light].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(lights[light].display_name) == false) {
								flag = "error";
								appendValidationMsg(lights[light].display_name+" key is not used");
							}
						}
					}
					else {
						if (lights[light].active =="N"){
							flag = "empty";
							appendValidationMsg("DMX light is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.dmxlights";
		}
		public override function toXML():XML {
			var lightsNode = new XML("<DMX />");
			for (var light in lights) {
				var newLight = new XML("<LIGHT />");
				if (lights[light].name != "") {
					newLight.@NAME = lights[light].name;
				}
				if (lights[light].display_name != "") {
					newLight.@DISPLAY_NAME = lights[light].display_name;
				}
				if (lights[light].key != "") {
					newLight.@KEY = lights[light].key;
				}
				if (lights[light].active != "") {
					newLight.@ACTIVE = lights[light].active;
				}
				lightsNode.appendChild(newLight);
			}
			return lightsNode;
		}
		public override function getName():String {
			return "Lights";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "DMXLights";
		}
		public override function setData(newData:Object):void {
			lights = newData.lights;
		}
		public override function getData():ObjectProxy {
			return {lights:lights, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			lights = new Array();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newLight = new Object();
				newLight.name = "";
				newLight.display_name = "";
				newLight.key = "";
				newLight.active = "Y";
				if (newData.children()[child].@NAME != undefined) {
					newLight.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newLight.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newLight.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newLight.active = newData.children()[child].@ACTIVE;
				}
				lights.push(newLight);
			}
		}
	}
}