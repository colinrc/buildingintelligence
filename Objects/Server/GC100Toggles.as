package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("GC100Toggles")]
	[RemoteClass(alias="elifeAdmin.server.gc100Toggles")] 
	public class GC100Toggles extends BaseElement {
		private var container:String;
		private var toggle_type:String;
		private var toggles:Array;
		private var modules:Object;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeUTF(toggle_type);
			output.writeObject(toggles);
			output.writeObject(modules);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF() as String;
			toggle_type = input.readUTF() as String;
			toggles = input.readObject()as Array;
			modules = input.readObject()as Object;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var toggle in toggles){
				tempKeys.push(toggles[toggle].display_name);
			}
			return tempKeys;
		}
		public function GC100Toggles(inToggle_type:String) {
			toggle_type = inToggle_type;
		}
		public function setModules(inModules:Object){
			modules = inModules;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var toggle in toggles) {
				if ((toggles[toggle].active != "Y") && (toggles[toggle].active != "N")) {
					flag = "error";
					appendValidationMsg("Active is invalid");
				}
				else {
					if (toggles[toggle].active =="Y"){
						if ((toggles[toggle].name == undefined) || (toggles[toggle].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((toggles[toggle].key == undefined) || (toggles[toggle].key == "")) {
							flag = "error";
							appendValidationMsg("Input/Output no. is empty");
						}
						if ((toggles[toggle].display_name == undefined) || (toggles[toggle].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(toggles[toggle].display_name) == false) {
								flag = "error";
								appendValidationMsg(toggles[toggle].display_name+" key is not used");
							}
						}
						
						var arrayTest:Array = modules.getData().modules;
						if ((arrayTest == undefined) || (arrayTest.length == 0)) {
							flag = "error";
							appendValidationMsg("Add GC100 Modules first");
						}
						else {
							if ((toggles[toggle].module == undefined) || (toggles[toggle].module.length == 0)) {
								flag = "error";
								appendValidationMsg("Select a GC100 Module");
							}
						}
					}
					else {
						if (toggles[toggle].active =="N"){
							flag = "empty";
							appendValidationMsg("GC100 Toggles is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.gc100toggle";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "GC100_Toggles";
		}
		public override function getName():String {
			switch(toggle_type){
				case"TOGGLE_INPUT":
				return "Toggle Inputs";
				break;
				case"TOGGLE_OUTPUT":
				return "Toggle Outputs";
				break;
			}
		}
		public override function getData():ObjectProxy {
			var tempMod:Object = new Object();
			if (modules==null) {
				tempMod = null;
			} else {
				tempMod = modules.getData().modules;
			}
			return {toggles:toggles,toggle_type:toggle_type,modules:tempMod, dataObject:this};
		}
		public override function setData(newData:Object):void{
			toggles = newData.toggles;
		}
	}
}
