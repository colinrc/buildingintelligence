package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Scripts")]
	[RemoteClass(alias="elifeAdmin.objects.server.scripts")]
	public class Scripts extends BaseElement {
		private var scriptInfo:Array = new Array();
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(scriptInfo);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			scriptInfo = input.readObject()as Array;
		}
		
	/*	public function isValid():Boolean {
			var flag = "ok";
			clearValidationMsg();
			
			var autoClose:Boolean = false;
			var iconSet:Boolean = false;
			for (var child in settings.childNodes) {
				if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
					autoClose = true;
				}
				if (settings.childNodes[child].attributes["NAME"] == "ICON") {
					iconSet = true;
				}
			}
			if (autoClose == false) {
				flag = "error";
				appendValidationMsg("Autoclose is empty");
			}
			if (iconSet == false) {
				flag = "error";
				appendValidationMsg("Icon is empty");
			}
			return flag;
		}*/
		public override function getForm():String {
			return "forms.project.script";
		}
		public override function toXML():XML{
			var newNode:XML = new XML("<SCRIPT_STATUS />");
			for(var script in scriptInfo){
				var newScript:XML = new XML("<SCRIPT />");
				newScript.attributes.NAME = scriptInfo[script].name;
				newScript.attributes.ENABLED = scriptInfo[script].enabled;
				if(scriptInfo[script].status != undefined){
					newScript.attributes.STATUS = scriptInfo[script].status;
				} else{
					newScript.attributes.STATUS = "";
				}
				newNode.appendChild(newScript);
			}
			return newNode;
		}
		public override function getName():String {
			return "Scripts";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Scripts";
		}
		public  function get Data():ObjectProxy {
			return {scriptInfo:scriptInfo, dataObject:this};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			scriptInfo = newData.scriptInfo;
		}
		public override function setXML(newData:XML):void {
			scriptInfo = new Array();
			if (newData.name() == "SCRIPT_STATUS") {
				for (var child:int =0; child<newData.children().length(); child++) {
					var script:Object = new Object;
					script.name = "";
					script.enabled = "";
					script.status = "";
					if (newData.children()[child].@NAME != undefined){
						script.name = newData.children()[child].@NAME;
					}
					if (newData.children()[child].@ENABLED != undefined){
						script.enabled = newData.children()[child].@ENABLED;
					}
					if(newData.children()[child].@STATUS != undefined){
						script.status = newData.children()[child].@STATUS;
					}
					scriptInfo.push(script);
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting SCRIPT_STATUS");
			}
		}
	}
}