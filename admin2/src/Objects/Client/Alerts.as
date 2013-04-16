package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("alerts")]
	[RemoteClass(alias="elifeAdmin.objects.client.alerts")]
	public class Alerts extends BaseElement {
		private var name:String="";
		private var x_pos:String="";
		private var y_pos:String="";
		private var alerts:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeUTF(x_pos);
			output.writeUTF(y_pos);
			output.writeObject(alerts);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF()as String;
			x_pos = input.readUTF()as String;
			y_pos = input.readUTF()as String;
			alerts = input.readObject()as Array;
		}
		
		
		public function deleteSelf() {
			treeNode.removeNode();
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			
			if (alerts.length == 0) {
				flag = "error";
				appendValidationMsg("No Alerts are defined");
			}
			for (var alert in alerts) {
				if ((alerts[alert].attributes["name"] == "") || (alerts[alert].attributes["name"] == undefined)) {
					flag = "error";
					appendValidationMsg("Name is empty");
				}
				//keys is a string comma seperated.
				var theKeys:Array = undefined;
				if ((alerts[alert].attributes["keys"] == "") || (alerts[alert].attributes["keys"] == undefined)) {
					flag = "error";
					appendValidationMsg("No Keys are used");
				}
				else {
					//theKeys = _global.makeArray(alerts[alert].attributes["keys"]);
					theKeys = alerts[alert].attributes["keys"].split(",");
					var changedKeys:String = "";
					for (var key in theKeys) {
						//should be false
						if (Application.application.isKeyValid(theKeys[key]) == false) {
							flag = "error";
							changedKeys = changedKeys +theKeys[key] + ", ";
						}
					}
					if (changedKeys.length > 1) {
						//Take off the last comma ans space
						changedKeys = changedKeys.substring(0, changedKeys.length - 2);						
						appendValidationMsg(changedKeys+" keys has changed and is invalid");
					} else {
						if (changedKeys.length == 1) {
							//Take off the last comma ans space
							changedKeys = changedKeys.substring(0, changedKeys.length - 2);						
							appendValidationMsg(changedKeys+" key has changed and is invalid");
						}
					}
				}
				if ((alerts[alert].attributes["icon"] == "") || (alerts[alert].attributes["icon"] == undefined)) {
					flag = "error";
					appendValidationMsg("No Icon is used");
				}
				if ((alerts[alert].attributes["fadeOutTime"] == "") || (alerts[alert].attributes["fadeOutTime"] == undefined)) {
					flag = "ok";
					appendValidationMsg("No Fade Out Time is used");
				}
				
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.alerts";
		}
		public override function toXML():XML {
			var newNode = new XML("<alerts />");
			if ((name != "") && (name != undefined)) {
				newNode.@name = name;
			}
			if ((x_pos != "") && (x_pos != undefined)) {
				newNode.@x = x_pos;
			}
			if ((y_pos != "") && (y_pos != undefined)) {
				newNode.@y = y_pos;
			}
			for (var alert in alerts) {
				newNode.appendChild(alerts[alert]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
		
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "ClientAlerts";
		}
		public override function getName():String {
			var newString = "Alert : ";
			if ((name != undefined) && (name != "")) {
				newString += name;
			}
			return newString;
		}
		public  function get Data():ObjectProxy {
			return {x_pos:x_pos, y_pos:y_pos, name:name, alerts:alerts, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			if (newData.name() == "alerts") {
				alerts:Array = new Array();
				name = newData.attribute("name");
				x_pos = newData.attribute("x");
				y_pos = newData.attribute("y");
				
				for (var child:int=0; child< newData.children().length();child++) {
					alerts.push(newData.children[child]);
				}
			} else {
				trace("Error, found " + newData.name() + ", was expecting alerts");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			name = newData.name;
			alerts = newData.alerts;
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var alert in alerts) {
				if ((alerts[alert].attributes["keys"] != "") && (alerts[alert].attributes["keys"] != undefined)) {
					var TempKeys = alerts[alert].attributes["keys"].split(",");
					for(var tempkey in TempKeys){
						addUsedKey(TempKeys[tempkey]);
					}
				}
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var alert in alerts) {
				if ((alerts[alert].attributes["icon"] != "") && (alerts[alert].attributes["icon"] != undefined)) {
					addIcon(alerts[alert].attributes["icon"]);
				}
			}
			return usedIcons;
		}
	}
}