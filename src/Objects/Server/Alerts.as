package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import mx.collections.ArrayCollection;
	import Forms.Server.Alerts_frm;
	
	[Bindable("alerts")]
	[RemoteClass(alias="elifeAdmin.objects.server.alerts")]
	public class Alerts extends BaseElement {
		[Bindable]
		public var container:String="";
		[Bindable]
		public var alerts:ArrayCollection;
		
		public function Alerts():void {
			container = new String();
			alerts = new ArrayCollection();
		}
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(alerts);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			alerts = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array {
			var tempKeys:Array = new Array();
			for (var alert in alerts) {
				tempKeys.push(alerts[alert].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag:String = "ok";
			
			clearValidationMsg();
			if (alerts.length == 0) {
				flag = "empty";
				appendValidationMsg("No Alerts are defined");
			}
			for (var alert:int in alerts) {
				
	/*			if ((alerts[alert].cat == undefined) || (alerts[alert].cat == "")) {
					flag = "warning";
					appendValidationMsg("Client Catagory is empty");
				} */
				if ((alerts[alert].message == undefined) || (alerts[alert].message == "")) {
					flag = "warning";
					appendValidationMsg("Message is empty");
				} 
				if ((alerts[alert].type == undefined) || (alerts[alert].type == "")) {
					flag = "warning";
					appendValidationMsg("Alert Type has not been selected");
				} 
				
				if ((alerts[alert].active != "Y") && (alerts[alert].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if ((alerts[alert].display_name == undefined) || (alerts[alert].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (Application.application.isKeyUsed(alerts[alert].display_name) == false) {
						flag = "error";
						appendValidationMsg(alerts[alert].display_name+" key is not being used");
					}
				}
				if ((alerts[alert].key == undefined) || (alerts[alert].key == "")) {
					flag = "error";
					appendValidationMsg("Comfort Code is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.alert";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.Alerts_frm;
			return className;		
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var alertsNode:XML = new XML("<"+container+" />");
			for (var alert:int in alerts) {
				var alertNode:XML = new XML("<ALERT />");
				if (alerts[alert].key != "") {
					alertNode.@KEY = parseInt(alerts[alert].key).toString(16);
				}
				if (alerts[alert].display_name != "") {
					alertNode.@DISPLAY_NAME = alerts[alert].display_name;
				}
				if (alerts[alert].active != "") {
					alertNode.@ACTIVE = alerts[alert].active;
				}
				if (alerts[alert].cat != "") {
					alertNode.@CLIENT_CAT = alerts[alert].cat;
				}
				if (alerts[alert].message != "") {
					alertNode.@MESSAGE = alerts[alert].message;
				}
				if (alerts[alert].type != "") {
					alertNode.@ALERT_TYPE = alerts[alert].type;
				}
				alertsNode.appendChild(alertNode);
			}
			return alertsNode;
		}
		public override function getName():String {
			return "Comfort Alerts";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode = newNode;			
			return newNode;
		}
		public function getKey():String {
			return "Alerts";
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({alerts:alerts, dataObject:this});
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			alerts = newData.alerts;
		}
		public override function setXML(newData:XML):void {
			alerts = new ArrayCollection();
			container = newData.name();
			for (var child:int in newData.children()) {
				var newAlert:Object = new Object();
				newAlert.key = "";
				newAlert.display_name = "";
				newAlert.message = "";
				newAlert.active = "Y";
				newAlert.type = "";
				newAlert.cat = "";
				if (newData.children()[child].@KEY != undefined) {
					newAlert.key = parseInt(newData.children()[child].@KEY,16);
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newAlert.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@CLIENT_CAT != undefined) {
					newAlert.cat = newData.children()[child].@CLIENT_CAT;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newAlert.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@MESSAGE != undefined) {
					newAlert.message = newData.children()[child].@MESSAGE;
				}
				if (newData.children()[child].@ALERT_TYPE != undefined) {
					newAlert.type = newData.children()[child].@ALERT_TYPE;
				}
				alerts.addItem(newAlert);
			}
		}
	}
}