package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.collections.ArrayCollection;
	import Forms.Server.GC100Modules_frm;
	[Bindable("GC100Modules")]
	[RemoteClass(alias="elifeAdmin.server.gc100Modules")] 
	public class GC100Modules extends BaseElement {
		[Bindable]
		public var modules:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(modules);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			modules = input.readObject()as ArrayCollection;
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var module in modules) {
				if ((modules[module].name == undefined) || (modules[module].name == "")) {
					flag = "error";
					appendValidationMsg("Name is empty");
				}
				if ((modules[module].type == undefined) || (modules[module].type == "")) {
					flag = "error";
					appendValidationMsg("Type is invalid");
				}
				if ((modules[module].number == undefined) || (modules[module].number == "")) {
					flag = "error";
					appendValidationMsg("Number is invalid");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.gc100_modules";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			/*for (var module in modules) {
				newNode.appendChild(modules[module].toTree());
			}*/
		
			treeNode = newNode;				
			return newNode;
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.GC100Modules_frm;
			return className;		
		}
		public function getKey():String {
			return "GC100Modules";
		}
		public override function getName():String {
			return "GC100 Modules";
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {modules:modules, dataObject:this})
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			modules = newData.modules;
		}
		public function getModuleNumbers():Array {
			var tempNumbs:Array = new Array();
			for (var module in modules) {
				tempNumbs.push({label: modules[module].number, data: modules[module].number});
			}
			return tempNumbs;
		}
	}
}