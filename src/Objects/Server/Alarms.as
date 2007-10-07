package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import mx.collections.ArrayCollection;
	import Forms.Server.Alarms_frm;
	
	[Bindable("alarms")]
	[RemoteClass(alias="elifeAdmin.objects.server.alarms")]
	public class Alarms extends BaseElement {
		[Bindable]
		public var container:String="";
		[Bindable]
		public var alarms:ArrayCollection;
		
		public function Alarms():void {
			alarms = new ArrayCollection();
			container = new String();
		}
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(alarms);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			alarms = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array{
		var tempKeys:Array = new Array();
			for(var alarm in alarms){
				tempKeys.push(alarms[alarm].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (alarms.length == 0) {
				flag = "empty";
				appendValidationMsg("No Alarms are defined");
			}
			for (var alarm in alarms) {
				if ((alarms[alarm].name == undefined) || (alarms[alarm].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((alarms[alarm].display_name == undefined) || (alarms[alarm].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				} else {
					if (Application.application.isKeyUsed(alarms[alarm].display_name) == false) {
						flag = "error";
						appendValidationMsg(alarms[alarm].display_name+" key is not being used");
					}
				}
				if ((alarms[alarm].key == undefined) || (alarms[alarm].key == "")) {
					flag = "error";
					appendValidationMsg("Alarm Code is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.alarm";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Alarms_frm;
			return className;		
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var alarmsNode = new XML("<"+container +" />");		
			for (var alarm in alarms) {
				var newAlarm:XML = new XML("<ALARM />");
				if(alarms[alarm].key != ""){
					newAlarm.@KEY  = parseInt(alarms[alarm].key).toString(16);
				}
				if(alarms[alarm].display_name != ""){
					newAlarm.@DISPLAY_NAME  = alarms[alarm].display_name;
	 		    }
				if(alarms[alarm].name != ""){
					newAlarm.@NAME = alarms[alarm].name;
	 		    }			
				alarmsNode.appendChild(newAlarm);
			}
			return alarmsNode;
		}
		public override function getName():String {
			return "Alarms";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;	
			return newNode;
		}
		public function getKey():String{
			return "Alarms";
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({alarms:alarms, dataObject:this});
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void{
			alarms = newData.alarms;
		}
		public override function setXML(newData:XML):void {
			alarms = new ArrayCollection();
			container = newData.name();
			for (var child in newData.children()) {
				var newAlarm = new Object();
				newAlarm.key = "";
				newAlarm.display_name = "";
				newAlarm.name = "";
				if(newData.children()[child].@KEY!=undefined){
					newAlarm.key = parseInt(newData.children()[child].@KEY,16);
				}
				if(newData.children()[child].@DISPLAY_NAME!=undefined){
					newAlarm.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if(newData.children()[child].@NAME!=undefined){
					newAlarm.name = newData.children()[child].@NAME;
				}			
				alarms.addItem(newAlarm);
			}
		}
	}
}