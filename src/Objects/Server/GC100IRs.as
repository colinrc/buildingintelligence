package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("GC100IRs")]
	[RemoteClass(alias="elifeAdmin.server.gc100IRs")] 
	public class GC100IRs extends BaseElement {
		private var container:String="";
		private var irs:Array;
		private var modules:Object;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(irs);
			output.writeObject(modules);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF() as String;
			irs = input.readObject()as Array;
			modules = input.readObject()as Object;
		}
		
		public function setModules(inModules:Object){
			modules = inModules;
		}
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var ir in irs){
				tempKeys.push(irs[ir].av_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var ir in irs) {
				if ((irs[ir].key == undefined) || (irs[ir].key == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
				if ((irs[ir].name == undefined) || (irs[ir].name == "")) {
					flag = "error";
					appendValidationMsg("Name is empty");
				}
				if ((irs[ir].avname == undefined) || (irs[ir].avname == "")) {
					flag = "error";
					appendValidationMsg("AV Name is empty");
				}
				
				var arrayTest:Array = modules.getData().modules;
				if ((arrayTest == undefined) || (arrayTest.length == 0)) {
					flag = "error";
					appendValidationMsg("Add GC100 Modules first");
				}
				else {
					if ((irs[ir].module == undefined) || (irs[ir].module.length() == 0)) {
						flag = "error";
						appendValidationMsg("Select a GC100 Module");
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.gc100ir";
		}
		public override function getName():String {
			return "IR Outputs";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "GC100_IRs";
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			irs = newData.irs;
		}
		public  function get Data():ObjectProxy {
			var tempMod:Object = new Object();
			if (modules==null) {
				tempMod = null;
			} else {
				tempMod = modules.getData().modules;
			}
			var ob:ObjectProxy = new ObjectProxy( {irs:irs, modules:tempMod, dataObject:this})
			return ob;
		}
	}
}