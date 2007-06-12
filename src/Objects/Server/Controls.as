package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Variables_frm;
	import mx.collections.ArrayCollection;
	[Bindable("Controls")]
	[RemoteClass(alias="elifeAdmin.server.controls")] 
	public class Controls extends BaseElement {
		[Bindable]
		public var variables:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(variables);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			variables = input.readObject()as ArrayCollection;
		}
		
		public function Controls(){
			 variables= new ArrayCollection();
		}
		public function getKeys():Array{
			var tempKeys:Array = new Array();
			for (var variable:int=0 ; variable < variables.length ; variable++ ) {
				tempKeys.push(variables[variable].key);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			for (var child:int=0 ; child < variables.length ; child++) {
				if ((variables[child].active != "Y") && (variables[child].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if (variables[child].active =="Y"){
					if ((variables[child].description == undefined) || (variables[child].description == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((variables[child].key == undefined) || (variables[child].key == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					if ((variables[child].extra == undefined) || (variables[child].extra == "")) {
						flag = "error";
						appendValidationMsg("Init Extra is empty");
					}
					if ((variables[child].command == undefined) || (variables[child].command == "")) {
						flag = "error";
						appendValidationMsg("Init Command is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("Variable " + variables[child].key + " is not Active");
				}
				
			}
			return flag;
		}
		public override function getForm():String {
			var className:String = getQualifiedClassName( this ).replace( "::", "." );	
			return className;			
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Variables_frm;
			return className;		
		}

		public override function toXML():XML {
			var variablesNode:XML = new XML("<VARIABLES />");
			for (var variable:int in variables) {
				var newvariable:XML = new XML("<VARIABLE />");
				if (variables[variable].description != "") {
					newvariable.@NAME = variables[variable].description;
				}
				if (variables[variable].key != "") {
					newvariable.@DISPLAY_NAME = variables[variable].key;
				}
				if (variables[variable].active != "") {
					newvariable.@ACTIVE = variables[variable].active;
				}
				if (variables[variable].extra != "") {
					newvariable.@INIT_EXTRA = variables[variable].extra;
				}
				if (variables[variable].command != "") {
					newvariable.@INIT_COMMAND = variables[variable].command;
				}
				variablesNode.appendChild(newvariable);
			}
			return variablesNode;
		}
		public override function getName():String {
			return "Variables";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Controls";
		}
		public  function get Data():ObjectProxy {
			
			return ObjectProxy({variables:variables, dataObject:this});
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			variables = newData.variables;
		}
		public override function setXML(newData:XML):void {
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newVariables:Object = new Object();
				newVariables.description = "";
				newVariables.key = "";
				newVariables.active = "Y";
				newVariables.extra = "";
				newVariables.command = "";
				
				if (newData.children()[child].@NAME != undefined) {
					newVariables.description = newData.children()[child].@NAME.toString();
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newVariables.key = newData.children()[child].@DISPLAY_NAME.toString();
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newVariables.active = newData.children()[child].@ACTIVE.toString();
				}
				if (newData.children()[child].@INIT_EXTRA != undefined) {
					newVariables.extra = newData.children()[child].@INIT_EXTRA.toString();
				}
				if (newData.children()[child].@INIT_COMMAND != undefined) {
					newVariables.command = newData.children()[child].@INIT_COMMAND.toString();
				}
				variables.addItem(newVariables);
			}
		}
	}
}