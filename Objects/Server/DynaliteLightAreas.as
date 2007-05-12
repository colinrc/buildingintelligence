package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("DynaliteLightAreas")]
	[RemoteClass(alias="elifeAdmin.server.dynaliteLightAreas")] 
	public class DynaliteLightAreas extends BaseElement {
		private var container:String;
		private var lightAreas:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(lightAreas);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			lightAreas = input.readObject()as Array;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var lightArea in lightAreas){
				tempKeys.push(lightAreas[lightArea].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var lightArea in lightAreas) {
				if ((lightAreas[lightArea].active != "Y") && (lightAreas[lightArea].active != "N")) {
					flag = "error";
					appendValidationMsg("Active Flag is invalid");
				} 
				else {
					if (lightAreas[lightArea].active =="Y"){
						if ((lightAreas[lightArea].name == undefined) || (lightAreas[lightArea].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((lightAreas[lightArea].key == undefined) || (lightAreas[lightArea].key == "")) {
							flag = "error";
							appendValidationMsg("Dynalite Code is empty");
						}
						if ((lightAreas[lightArea].display_name == undefined) || (lightAreas[lightArea].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(lightAreas[lightArea].display_name) == false) {
								flag = "error";
								appendValidationMsg(lightAreas[lightArea].display_name+" key is not used");
							}
						}
					}
					else {
						if (lightAreas[lightArea].active =="N"){
							flag = "empty";
							appendValidationMsg("Dynalite Light Areas is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.dynalitelightAreas";
		}
		public override function toXML():XML {
			var lightAreasNode = new XML(container);
			for (var lightArea in lightAreas) {
				var newLightArea = new XML("<LIGHT_DYNALITE_AREA />");
				if (lightAreas[lightArea].name != "") {
					newLightArea.@NAME = lightAreas[lightArea].name;
				}
				if (lightAreas[lightArea].display_name != "") {
					newLightArea.@DISPLAY_NAME = lightAreas[lightArea].display_name;
				}
				if (lightAreas[lightArea].key != "") {
					newLightArea.@KEY = lightAreas[lightArea].key;
				}
				if (lightAreas[lightArea].active != "") {
					newLightArea.@ACTIVE = lightAreas[lightArea].active;
				}
				lightAreasNode.appendChild(newLightArea);
			}
			return lightAreasNode;
		}
		public override function getName():String {
			return "Areas";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "DynaliteLightAreas";
		}
		public override function setData(newData:Object):void {
			lightAreas = newData.lightAreas;
		}
		public override function getData():ObjectProxy {
			return {lightAreas:lightAreas, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			lightAreas = new Array();
			container = newData.nodeName;
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newLightArea = new Object();
				newLightArea.name = "";
				newLightArea.display_name = "";
				newLightArea.key = "";
				newLightArea.active = "Y";
				newLightArea.box = "";
				if (newData.children()[child].@NAME != undefined) {
					newLightArea.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newLightArea.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newLightArea.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newLightArea.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@BOX != undefined) {
					newLightArea.box = newData.children()[child].@BOX;
				}
				lightAreas.push(newLightArea);
			}
		}
	}
}