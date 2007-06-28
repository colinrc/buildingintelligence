package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("monitors")]
	[RemoteClass(alias="elifeAdmin.objects.server.monitors")]
	public class Monitors extends BaseElement {
		private var container:String="";
		private var monitors:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(monitors);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			monitors = input.readObject()as Array;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var monitor in monitors) {
				tempKeys.push(monitors[monitor].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var monitor in monitors) {
				if ((monitors[monitor].active != "Y") && (monitors[monitor].active != "N")) {
					flag = "error";
					appendValidationMsg("Active is invalid");
				}
				else {
					if (monitors[monitor].active =="Y"){
						if ((monitors[monitor].name == undefined) || (monitors[monitor].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((monitors[monitor].key == undefined) || (monitors[monitor].key == "")) {
							flag = "error";
							appendValidationMsg("Output no. is empty");
						}
						if ((monitors[monitor].display_name == undefined) || (monitors[monitor].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(monitors[monitor].display_name) == false) {
								flag = "error";
								appendValidationMsg(monitors[monitor].display_name+" key is not used");
							}
						}
					}
					else {
						if (monitors[monitor].active =="N"){
							flag = "empty";
							appendValidationMsg("Monitors is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.togglemonitor";
		}
		public override function toXML():XML{
			if (container.length == 0) {
				return XML();
			}
			
			var monitorsNode:XML = new XML(container);
			for (var monitor in monitors) {
				var monitorNode:XML = new XML("<TOGGLE_OUTPUT_MONITOR />");
				if (monitors[monitor].key != "") {
					monitorNode.@KEY = parseInt(monitors[monitor].key).toString(16);
				}
				if (monitors[monitor].name != "") {
					monitorNode.@NAME = monitors[monitor].name;
				}
				if (monitors[monitor].active != "") {
					monitorNode.@ACTIVE = monitors[monitor].active;
				}
				if (monitors[monitor].display_name != "") {
					monitorNode.@DISPLAY_NAME = monitors[monitor].display_name;
				}
				monitorsNode.appendChild(monitorNode);
			}
			return monitorsNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Monitors";
		}	
		public override function getName():String {
			return "Output Monitors";
		}
		public  function get Data():ObjectProxy {
			return {monitors:monitors, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			monitors = newData.monitors;
		}
		public override function setXML(newData:XML):void {
			monitors = new Array();
			container = newData.name();
			for (var child:int = 0; child<newData.children().length;child++){
				var newMonitor:Object = new Object();
				newMonitor.key = "";
				newMonitor.name = "";
				newMonitor.display_name = "";
				newMonitor.active = "Y";
				if (newData.children()[child].@KEY != undefined) {
					newMonitor.key = parseInt(newData.children()[child].@KEY,16);
				}
				if (newData.children()[child].@NAME != undefined) {
					newMonitor.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newMonitor.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newMonitor.active = newData.children()[child].@ACTIVE;
				}
				monitors.push(newMonitor);
			}
		}
	}
}