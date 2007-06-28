package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	[Bindable("counters")]
	[RemoteClass(alias="elifeAdmin.server.counters")] 
	public class Counters extends BaseElement {
		private var container:String="";
		private var counters:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(counters);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			counters = input.readObject()as Array;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var counter in counters){
				tempKeys.push(counters[counter].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var counter in counters) {
				if ((counters[counter].active != "Y") && (counters[counter].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if (counters[counter].active =="Y"){
					if ((counters[counter].name == undefined) || (counters[counter].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((counters[counter].display_name == undefined) || (counters[counter].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (Application.application.isKeyUsed(counters[counter].display_name) == false) {
							flag = "error";
							appendValidationMsg(counters[counter].display_name+" key is not used");
						}
					}
					if ((counters[counter].key == undefined) || (counters[counter].key == "")) {
						flag = "error";
						appendValidationMsg("Counter No. is empty");
					}
					if ((counters[counter].max == undefined) || (counters[counter].max == "")) {
						flag = "error";
						appendValidationMsg("Max is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("Counters is not Active");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.counter";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var countersNode = new XML(container);
			for (var counter in counters) {
				var newCounter = new XML("<COUNTER />");
				if (counters[counter].name != "") {
					newCounter.@NAME = counters[counter].name;
				}
				if (counters[counter].display_name != "") {
					newCounter.@DISPLAY_NAME = counters[counter].display_name;
				}
				if (counters[counter].key != "") {
					newCounter.@KEY = parseInt(counters[counter].key).toString(16);
				}
				if (counters[counter].active != "") {
					newCounter.@ACTIVE = counters[counter].active;
				}
				if (counters[counter].max != "") {
					newCounter.@MAX = counters[counter].max;
				}
				if (counters[counter].power != "") {
					newCounter.@POWER_RATING = counters[counter].power;
				}
				countersNode.appendChild(newCounter);
			}
			return countersNode;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Counters";
		}
		public override function getName():String {
			return "Counters";
		}
		public  function get Data():ObjectProxy {
			return {counters:counters, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			counters = newData.counters;
		}
		public override function setXML(newData:XML):void {
			counters = new Array();
			container = newData.nodeName;
		
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newCounter = new Object();
				newCounter.name = "";
				newCounter.display_name = "";
				newCounter.key = "";
				newCounter.active = "Y";
				newCounter.max = "";
				newCounter.power = "";
				if (newData.children()[child].@NAME != undefined) {
					newCounter.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newCounter.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newCounter.key = parseInt(newData.children()[child].@KEY,16);
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newCounter.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@MAX != undefined) {
					newCounter.max = newData.children()[child].@MAX;
				}
				if (newData.children()[child].@POWER_RATING != undefined) {
					newCounter.power = newData.children()[child].@POWER_RATING;
				}
				counters.push(newCounter);
			}
		}
	}
}