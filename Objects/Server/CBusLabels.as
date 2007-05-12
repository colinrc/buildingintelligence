package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("cBusLabels")]
	[RemoteClass(alias="elifeAdmin.objects.server.cBusLabels")]
	
	public class CBusLabels extends BaseElement {
		private var container:String;
		private var labels:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(labels);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			labels = input.readObject()as Array;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var label in labels) {
				tempKeys.push(labels[label].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var label in labels) {
				if ((labels[label].active != "Y") && (labels[label].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				
				if (labels[label].active =="Y"){
					if(Application.application.advanced){
						if ((labels[label].def == undefined) || (labels[label].def == "")) {
							flag = "empty";
							appendValidationMsg("Default is empty");
						}
						if ((labels[label].application == undefined) || (labels[label].application == "")) {
							flag = "empty";
							appendValidationMsg("App. is empty");
						}
					}
					if ((labels[label].display_name == undefined) || (labels[label].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					} else {
						if (Application.application.isKeyUsed(labels[label].display_name) == false) {
							flag = "error";
							appendValidationMsg(labels[label].display_name+" Key is not used");
						}
					}
					if ((labels[label].name == undefined) || (labels[label].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((labels[label].key == undefined) || (labels[label].key == "")) {
						flag = "error";
						appendValidationMsg("Group Addr. is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("CBUS Dimmers is not Active");
				}
				
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.cbuslabels";
		}
		public override function toXML():XML {
			var labelsNode = new XML("<"+container+" />");
			for (var label in labels) {
				var newLabel = new XML("<LIGHT_CBUS />");
				if (labels[label].name != "") {
					newLabel.@NAME = labels[label].name;
				}
				if (labels[label].display_name != "") {
					newLabel.@DISPLAY_NAME = labels[label].display_name;
				}
				if (labels[label].key != "") {
					newLabel.@KEY = labels[label].key;
				}
				if (labels[label].active != "") {
					newLabel.@ACTIVE = labels[label].active;
				}
				if (labels[label].def != "") {
					newLabel.@DEFAULT = labels[label].def;
				}
				if (labels[label].application != "") {
					newLabel.@CBUS_APPLICATION = labels[label].application;
				}
				labelsNode.appendChild(newLabel);
			}
			return labelsNode;
		}
		public override function getName():String {
			return "Labels";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "CBusLabels";
		}
		public override function setData(newData:Object):void {
			labels = newData.labels;
		}
		public override function getData():ObjectProxy {
			return {labels:labels, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			labels = new Array();
			container = newData.name();
			for (var child in newData.children()) {
				var newLabel = new Object();
				newLabel.name = "";
				newLabel.display_name = "";
				newLabel.key = "";
				newLabel.active = "Y";
				newLabel.def = "";
				if (newData.children()[child].@NAME != undefined) {
					newLabel.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newLabel.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newLabel.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newLabel.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@DEFAULT != undefined) {
					newLabel.def = newData.children()[child].@DEFAULT;
				}
				if (newData.children()[child].@CBUS_APPLICATION != undefined) {
					newLabel.application = newData.children()[child].@CBUS_APPLICATION;
				}
				labels.push(newLabel);
			}
		}
	}
}