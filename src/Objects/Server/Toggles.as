package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.collections.ArrayCollection;
	import Forms.Server.Toggles_frm;
	
	[Bindable("toggles")]
	[RemoteClass(alias="elifeAdmin.objects.server.toggles")]
	public class Toggles extends BaseElement {
		[Bindable]
		public var container:String="";
		[Bindable]
		public var toggle_type:String="";
		[Bindable]
		public var toggles:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeUTF(toggle_type);
			output.writeObject(toggles);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			toggle_type = input.readUTF()as String;
			toggles = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var toggle in toggles){
				tempKeys.push(toggles[toggle].display_name);
			}
			return tempKeys;
		}
		public function Toggles():void {
		}
		public function setType(toggleType:String):void {
			toggle_type = toggleType;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var toggle in toggles) {
				if ((toggles[toggle].active != "Y") && (toggles[toggle].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				
				if (toggles[toggle].active =="Y"){
					if ((toggles[toggle].name == undefined) || (toggles[toggle].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((toggles[toggle].display_name == undefined) || (toggles[toggle].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}else {
						if (Application.application.isKeyUsed(toggles[toggle].display_name) == false) {
							flag = "error";
							appendValidationMsg(toggles[toggle].display_name+" key is not being used");
						}
					}
					
					if ((toggles[toggle].key == undefined) || (toggles[toggle].key == "")) {
						flag = "error";
						appendValidationMsg("Input/Output No. is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("Toggles is not Active");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.toggle";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var togglesNode:XML = new XML("<"+container+" />");
			for (var toggle in toggles) {
				var toggleNode:XML = new XML("<"+toggle_type+" />");
				if (toggles[toggle].name != "") {
					toggleNode.@NAME = toggles[toggle].name;
				}
				if (toggles[toggle].key != "") {
					toggleNode.@KEY = parseInt(toggles[toggle].key).toString(16);
				}
				if (toggles[toggle].display_name != "") {
					toggleNode.@DISPLAY_NAME = toggles[toggle].display_name;
				}
				if (toggles[toggle].active != "") {
					toggleNode.@ACTIVE = toggles[toggle].active;
				}
				if (toggles[toggle].power != "") {
					toggleNode.@POWER_RATING = toggles[toggle].power;
				}
				togglesNode.appendChild(toggleNode);
			}
			return togglesNode;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Toggles";
		}	
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Toggles_frm;
			return className;		
		}
		
		public override function getName():String {
			switch(toggle_type){
				case"TOGGLE_INPUT":
					return "Toggle Inputs";
				break;
				case"TOGGLE_OUTPUT":
					return "Toggle Outputs";
				break;
				case"PULSE_OUTPUT":
					return "Pulse Outputs";
				break;
				case"OUTPUT":
					return "Outputs";
				break;
				case"SENSOR":
					return "Sensors";
				break;
			}
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({toggles:toggles,toggle_type:toggle_type, dataObject:this});
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void{
			toggles = newData.toggles;
		}
		public override function setXML(newData:XML):void {
			toggles = new ArrayCollection();
			container = newData.name();
			for (var child:int = 0; child<newData.children().length();child++){	
				var newToggle:Object = new Object();
				newToggle.name = "";
				newToggle.key = "";
				newToggle.display_name = "";
				newToggle.power = "";
				newToggle.active = "Y";
				if (newData.children()[child].@NAME != undefined) {
					newToggle.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newToggle.key = parseInt(newData.children()[child].@KEY,16);
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newToggle.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@POWER_RATING != undefined) {
					newToggle.power = newData.children()[child].@POWER_RATING;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newToggle.active = newData.children()[child].@ACTIVE;
				}
				toggles.addItem(newToggle);
			}
		}
	}
}