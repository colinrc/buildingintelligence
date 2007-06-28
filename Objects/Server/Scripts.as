package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Scripts_frm;
	import mx.collections.ArrayCollection;
	
	[Bindable("Scripts")]
	[RemoteClass(alias="elifeAdmin.objects.server.scripts")]
	public class Scripts extends BaseElement {
		private var scriptInfo:ArrayCollection = new ArrayCollection();
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(scriptInfo);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			scriptInfo = input.readObject()as ArrayCollection;
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
			for(var script:int in scriptInfo){
				var newScript:XML = new XML("<SCRIPT />");
				newScript.@NAME = scriptInfo[script].name;
				newScript.@ENABLED = scriptInfo[script].active;
				if(scriptInfo[script].status != undefined){
					newScript.@STATUS = scriptInfo[script].status;
				} else{
					newScript.@STATUS = "";
				}
				newNode.appendChild(newScript);
			}
			return newNode;
		}
		public override function getName():String {
			return "Scripts";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.Scripts_frm;
			return className;		
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
			var ob:ObjectProxy = new ObjectProxy( {scriptInfo:scriptInfo, dataObject:this});
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			scriptInfo = newData.scriptInfo;
		}
		public override function setXML(newData:XML):void {
			scriptInfo = new ArrayCollection();
			if (newData != null) {
				if (newData.name() == "SCRIPT_STATUS") {
					for (var child:int =0; child<newData.children().length(); child++) {
						var script:Object = new Object;
						script.name = "";
						script.active = "";
						script.status = "";
						if (newData.children()[child].@NAME != undefined){
							script.name = newData.children()[child].@NAME;
						}
						if (newData.children()[child].@ENABLED != undefined){
							script.active = newData.children()[child].@ENABLED;
						}
						if(newData.children()[child].@STATUS != undefined){
							script.status = newData.children()[child].@STATUS;
						}
						scriptInfo.addItem(script);
					}
				} else {
					trace("ERROR, found node "+newData.name()+", expecting SCRIPT_STATUS");
				}
			}
		}
	}
}