package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;	
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("CustomConnectKeys")]
	[RemoteClass(alias="elifeAdmin.server.customConnectKeys")] 
	public class CustomConnectKeys extends BaseElement {
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
		/*	for (var custom in customs) {
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
						if (_global.isKeyUsed(customs[custom].display_name) == false) {
							flag = "error";
							appendValidationMsg(customs[custom].display_name+" key is not used");
						}
					}
					
					if ((customs[custom].extra == undefined) || (customs[custom].extra == "")) {
						flag = "warning";
						appendValidationMsg("Extra is not used");
					}
					
					if (_global.advanced == true) {
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
			}*/
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.customkeys";
		}
		public override function toXML():XML {
			var customsNode = new XML("<CUSTOM_CONNECTION />");
			for (var custom in customs) {
				var newCustom = new XML("<KEY />");
				if (customs[custom].name != "") {
					newCustom.@NAME = customs[custom].name;
				}
				if (customs[custom].display_name != "") {
					newCustom.@DISPLAY_NAME = customs[custom].display_name;
				}
				if (customs[custom].value != "") {
					newCustom.@VALUE = customs[custom].value;
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
			return "CustomKeys";
		}
		public override function getName():String {
			return "Custom Keys";
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
				newCustom.value = "";
				if (newData.children()[child].@NAME != undefined) {
					newCustom.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newCustom.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@VALUE != undefined) {
					newCustom.value = newData.children()[child].@VALUE;
				}
				customs.push(newCustom);
			}
		}
	}
}