package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("Controls")]
	[RemoteClass(alias="elifeAdmin.server.controls")] 
	public class Controls extends BaseElement {
		private var variables:XML;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(variables);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			variables = input.readObject()as XML;
		}
		
		public function Controls(){
			 variables= new XML("<VARIABLES />");
		}
		public function getKeys():Array{
			var tempKeys = new Array();
			for (var variable:int=0 ; variable < variables.children().length() ; variable++ ) {
				tempKeys.push(variables.children()[variable].@DISPLAY_NAME);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var child:int=0 ; child < variables.children().length() ; child++) {
				if ((variables.children()[child].@ACTIVE != "Y") && (variables.children()[child].@ACTIVE != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				if (variables.children()[child].@ACTIVE =="Y"){
					if ((variables.children()[child].@NAME == undefined) || (variables.children()[child].@NAME == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((variables.children()[child].@DISPLAY_NAME == undefined) || (variables.children()[child].@DISPLAY_NAME == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					if ((variables.children()[child].@INIT_EXTRA == undefined) || (variables.children()[child].@INIT_EXTRA == "")) {
						flag = "error";
						appendValidationMsg("Init Extra is empty");
					}
					if ((variables.children()[child].@INIT_COMMAND == undefined) || (variables.children()[child].@INIT_COMMAND == "")) {
						flag = "error";
						appendValidationMsg("Init Command is empty");
					}
				}
				else{
					flag = "empty";
					appendValidationMsg("Variable " + variables.children()[child].@DISPLAY_NAME + " is not Active");
				}
				
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.variables";
		}
		public override function toXML():XML {
			return variables;
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
		public override function getData():ObjectProxy {
			return {variables:variables, dataObject:this};
		}
		public override function setData(newData:Object):void {
			variables = newData.variables;
		}
		public override function setXML(newData:XML):void {
			if (newData.name() == "VARIABLES") {
				variables = newData;
			} else {
				trace("ERROR, found node "+newData.name()+", expecting VARIABLES");
			}
		}
	}
}