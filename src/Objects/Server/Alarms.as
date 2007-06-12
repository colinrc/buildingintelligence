package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("alarms")]
	[RemoteClass(alias="elifeAdmin.objects.server.alarms")]
	public class Alarms extends BaseElement {
		private var container:String;
		private var alarms:Array;
		
		public function Alarms():void {
			alarms = new Array();
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
			alarms = input.readObject()as Array;
		}
		
		public function getKeys():Array{
		var tempKeys:Array = new Array();
	/*		for(var alarm in alarms){
				tempKeys.push(alarms[alarm].display_name);
			}*/
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
					if (_global.isKeyUsed(alarms[alarm].display_name) == false) {
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
		public override function toXML():XML {
			var alarmsNode = new XML(container);		
			for (var alarm in alarms) {
				var newAlarm = new XMLNode(1, "<ALARM />");
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
			return {alarms:alarms, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void{
			alarms = newData.alarms;
		}
		public override function setXML(newData:XML):void {
			alarms = new Array();
			container = newData.name();
			for (var child in newData.childNodes) {
				var newAlarm = new Object();
				newAlarm.key = "";
				newAlarm.display_name = "";
				newAlarm.name = "";
				if(newData.childNodes[child].attributes["KEY"]!=undefined){
					newAlarm.key = parseInt(newData.childNodes[child].attributes["KEY"],16);
				}
				if(newData.childNodes[child].attributes["DISPLAY_NAME"]!=undefined){
					newAlarm.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
				}
				if(newData.childNodes[child].attributes["NAME"]!=undefined){
					newAlarm.name = newData.childNodes[child].attributes["NAME"];
				}			
				alarms.push(newAlarm);
			}
		}
	}
}