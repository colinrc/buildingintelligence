package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("Customs")]
	[RemoteClass(alias="elifeAdmin.server.customs")] 
	public class Customs extends BaseElement {
		private var container:String;
		private var customs:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(customs);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			customs = input.readObject()as Array;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var custom in customs){
				tempKeys.push(customs[custom].display_name);
			}
			return tempKeys;
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var custom in customs) {
				if ((customs[custom].active != "Y") && (customs[custom].active != "N")) {
					flag = "error";
					appendValidationMsg("Active Flag is invalid");
				}
				
				if (customs[custom].active =="Y"){
					if ((customs[custom].name == undefined) || (customs[custom].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((customs[custom].command == undefined) || (customs[custom].command == "")) {
						flag = "warning";
						appendValidationMsg("Command is empty");
					}
					if ((customs[custom].regex!= "Y") && (customs[custom].regex != "N")) {
						flag = "error";
						appendValidationMsg("Key is RegEx. is invalid");
					}
					if ((customs[custom].key == undefined) || (customs[custom].key == "")) {
						flag = "error";
						appendValidationMsg("Input Number is empty");
					}
					
					if ((customs[custom].display_name == undefined) || (customs[custom].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (Application.application.isKeyUsed(customs[custom].display_name) == false) {
							flag = "error";
							appendValidationMsg(customs[custom].display_name+" key is not used");
						}
					}
					
					if ((customs[custom].extra == undefined) || (customs[custom].extra == "")) {
						flag = "warning";
						appendValidationMsg("Extra is not used");
					}
					
					if (Application.application.advanced == true) {
						if ((customs[custom].power == undefined) || (customs[custom].power == "")) {
							flag = "empty";
							appendValidationMsg("Power is empty");
						}
						if ((customs[custom].extra2 == undefined) || (customs[custom].extra2 == "")) {
							flag = "empty";
							appendValidationMsg("Extra2 is empty");
						}
						if ((customs[custom].extra3 == undefined) || (customs[custom].extra3 == "")) {
							flag = "empty";
							appendValidationMsg("Extra3 is empty");
						}
						if ((customs[custom].extra4 == undefined) || (customs[custom].extra4 == "")) {
							flag = "empty";
							appendValidationMsg("Extra4 is empty");
						}
						if ((customs[custom].extra5 == undefined) || (customs[custom].extra5 == "")) {
							flag = "empty";
							appendValidationMsg("Extra5 is empty");
						}
					}
				} else {
					flag = "empty";
					appendValidationMsg("Custom Inputs is not Active");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.custom";
		}
		public override function toXML():XML {
			var customsNode = new XML(container);
			for (var custom in customs) {
				var newCustom = new XML("<CUSTOM_INPUT />");
				if (customs[custom].name != "") {
					newCustom.@NAME = customs[custom].name;
				}
				if (customs[custom].display_name != "") {
					newCustom.@DISPLAY_NAME = customs[custom].display_name;
				}
				if (customs[custom].key != "") {
					newCustom.@KEY = customs[custom].key;
				}
				if (customs[custom].active != "") {
					newCustom.@ACTIVE = customs[custom].active;
				}
				if (customs[custom].command != "") {
					newCustom.@COMMAND = customs[custom].command;
				}
				if (customs[custom].power != "") {
					newCustom.@POWER_RATING = customs[custom].power;
				}
				if (customs[custom].regex != "") {
					newCustom.@KEY_IS_REGEX = customs[custom].regex;
				}
				if (customs[custom].extra != "") {
					newCustom.@EXTRA = customs[custom].extra;
				}
				if (customs[custom].extra2 != "") {
					newCustom.@EXTRA2 = customs[custom].extra2;
				}
				if (customs[custom].extra3 != "") {
					newCustom.@EXTRA3 = customs[custom].extra3;
				}
				if (customs[custom].extra4 != "") {
					newCustom.@EXTRA4 = customs[custom].extra4;
				}
				if (customs[custom].extra5 != "") {
					newCustom.@EXTRA5 = customs[custom].extra5;
				}			
				customsNode.appendChild(newCustom);
			}
			return customsNode;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Customs";
		}
		public override function getName():String {
			return "Custom Inputs";
		}
		public override function getData():ObjectProxy {
			return {customs:customs, dataObject:this};
		}
		public override function setData(newData:Object):void {
			customs = newData.customs;
		}
		public override function setXML(newData:XML):void {
			customs = new Array();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newCustom = new Object();
				newCustom.name = "";
				newCustom.display_name = "";
				newCustom.key = "";
				newCustom.active = "Y";
				newCustom.command = "";
				newCustom.power = "";
				newCustom.regex = "Y";
				newCustom.extra = "";
				newCustom.extra2 = "";
				newCustom.extra3 = "";
				newCustom.extra4 = "";
				newCustom.extra5 = "";			
				if (newData.children()[child].@NAME != undefined) {
					newCustom.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newCustom.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newCustom.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newCustom.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@COMMAND != undefined) {
					newCustom.command = newData.children()[child].@COMMAND;
				}
				if (newData.children()[child].@POWER_RATING != undefined) {
					newCustom.power = newData.children()[child].@POWER_RATING;
				}
				if (newData.children()[child].@KEY_IS_REGEX != undefined) {
					newCustom.regex = newData.children()[child].@KEY_IS_REGEX;
				}
				if (newData.children()[child].@EXTRA != undefined) {
					newCustom.extra = newData.children()[child].@EXTRA;
				}
				if (newData.children()[child].@EXTRA2 != undefined) {
					newCustom.extra2 = newData.children()[child].@EXTRA2;
				}
				if (newData.children()[child].@EXTRA3 != undefined) {
					newCustom.extra3 = newData.children()[child].@EXTRA3;
				}
				if (newData.children()[child].@EXTRA4 != undefined) {
					newCustom.extra4 = newData.children()[child].@EXTRA4;
				}
				if (newData.children()[child].@EXTRA5 != undefined) {
					newCustom.extra5 = newData.children()[child].@EXTRA5;
				}			
				customs.push(newCustom);
			}
		}
	}
}