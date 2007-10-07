package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("Macro")]
	[RemoteClass(alias="elifeAdmin.server.macro")] 
	public class Macro extends BaseElement {
		private var name:String="";
		private var steps:Array;
		private var noEdit:Boolean;
		private var noDelete:Boolean;
		private var isSecure:Boolean;
		private var isHidden:Boolean;
		private var integrator:Boolean;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeObject(steps);
			output.writeBoolean(noEdit);
			output.writeBoolean(noDelete);
			output.writeBoolean(isSecure);
			output.writeBoolean(isHidden);
			output.writeBoolean(integrator);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF()as String;
			steps = input.readObject() as Array;
			noEdit = input.readBoolean()as Boolean;
			noDelete = input.readBoolean() as Boolean;
			isSecure = input.readBoolean() as Boolean;
			isHidden = input.readBoolean() as Boolean;
			integrator = input.readBoolean() as Boolean;
		}
		
		public function deleteSelf(){
			treeNode.removeNode();
		}
		public function Macro() {
			name = "";
			steps = new Array();
			noEdit = false;
			noDelete = false;
			isSecure = false;
			isHidden = false;
			integrator = false;
		}
		public override function getForm():String {
			return "forms.project.macro";
		}
		public function publish():XMLNode {
			var newMacro = new XMLNode(1, "CONTROL");
			newMacro.attributes.KEY = "MACRO";
			newMacro.attributes.COMMAND = "getList";
			if(integrator){
				newMacro.attributes.EXTRA = "_"+name;
			} else{
				newMacro.attributes.EXTRA = name;
			}
			newMacro.attributes.TYPE = "";
			newMacro.attributes.RUNNING = "0";
			var status = new Array();
			if (noEdit) {
				status.push("noEdit");
			}
			if (noDelete) {
				status.push("noDelete");
			}
			if (isSecure) {
				status.push("isSecure");
			}
			if (isHidden) {
				status.push("isHidden");
			}
			newMacro.attributes.STATUS = status.join(",");
			for (var step = 0; step < steps.length; step++) {
				var newStep = new XMLNode(1, "CONTROL");
				if (steps[step].key != undefined) {
					newStep.attributes.KEY = steps[step].key;
				} else {
					newStep.attributes.KEY = "";
				}
				if (steps[step].command != undefined) {
					newStep.attributes.COMMAND = steps[step].command;
				} else {
					newStep.attributes.COMMAND = "";
				}
				if (steps[step].extra != undefined) {
					newStep.attributes.EXTRA = steps[step].extra;
				} else {
					newStep.attributes.EXTRA = "";
				}
				if (steps[step].extra2 != undefined) {
					newStep.attributes.EXTRA2 = steps[step].extra2;
				} else {
					newStep.attributes.EXTRA2 = "";
				}
				if (steps[step].extra3 != undefined) {
					newStep.attributes.EXTRA3 = steps[step].extra3;
				} else {
					newStep.attributes.EXTRA3 = "";
				}
				if (steps[step].extra4 != undefined) {
					newStep.attributes.EXTRA4 = steps[step].extra4;
				} else {
					newStep.attributes.EXTRA4 = "";
				}
				if (steps[step].extra5 != undefined) {
					newStep.attributes.EXTRA5 = steps[step].extra5;
				} else {
					newStep.attributes.EXTRA5 = "";
				}
				if (steps[step].target != undefined) {
					newStep.attributes.TARGET = steps[step].target;
				} else {
					newStep.attributes.TARGET = "All";
				}
				if (steps[step].target_user != undefined) {
					newStep.attributes.TARGET_USER = steps[step].target_user;
				} else {
					newStep.attributes.TARGET_USER = "";
				}
				newMacro.appendChild(newStep);
			}
			return newMacro;
		}
		public override function toXML():XML{
			var newMacro = new XML("<CONTROL />");
			newMacro.attributes.KEY = "MACRO";
			newMacro.attributes.COMMAND = "getList";
			newMacro.attributes.EXTRA = name;
			newMacro.attributes.TYPE = "";
			newMacro.attributes.RUNNING = "0";
			newMacro.attributes.integrator = integrator;
			var status:Array = new Array();
			if (noEdit) {
				status.push("noEdit");
			}
			if (noDelete) {
				status.push("noDelete");
			}
			if (isSecure) {
				status.push("isSecure");
			}
			if (isHidden) {
				status.push("isHidden");
			}
			newMacro.@STATUS = status.join(",");
			for (var step:int = 0; step < steps.length; step++) {
				var newStep:XML = new XML("<CONTROL />");
				if (steps[step].key != undefined) {
					newStep.@KEY = steps[step].key;
				} else {
					newStep.@KEY = "";
				}
				if (steps[step].command != undefined) {
					newStep.@COMMAND = steps[step].command;
				} else {
					newStep.@COMMAND = "";
				}
				if (steps[step].extra != undefined) {
					newStep.@EXTRA = steps[step].extra;
				} else {
					newStep.@EXTRA = "";
				}
				if (steps[step].extra2 != undefined) {
					newStep.@EXTRA2 = steps[step].extra2;
				} else {
					newStep.@EXTRA2 = "";
				}
				if (steps[step].extra3 != undefined) {
					newStep.@EXTRA3 = steps[step].extra3;
				} else {
					newStep.@EXTRA3 = "";
				}
				if (steps[step].extra4 != undefined) {
					newStep.@EXTRA4 = steps[step].extra4;
				} else {
					newStep.@EXTRA4 = "";
				}
				if (steps[step].extra5 != undefined) {
					newStep.@EXTRA5 = steps[step].extra5;
				} else {
					newStep.@EXTRA5 = "";
				}
				if (steps[step].target != undefined) {
					newStep.@TARGET = steps[step].target;
				} else {
					newStep.@TARGET = "All";
				}
				if (steps[step].target_user != undefined) {
					newStep.@TARGET_USER = steps[step].target_user;
				} else {
					newStep.@TARGET_USER = "";
				}
				newMacro.appendChild(newStep);
			}
			return newMacro;
		}
		public override function getName():String {
			return name;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Macro";
		}
		public  function get Data():ObjectProxy {
			return {steps:steps, name:name, noEdit:noEdit, noDelete:noDelete, isSecure:isSecure, isHidden:isHidden, integrator:integrator, dataObject:this};
		}
		[Bindable]
		public function set Data(newData:ObjectProxy):void {
			steps = newData.steps;
			name = newData.name;
			noEdit = newData.noEdit;
			noDelete = newData.noDelete;
			isSecure = newData.isSecure;
			isHidden = newData.isHidden;
			integrator = newData.integrator;
		}
		public override function setXML(newData:XML):void {
			steps = new Array();
			noEdit = false;
			noDelete = false;
			isSecure = false;
			isHidden = false;
			integrator = false;
			if (newData.name() == "CONTROL") {
				name = newData.@EXTRA;
				var tempStatus = newData.@STATUS.split(",");
				for (var status in tempStatus) {
					switch (tempStatus[status]) {
					case "noEdit" :
						noEdit = true;
						break;
					case "noDelete" :
						noDelete = true;
						break;
					case "isSecure" :
						isSecure = true;
						break;
					case "isHidden" :
						isHidden = true;
						break;
					}
				}
				if(newData.@integrator == "true"){
					integrator = true;
				}
				for (var child = 0; child < newData.children().length; child++) {
					var newStep = new Object();
					if (newData.children()[child].@KEY != undefined) {
						newStep.key = newData.children()[child].@KEY;
					} else {
						newStep.key = "";
					}
					if (newData.children()[child].@COMMAND != undefined) {
						newStep.command = newData.children()[child].@COMMAND;
					} else {
						newStep.command = "";
					}
					if (newData.children()[child].@EXTRA != undefined) {
						newStep.extra = newData.children()[child].@EXTRA;
					} else {
						newStep.extra = "";
					}
					if (newData.children()[child].@EXTRA2 != undefined) {
						newStep.extra2 = newData.children()[child].@EXTRA2;
					} else {
						newStep.extra2 = "";
					}
					if (newData.children()[child].@EXTRA3 != undefined) {
						newStep.extra3 = newData.children()[child].@EXTRA3;
					} else {
						newStep.extra3 = "";
					}
					if (newData.children()[child].@EXTRA4 != undefined) {
						newStep.extra4 = newData.children()[child].@EXTRA4;
					} else {
						newStep.extra4 = "";
					}
					if (newData.children()[child].@EXTRA5 != undefined) {
						newStep.extra5 = newData.children()[child].@EXTRA5;
					} else {
						newStep.extra5 = "";
					}
					if (newData.children()[child].@TARGET != undefined) {
						newStep.target = newData.children()[child].@TARGET;
					} else {
						newStep.target = "All";
					}
					if (newData.children()[child].@TARGET_USER != undefined) {
						newStep.target_user = newData.children()[child].@TARGET_USER;
					} else {
						newStep.target_user = "";
					}
					steps.push(newStep);
				}
			} else {
				trace("ERROR, found node " + newData.name() + ", expecting CONTROL");
			}
		}
	}
}